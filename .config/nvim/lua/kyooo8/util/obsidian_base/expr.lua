-- Evaluator for the subset of the Obsidian Bases formula language actually
-- used by this vault's .base files: property paths (file.name, this.file.name),
-- link()/today(), .contains()/.isEmpty()/.toString(), comparisons, unary "!",
-- and "+"/"-" day-duration arithmetic on dates.
-- ponytail: covers only operators/functions seen in Templates/Bases/*.base.
-- Add new ones here as new .base files need them; this is not a general
-- implementation of the Bases formula language (no boolean and/or inside a
-- single expression string -- those are expressed via YAML and/or blocks
-- instead, which is all this vault's files use).
local M = {}

-- ── Tokenizer ──────────────────────────────────────────────────────────────

local function tokenize(src)
	local tokens = {}
	local i = 1
	local n = #src
	while i <= n do
		local c = src:sub(i, i)
		if c:match("%s") then
			i = i + 1
		elseif c == '"' or c == "'" then
			local close = src:find(c, i + 1)
			assert(close, "unterminated string literal in: " .. src)
			tokens[#tokens + 1] = { type = "string", value = src:sub(i + 1, close - 1) }
			i = close + 1
		elseif src:sub(i, i + 1) == "==" or src:sub(i, i + 1) == "!=" or src:sub(i, i + 1) == ">=" or src:sub(i, i + 1) == "<=" then
			tokens[#tokens + 1] = { type = src:sub(i, i + 1) }
			i = i + 2
		elseif c:match("[%(%),%.!><%+%-]") then
			tokens[#tokens + 1] = { type = c }
			i = i + 1
		elseif c:match("[%a_]") then
			local j = i
			while j <= n and src:sub(j, j):match("[%w_]") do
				j = j + 1
			end
			tokens[#tokens + 1] = { type = "ident", value = src:sub(i, j - 1) }
			i = j
		elseif c:match("%d") then
			local j = i
			while j <= n and src:sub(j, j):match("[%d%.]") do
				j = j + 1
			end
			tokens[#tokens + 1] = { type = "number", value = tonumber(src:sub(i, j - 1)) }
			i = j
		else
			error("unexpected character '" .. c .. "' in expression: " .. src)
		end
	end
	return tokens
end

-- ── Parser (produces a small AST) ───────────────────────────────────────────

local Parser = {}
Parser.__index = Parser

local function new_parser(tokens)
	return setmetatable({ tokens = tokens, pos = 1 }, Parser)
end

function Parser:peek()
	return self.tokens[self.pos]
end

function Parser:advance()
	local t = self.tokens[self.pos]
	self.pos = self.pos + 1
	return t
end

function Parser:expect(ty)
	local t = self:advance()
	assert(t and t.type == ty, "expected '" .. ty .. "' but got " .. vim.inspect(t))
	return t
end

-- expr := additive (cmp_op additive)?
function Parser:parse_expr()
	local left = self:parse_unary()
	local t = self:peek()
	if t and (t.type == "==" or t.type == "!=" or t.type == ">=" or t.type == "<=" or t.type == ">" or t.type == "<") then
		self:advance()
		local right = self:parse_unary()
		return { kind = "binop", op = t.type, left = left, right = right }
	end
	return left
end

-- unary := "!" unary | additive
function Parser:parse_unary()
	local t = self:peek()
	if t and t.type == "!" then
		self:advance()
		return { kind = "not", expr = self:parse_unary() }
	end
	return self:parse_additive()
end

-- additive := postfix (("+"|"-") postfix)*
function Parser:parse_additive()
	local left = self:parse_postfix()
	while true do
		local t = self:peek()
		if t and (t.type == "+" or t.type == "-") then
			self:advance()
			local right = self:parse_postfix()
			left = { kind = "binop", op = t.type, left = left, right = right }
		else
			break
		end
	end
	return left
end

-- postfix := primary ("." ident ("(" args ")")?)*
function Parser:parse_postfix()
	local node = self:parse_primary()
	while true do
		local t = self:peek()
		if t and t.type == "." then
			self:advance()
			local name = self:expect("ident").value
			if self:peek() and self:peek().type == "(" then
				local args = self:parse_args()
				node = { kind = "method", target = node, name = name, args = args }
			else
				node = { kind = "member", target = node, name = name }
			end
		else
			break
		end
	end
	return node
end

function Parser:parse_args()
	self:expect("(")
	local args = {}
	if self:peek() and self:peek().type ~= ")" then
		args[#args + 1] = self:parse_expr()
		while self:peek() and self:peek().type == "," do
			self:advance()
			args[#args + 1] = self:parse_expr()
		end
	end
	self:expect(")")
	return args
end

-- primary := STRING | NUMBER | IDENT ("(" args ")")? | "(" expr ")"
function Parser:parse_primary()
	local t = self:advance()
	assert(t, "unexpected end of expression")
	if t.type == "string" then
		return { kind = "literal", value = t.value }
	elseif t.type == "number" then
		return { kind = "literal", value = t.value }
	elseif t.type == "(" then
		local e = self:parse_expr()
		self:expect(")")
		return e
	elseif t.type == "ident" then
		if self:peek() and self:peek().type == "(" then
			local args = self:parse_args()
			return { kind = "call", name = t.value, args = args }
		end
		return { kind = "ident", name = t.value }
	else
		error("unexpected token: " .. vim.inspect(t))
	end
end

--- @param src string
--- @return table ast
function M.parse(src)
	local tokens = tokenize(src)
	local p = new_parser(tokens)
	local ast = p:parse_expr()
	assert(p.pos > #tokens, "trailing tokens after parsing expression: " .. src)
	return ast
end

-- ── Runtime values ──────────────────────────────────────────────────────────
-- A "file ref" wraps a note so `.name`/`.folder`/`.ext`/`.tags`/`.links`/
-- `.backlinks` resolve consistently whether reached via `file.*` or
-- `this.file.*`.

local function file_ref(note_handle)
	return { __kind = "file", note = note_handle }
end

local function link_value(path, label)
	return { __kind = "link", path = path, label = label }
end

-- normalize a link-ish wikilink string "[[path|label]]" / "[[path]]" to path
local function link_text_to_path(s)
	local inner = s:match("^%[%[(.-)%]%]$")
	if not inner then
		return s
	end
	return (inner:match("^([^|]+)") or inner)
end

local function values_equal(a, b)
	if type(a) == "table" and a.__kind == "file" then
		a = a.note.id
	end
	if type(a) == "table" and a.__kind == "link" then
		a = a.path
	end
	if type(b) == "table" and b.__kind == "file" then
		b = b.note.id
	end
	if type(b) == "table" and b.__kind == "link" then
		b = b.path
	end
	return a == b
end

local function contains_value(list, needle)
	if type(list) == "string" then
		local n = needle
		if type(n) == "table" then
			n = n.path or n.note and n.note.id
		end
		return list:find(n, 1, true) ~= nil
	end
	if type(list) ~= "table" then
		return false
	end
	for _, item in ipairs(list) do
		local item_path = item
		if type(item) == "string" then
			item_path = link_text_to_path(item)
		end
		local needle_val = needle
		if type(needle) == "table" and needle.__kind == "link" then
			needle_val = needle.path
		elseif type(needle) == "table" and needle.__kind == "file" then
			needle_val = needle.note.id
		end
		if item_path == needle_val then
			return true
		end
		-- fall back to raw equality (needed when needle is `this` compared
		-- against a plain wikilink string, e.g. `teams.contains(this)`)
		if values_equal(item, needle) then
			return true
		end
	end
	return false
end

local DAY_SECONDS = 24 * 60 * 60

local function parse_duration_days(s)
	local n, unit = s:match("^(%d+)(%a)$")
	assert(n and unit == "d", "unsupported duration (only Nd is supported): " .. tostring(s))
	return tonumber(n)
end

local function date_add(date_str, days)
	local y, m, d = date_str:match("^(%d%d%d%d)-(%d%d)-(%d%d)")
	assert(y, "expected ISO date string, got: " .. tostring(date_str))
	local t = os.time({ year = tonumber(y), month = tonumber(m), day = tonumber(d), hour = 0 })
	return os.date("%Y-%m-%d", t + days * DAY_SECONDS)
end

-- ── Evaluator ────────────────────────────────────────────────────────────────

local eval

local function resolve_ident(name, ctx)
	if name == "this" then
		return ctx.this and { __kind = "file", note = ctx.this } or nil
	elseif name == "file" then
		return file_ref(ctx.note)
	else
		return ctx.note:get_field(name)
	end
end

local function call_function(name, args, ctx)
	if name == "link" then
		local path = eval(args[1], ctx)
		local label = args[2] and eval(args[2], ctx) or nil
		return link_value(path, label)
	elseif name == "today" then
		return os.date("%Y-%m-%d")
	else
		error("unsupported function: " .. name)
	end
end

local function eval_member(target, name, ctx)
	if target == nil then
		-- e.g. `this.file.name` when `this` is unset (no embedding context):
		-- treat the whole chain as absent rather than erroring.
		return nil
	end
	if type(target) == "table" and target.__kind == "file" then
		local note = target.note
		if name == "name" then
			return note.id
		elseif name == "folder" then
			local dir = vim.fs.dirname(note.path) or ""
			local rel = vim.fs.relpath(ctx.vault_root, dir)
			return rel or ""
		elseif name == "ext" then
			return "md"
		elseif name == "tags" then
			return note.tags or {}
		elseif name == "links" then
			return ctx.links_of(note)
		elseif name == "backlinks" then
			return ctx.backlinks_of(note)
		elseif name == "file" then
			return target
		else
			return note:get_field(name)
		end
	end
	error("cannot access member '" .. name .. "' on value: " .. vim.inspect(target))
end

local function eval_method(target_ast, name, args_ast, ctx)
	local target = eval(target_ast, ctx)
	if name == "contains" then
		local needle = eval(args_ast[1], ctx)
		return contains_value(target, needle)
	elseif name == "isEmpty" then
		if type(target) == "table" then
			return #target == 0
		end
		return target == nil or target == ""
	elseif name == "toString" then
		return target
	else
		error("unsupported method: " .. name)
	end
end

eval = function(node, ctx)
	if node.kind == "literal" then
		return node.value
	elseif node.kind == "ident" then
		return resolve_ident(node.name, ctx)
	elseif node.kind == "call" then
		return call_function(node.name, node.args, ctx)
	elseif node.kind == "member" then
		local target = eval(node.target, ctx)
		return eval_member(target, node.name, ctx)
	elseif node.kind == "method" then
		return eval_method(node.target, node.name, node.args, ctx)
	elseif node.kind == "not" then
		local v = eval(node.expr, ctx)
		return not v
	elseif node.kind == "binop" then
		local op = node.op
		if op == "+" or op == "-" then
			local left = eval(node.left, ctx)
			local right = eval(node.right, ctx)
			if left == nil then
				return nil
			end
			if type(right) == "string" and right:match("^%d+d$") then
				local days = parse_duration_days(right)
				return date_add(left, op == "-" and -days or days)
			end
			error("unsupported arithmetic operands: " .. vim.inspect(left) .. ", " .. vim.inspect(right))
		end
		local left = eval(node.left, ctx)
		local right = eval(node.right, ctx)
		if op == "==" then
			return values_equal(left, right)
		elseif op == "!=" then
			return not values_equal(left, right)
		end
		-- ordering comparisons need two comparable scalars; a missing property
		-- (nil) simply fails the filter instead of erroring.
		if left == nil or right == nil then
			return false
		end
		if op == ">=" then
			return left >= right
		elseif op == "<=" then
			return left <= right
		elseif op == ">" then
			return left > right
		elseif op == "<" then
			return left < right
		end
	end
	error("unhandled AST node: " .. vim.inspect(node))
end

--- Evaluate a single Bases expression string against a context.
--- @param src string
--- @param ctx table { note, this, links_of, backlinks_of, vault_root }
--- @return any
function M.eval_string(src, ctx)
	local ast = M.parse(src)
	return eval(ast, ctx)
end

function M._selftest()
	local fake_notes = {
		["Categories/People"] = { id = "Categories/People", path = "/vault/Categories/People.md", tags = {}, fields = {} },
		["ito yuki"] = {
			id = "ito yuki",
			path = "/vault/ito yuki.md",
			tags = {},
			fields = { categories = { "[[Categories/People|People]]" }, organizations = { "[[kufu]]" }, created = "2026-10-19" },
		},
	}
	local function mk_note(id)
		local n = fake_notes[id]
		return {
			id = n.id,
			path = n.path,
			tags = n.tags,
			get_field = function(_, key)
				return n.fields[key]
			end,
		}
	end

	local ctx = {
		note = mk_note("ito yuki"),
		this = nil,
		vault_root = "/vault",
		links_of = function()
			return {}
		end,
		backlinks_of = function()
			return {}
		end,
	}

	assert(M.eval_string('categories.contains(link("Categories/People", "People"))', ctx) == true, "contains(link) should match")
	assert(M.eval_string('categories.contains(link("Categories/Other"))', ctx) == false, "contains(link) should not match")
	assert(M.eval_string('!file.folder.contains("Templates")', ctx) == true, "folder negation should hold")
	assert(M.eval_string('file.ext == "md"', ctx) == true, "file.ext == md")
	assert(M.eval_string('file.name != "someone else"', ctx) == true, "file.name != literal")

	local today = os.date("%Y-%m-%d")
	local six_days_ago = date_add(today, -6)
	assert(M.eval_string("today() - \"6d\"", ctx) == six_days_ago, "date subtraction mismatch")

	return true
end

return M
