-- Minimal block-style YAML reader scoped to the shape Obsidian Bases (.base)
-- files actually use: nested maps/lists of scalars, no anchors, no flow
-- style, no multi-line scalars. NOT a general YAML parser.
-- ponytail: block-style map/list/scalar only; extend if a .base file ever
-- uses flow style (`{a: b}` / `[a, b]`) or multi-line strings.
local M = {}

local function trim(s)
	return s:match("^%s*(.-)%s*$")
end

local function strip_quotes(s)
	s = trim(s)
	if #s >= 2 then
		local first, last = s:sub(1, 1), s:sub(-1)
		if (first == "'" and last == "'") or (first == '"' and last == '"') then
			return s:sub(2, -2)
		end
	end
	return s
end

local function indent_of(line)
	local spaces = line:match("^( *)")
	return #spaces
end

local function is_blank(line)
	return trim(line) == ""
end

-- forward declare
local parse_block

-- Parses a sequence of "- ..." lines at exactly `indent`. Returns the list
-- and the next line index to continue from.
local function parse_list(lines, i, indent)
	local items = {}
	while i <= #lines do
		local line = lines[i]
		if is_blank(line) then
			i = i + 1
		elseif indent_of(line) == indent and line:match("^%s*%- ?") then
			local after_dash = line:match("^%s*%-(.*)$")
			local content_indent = indent + (line:match("^%s*%- ") and 2 or 1)
			local rest = trim(after_dash)
			if rest == "" then
				local value, next_i = parse_block(lines, i + 1, content_indent)
				items[#items + 1] = value
				i = next_i
			elseif rest:match("^[%w_%.]+:%s*(.*)$") or rest:match("^[%w_%.]+:$") then
				-- inline map start, e.g. `- type: table`
				local map = {}
				local order = {}
				local synthetic = { string.rep(" ", content_indent) .. rest }
				local combined = {}
				for _, l in ipairs(synthetic) do
					combined[#combined + 1] = l
				end
				-- parse the first key:value from the synthetic line, then continue
				-- scanning subsequent real lines at content_indent for more keys.
				local key, val = rest:match("^([%w_%.]+):%s*(.*)$")
				if val == "" then
					local sub_i = i + 1
					-- peek: does a deeper block follow?
					if sub_i <= #lines and not is_blank(lines[sub_i]) and indent_of(lines[sub_i]) > content_indent then
						local value, next_i = parse_block(lines, sub_i, indent_of(lines[sub_i]))
						map[key] = value
						i = next_i
					else
						map[key] = nil
						i = i + 1
					end
				else
					map[key] = strip_quotes(val)
					i = i + 1
				end
				order[#order + 1] = key
				local m2, next_i = parse_block(lines, i, content_indent, map, order)
				items[#items + 1] = m2
				i = next_i
			else
				items[#items + 1] = strip_quotes(rest)
				i = i + 1
			end
		else
			break
		end
	end
	return items, i
end

-- Parses "key:" / "key: value" lines at exactly `indent`, optionally seeded
-- with an already-started map/order pair (used when a list item's inline
-- map already consumed its first key).
local function parse_map(lines, i, indent, seed_map, seed_order)
	local map = seed_map or {}
	local order = seed_order or {}
	while i <= #lines do
		local line = lines[i]
		if is_blank(line) then
			i = i + 1
		elseif indent_of(line) == indent and not line:match("^%s*%-") then
			local key, val = trim(line):match("^([%w_%.]+):%s*(.*)$")
			if not key then
				break
			end
			if val == "" then
				local next_i = i + 1
				if next_i <= #lines and not is_blank(lines[next_i]) and indent_of(lines[next_i]) > indent then
					local value, after_i = parse_block(lines, next_i, indent_of(lines[next_i]))
					map[key] = value
					i = after_i
				else
					map[key] = nil
					i = next_i
				end
			else
				map[key] = strip_quotes(val)
				i = i + 1
			end
			order[#order + 1] = key
		else
			break
		end
	end
	return map, i
end

-- Dispatches to parse_list or parse_map based on what the line at `i` looks
-- like, both anchored at `indent`.
parse_block = function(lines, i, indent, seed_map, seed_order)
	while i <= #lines and is_blank(lines[i]) do
		i = i + 1
	end
	if i > #lines then
		return seed_map or {}, i
	end
	if lines[i]:match("^%s*%-") and indent_of(lines[i]) == indent then
		return parse_list(lines, i, indent)
	end
	return parse_map(lines, i, indent, seed_map, seed_order)
end

--- @param text string raw file contents
--- @return table
function M.parse(text)
	local lines = vim.split(text, "\n", { plain = true })
	local value = parse_block(lines, 1, 0)
	return value
end

--- @param path string
--- @return table
function M.parse_file(path)
	local lines = vim.fn.readfile(path)
	return (parse_block(lines, 1, 0))
end

function M._selftest()
	local sample = table.concat({
		"filters:",
		"  and:",
		"    - '!file.folder.contains(\"Templates\")'",
		"views:",
		"  - type: table",
		"    name: Organizations",
		"    filters:",
		"      and:",
		"        - categories.contains(link(\"Categories/Organizations\"))",
		"    order:",
		"      - file.name",
		"      - created",
		"    sort:",
		"      - property: file.name",
		"        direction: ASC",
		"    columnSize:",
		"      file.name: 467",
	}, "\n")

	local parsed = M.parse(sample)
	assert(type(parsed.filters) == "table", "filters should parse as a table")
	assert(parsed.filters["and"][1] == '!file.folder.contains("Templates")', "nested and[1] mismatch")
	assert(type(parsed.views) == "table" and #parsed.views == 1, "views should be a 1-item list")
	local view = parsed.views[1]
	assert(view.type == "table", "view.type mismatch: " .. vim.inspect(view.type))
	assert(view.name == "Organizations", "view.name mismatch: " .. vim.inspect(view.name))
	assert(view.filters["and"][1] == 'categories.contains(link("Categories/Organizations"))', "view filter mismatch")
	assert(#view.order == 2 and view.order[1] == "file.name" and view.order[2] == "created", "order mismatch")
	assert(view.sort[1].property == "file.name" and view.sort[1].direction == "ASC", "sort mismatch")
	assert(view.columnSize["file.name"] == "467", "columnSize mismatch")

	return true
end

return M
