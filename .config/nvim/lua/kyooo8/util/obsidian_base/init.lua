-- Renders an Obsidian Bases (.base) table view inside Neovim: scans the
-- vault's markdown notes, applies the view's filters (see expr.lua), sorts,
-- and shows the result as a read-only table in a floating window.
-- ponytail: table views only (the only type used in this vault); no editing,
-- no live two-way sync -- re-run the command to refresh.
local yaml = require("kyooo8.util.obsidian_base.yaml")
local expr = require("kyooo8.util.obsidian_base.expr")

local M = {}

local function vault_root()
	return tostring(Obsidian.workspace.path)
end

local function find_markdown_files(root)
	local files = {}
	for name, ty in vim.fs.dir(root, { depth = math.huge }) do
		if ty == "file" and name:match("%.md$") then
			files[#files + 1] = vim.fs.joinpath(root, name)
		end
	end
	return files
end

-- Obsidian embeds resolve by "shortest path" (e.g. `![[Daily.base]]` can
-- point at Templates/Bases/Daily.base) rather than a vault-root-relative
-- path. Try the literal join first, then fall back to a vault-wide search
-- by basename.
local function resolve_base_path(root, embed_path)
	local direct = vim.fs.joinpath(root, embed_path)
	if vim.uv.fs_stat(direct) then
		return direct
	end
	local basename = vim.fs.basename(embed_path)
	local matches = vim.fs.find(basename, { path = root, type = "file", limit = 1 })
	return matches[1]
end

-- Extracts outgoing wikilink targets (basenames, no alias/anchor) from a
-- note's raw body text.
local function extract_links(text)
	local links = {}
	for inner in text:gmatch("%[%[(.-)%]%]") do
		local target = inner:match("^([^|#]+)")
		if target then
			target = vim.trim(target)
			links[#links + 1] = target
		end
	end
	return links
end

--- Build a link graph (outgoing + backlinks) over the given notes by id.
--- @param notes_by_id table<string, obsidian.Note>
--- @return table links_of, table backlinks_of  (both keyed by note id -> list of ids)
local function build_link_graph(notes_by_id)
	local links_of = {}
	local backlinks_of = {}
	for id in pairs(notes_by_id) do
		backlinks_of[id] = backlinks_of[id] or {}
	end
	for id, note in pairs(notes_by_id) do
		local ok, lines = pcall(vim.fn.readfile, note.path)
		local text = ok and table.concat(lines, "\n") or ""
		local targets = extract_links(text)
		links_of[id] = targets
		for _, target in ipairs(targets) do
			if notes_by_id[target] then
				backlinks_of[target] = backlinks_of[target] or {}
				table.insert(backlinks_of[target], id)
			end
		end
	end
	return links_of, backlinks_of
end

--- @param filter_node any  string | { ["and"]=list } | { ["or"]=list } | nil
--- @param ctx table
--- @return boolean
local function matches_filter(filter_node, ctx)
	if filter_node == nil then
		return true
	end
	if type(filter_node) == "string" then
		local ok, result = pcall(expr.eval_string, filter_node, ctx)
		if not ok then
			error("filter error in '" .. filter_node .. "': " .. tostring(result))
		end
		return result == true
	end
	if filter_node["and"] then
		for _, child in ipairs(filter_node["and"]) do
			if not matches_filter(child, ctx) then
				return false
			end
		end
		return true
	end
	if filter_node["or"] then
		for _, child in ipairs(filter_node["or"]) do
			if matches_filter(child, ctx) then
				return true
			end
		end
		return false
	end
	error("unrecognized filter node: " .. vim.inspect(filter_node))
end

--- Resolve a display value for `column` (e.g. "file.name", "created",
--- "categories") against a note, for rendering a table cell.
local function column_value(column, note)
	if column == "file.name" then
		return note.id
	elseif column == "file.folder" then
		return vim.fs.dirname(note.path) or ""
	elseif column == "file.ext" then
		return "md"
	elseif column == "file.tags" or column == "tags" then
		return table.concat(note.tags or {}, ", ")
	else
		local field = note:get_field(column)
		if field == nil then
			return ""
		elseif type(field) == "table" then
			local parts = {}
			for _, v in ipairs(field) do
				local inner = tostring(v):match("^%[%[(.-)%]%]$")
				if inner then
					parts[#parts + 1] = inner:match("|(.+)$") or inner
				else
					parts[#parts + 1] = tostring(v)
				end
			end
			return table.concat(parts, ", ")
		end
		return tostring(field)
	end
end

local function sort_rows(rows, sort_spec)
	if not sort_spec or #sort_spec == 0 then
		return
	end
	table.sort(rows, function(a, b)
		for _, key in ipairs(sort_spec) do
			local av = column_value(key.property, a)
			local bv = column_value(key.property, b)
			if av ~= bv then
				if key.direction == "DESC" then
					return av > bv
				end
				return av < bv
			end
		end
		return false
	end)
end

--- Scan the vault once: load every note and build the link graph. Reuse the
--- result across multiple run_view() calls (e.g. rendering several embeds,
--- or several views of one .base file) instead of rescanning per view.
--- @return table  { root, notes_by_id, links_of, backlinks_of }
function M.scan_vault()
	local Note = require("obsidian.note")
	local root = vault_root()
	local paths = find_markdown_files(root)

	local notes_by_id = {}
	for _, path in ipairs(paths) do
		local ok, note = pcall(Note.from_file, path)
		if ok then
			note.path = tostring(note.path) -- obsidian.Path -> string, for vim.fs.*
			notes_by_id[note.id] = note
		end
	end

	local links_of, backlinks_of = build_link_graph(notes_by_id)
	return { root = root, notes_by_id = notes_by_id, links_of = links_of, backlinks_of = backlinks_of }
end

--- Run a single view of a parsed .base file against the vault.
--- @param parsed table  the parsed .base contents (yaml.lua output)
--- @param view table  one entry from parsed.views
--- @param this_note obsidian.Note|nil  the note the base is embedded in, if any
--- @param scan table|nil  reuse a prior M.scan_vault() result instead of rescanning
--- @return table rows  list of obsidian.Note matching the filters, sorted
function M.run_view(parsed, view, this_note, scan)
	scan = scan or M.scan_vault()

	local function ctx_for(note)
		return {
			note = note,
			this = this_note,
			vault_root = scan.root,
			links_of = function(n)
				return scan.links_of[n.id] or {}
			end,
			backlinks_of = function(n)
				return scan.backlinks_of[n.id] or {}
			end,
		}
	end

	local rows = {}
	for _, note in pairs(scan.notes_by_id) do
		local ctx = ctx_for(note)
		local ok, top_ok = pcall(matches_filter, parsed.filters, ctx)
		if ok and top_ok then
			local ok2, view_ok = pcall(matches_filter, view.filters, ctx)
			if ok2 and view_ok then
				rows[#rows + 1] = note
			elseif not ok2 then
				vim.notify("obsidian-base: " .. tostring(view_ok), vim.log.levels.WARN)
			end
		elseif not ok then
			vim.notify("obsidian-base: " .. tostring(top_ok), vim.log.levels.WARN)
		end
	end

	sort_rows(rows, view.sort)
	return rows
end

local function render_table(columns, rows)
	vim.api.nvim_set_hl(0, "ObsidianBaseHeader", {
		default = true,
		fg = vim.api.nvim_get_hl(0, { name = "Normal", link = false }).fg,
		bg = vim.api.nvim_get_hl(0, { name = "Visual", link = false }).bg,
		bold = true,
	})
	vim.api.nvim_set_hl(0, "ObsidianBaseLink", { default = true, link = "ObsidianRefText" })
	local labels = { ["file.name"] = "ノート", created = "作成日", categories = "カテゴリ", tags = "タグ", ["file.tags"] = "タグ" }
	local headers, widths = {}, {}
	for i, col in ipairs(columns) do
		headers[i] = labels[col] or col
		widths[i] = vim.fn.strdisplaywidth(headers[i])
	end
	local cell_rows = {}
	for _, note in ipairs(rows) do
		local cells = {}
		for i, col in ipairs(columns) do
			local v = column_value(col, note)
			cells[i] = v
			widths[i] = math.max(widths[i], vim.fn.strdisplaywidth(v))
		end
		cell_rows[#cell_rows + 1] = cells
	end

	local function fmt_row(cells)
		local parts, style = {}, {}
		local byte_offset = 0
		for i, c in ipairs(cells) do
			if columns[i] == "file.name" then
				style = { hl_group = "ObsidianBaseLink", start_col = byte_offset, end_col = byte_offset + #c }
			end
			parts[i] = c .. string.rep(" ", widths[i] - vim.fn.strdisplaywidth(c))
			byte_offset = byte_offset + #parts[i] + 2
		end
		return table.concat(parts, "  "), style
	end

	local header = fmt_row(headers)
	local lines = { header, string.rep("─", vim.fn.strdisplaywidth(header)) }
	local styles = {
		{ hl_group = "ObsidianBaseHeader", line_hl_group = "ObsidianBaseHeader", end_col = #header },
		{ hl_group = "Comment", end_col = #lines[2] },
	}
	for _, cells in ipairs(cell_rows) do
		local line, style = fmt_row(cells)
		lines[#lines + 1] = line
		styles[#lines] = style
	end
	return lines, styles
end

--- Open a floating window showing `view`'s results. Pressing <CR> on a row
--- jumps to that note; q/<Esc> closes.
function M.show_view(parsed, view, this_note)
	local ok, rows = pcall(M.run_view, parsed, view, this_note)
	if not ok then
		vim.notify("obsidian-base: failed to evaluate view: " .. tostring(rows), vim.log.levels.ERROR)
		return
	end

	local columns = view.order
	if not columns or #columns == 0 then
		columns = { "file.name" }
	end

	local lines = render_table(columns, rows)
	table.insert(lines, 1, (view.name or "view") .. " — " .. #rows .. " results")
	table.insert(lines, 2, "")

	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].modifiable = false
	vim.bo[buf].filetype = "obsidian-base-view"

	local width = 0
	for _, l in ipairs(lines) do
		width = math.max(width, vim.fn.strdisplaywidth(l))
	end
	width = math.min(width + 2, vim.o.columns - 4)
	local height = math.min(#lines + 1, vim.o.lines - 6)

	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = math.floor((vim.o.lines - height) / 2),
		col = math.floor((vim.o.columns - width) / 2),
		style = "minimal",
		border = "rounded",
		title = " " .. (view.name or "Base view") .. " ",
		title_pos = "center",
	})

	local header_offset = 2 -- title line + blank line
	local function jump_to_row()
		local lnum = vim.api.nvim_win_get_cursor(win)[1]
		local row_idx = lnum - header_offset - 2 -- minus column header + separator
		local note = rows[row_idx]
		if not note then
			return
		end
		vim.api.nvim_win_close(win, true)
		vim.cmd.edit(vim.fn.fnameescape(note.path))
	end

	local map_opts = { buffer = buf, nowait = true, silent = true }
	vim.keymap.set("n", "<CR>", jump_to_row, map_opts)
	vim.keymap.set("n", "q", function()
		vim.api.nvim_win_close(win, true)
	end, map_opts)
	vim.keymap.set("n", "<Esc>", function()
		vim.api.nvim_win_close(win, true)
	end, map_opts)
end

--- Load and parse a .base file.
--- @param path string
--- @return table
function M.load(path)
	return yaml.parse_file(path)
end

--- Prompt the user to pick a view (if more than one) and show it.
--- @param base_path string path to the .base file
--- @param this_note obsidian.Note|nil
function M.open(base_path, this_note)
	local parsed = M.load(base_path)
	local views = parsed.views or {}
	if #views == 0 then
		vim.notify("obsidian-base: no views defined in " .. base_path, vim.log.levels.WARN)
		return
	end
	if #views == 1 then
		M.show_view(parsed, views[1], this_note)
		return
	end
	local labels = {}
	for i, v in ipairs(views) do
		labels[i] = v.name or ("view " .. i)
	end
	vim.ui.select(labels, { prompt = "Base view:" }, function(_, idx)
		if idx then
			M.show_view(parsed, views[idx], this_note)
		end
	end)
end

--- Resolve what to open from the current cursor context:
---  - cursor on an embed line `![[Foo.base#View]]` -> that base + current note as `this`
---  - current buffer is itself a .base file -> that file, no `this`
--- @return string|nil base_path, string|nil view_name, obsidian.Note|nil this_note
function M.resolve_at_cursor()
	local line = vim.api.nvim_get_current_line()
	local embed_path, view_name = line:match("!%[%[([^%]#]+%.base)#?([^%]]*)%]%]")
	if embed_path then
		local root = vault_root()
		local full = resolve_base_path(root, embed_path)
		local Note = require("obsidian.note")
		local ok, this_note = pcall(Note.from_buffer, 0)
		return full, (view_name ~= "" and view_name or nil), ok and this_note or nil
	end

	local bufname = vim.api.nvim_buf_get_name(0)
	if bufname:match("%.base$") then
		return bufname, nil, nil
	end

	return nil, nil, nil
end

--- Entry point for the user command: resolve context, then open (optionally
--- jumping straight to a named view from an embed's #View anchor).
function M.open_at_cursor()
	local base_path, view_name, this_note = M.resolve_at_cursor()
	if not base_path then
		vim.notify("obsidian-base: place the cursor on a .base file or a ![[x.base#View]] embed", vim.log.levels.WARN)
		return
	end
	if not vim.uv.fs_stat(base_path) then
		vim.notify("obsidian-base: file not found: " .. base_path, vim.log.levels.ERROR)
		return
	end
	if view_name then
		local parsed = M.load(base_path)
		for _, v in ipairs(parsed.views or {}) do
			if v.name == view_name then
				M.show_view(parsed, v, this_note)
				return
			end
		end
		vim.notify("obsidian-base: view '" .. view_name .. "' not found in " .. base_path, vim.log.levels.WARN)
		return
	end
	M.open(base_path, this_note)
end

-- Base tables are decorations, never buffer text: rendering must not touch undo.
local render_ns = vim.api.nvim_create_namespace("kyooo8_obsidian_base")
local BLOCKS = {}
local NAV_INSTALLED = {}

local function block_row(bufnr, block)
	if block.id then
		return vim.api.nvim_buf_get_extmark_by_id(bufnr, render_ns, block.id, {})[1]
	end
	return block.row
end

local function draw_block(bufnr, block)
	local row = block_row(bufnr, block)
	if not row then
		return
	end
	local selected = block.targets[block.selected or 0]
	local virtual = {}
	for i, line in ipairs(block.lines) do
		local style = block.styles[i] or {}
		local active = selected and selected.line == i
		local function highlight(group)
			return active and { group, "Visual" } or group
		end
		local chunks = { { active and "› " or "  ", highlight("Normal") } }
		local start_col = style.start_col or 0
		local end_col = style.end_col or 0
		if start_col > 0 then
			chunks[#chunks + 1] = { line:sub(1, start_col), highlight("Normal") }
		end
		chunks[#chunks + 1] = { line:sub(start_col + 1, end_col), highlight(style.hl_group or "Normal") }
		chunks[#chunks + 1] = { line:sub(end_col + 1), highlight("Normal") }
		virtual[#virtual + 1] = chunks
	end
	block.id = vim.api.nvim_buf_set_extmark(bufnr, render_ns, row, 0, {
		id = block.id,
		virt_lines = virtual,
		virt_lines_overflow = "scroll",
	})
end

local function clear_selection(bufnr)
	for _, block in ipairs(BLOCKS[bufnr] or {}) do
		if block.selected then
			block.selected = nil
			draw_block(bufnr, block)
		end
	end
end

local function move(bufnr, direction)
	for _ = 1, vim.v.count1 do
		local row = vim.api.nvim_win_get_cursor(0)[1] - 1
		local handled = false
		for _, block in ipairs(BLOCKS[bufnr] or {}) do
			local anchor = block_row(bufnr, block)
			local next_index
			if anchor == row and block.selected then
				next_index = block.selected + direction
			elseif anchor == row and direction == 1 then
				next_index = 1
			elseif anchor == row - 1 and direction == -1 then
				next_index = #block.targets
			end
			if next_index and #block.targets > 0 then
				clear_selection(bufnr)
				if next_index >= 1 and next_index <= #block.targets then
					vim.api.nvim_win_set_cursor(0, { anchor + 1, 0 })
					block.selected = next_index
					draw_block(bufnr, block)
					handled = true
				elseif next_index == 0 then
					-- Moving up out of a table returns to its embed/source line.
					handled = true
				end
				break
			end
		end
		if not handled then
			clear_selection(bufnr)
			vim.cmd("normal! " .. (direction == 1 and "j" or "k"))
		end
	end
end

local function setup_navigation(bufnr)
	if NAV_INSTALLED[bufnr] then
		return
	end
	NAV_INSTALLED[bufnr] = true
	for key, direction in pairs({ j = 1, k = -1, ["<Down>"] = 1, ["<Up>"] = -1 }) do
		vim.keymap.set("n", key, function()
			move(bufnr, direction)
		end, { buffer = bufnr, desc = "Move through note and Base rows" })
	end
	vim.api.nvim_create_autocmd({ "CursorMoved", "InsertEnter" }, {
		buffer = bufnr,
		callback = function(ev)
			local row = vim.api.nvim_win_get_cursor(0)[1] - 1
			for _, block in ipairs(BLOCKS[bufnr] or {}) do
				if block.selected and (ev.event == "InsertEnter" or block_row(bufnr, block) ~= row) then
					block.selected = nil
					draw_block(bufnr, block)
				end
			end
		end,
	})
	vim.api.nvim_create_autocmd("BufWipeout", {
		buffer = bufnr,
		once = true,
		callback = function()
			BLOCKS[bufnr], NAV_INSTALLED[bufnr] = nil, nil
		end,
	})
end

function M.setup_cr_override(bufnr)
	vim.keymap.set("n", "<CR>", function()
		local row = vim.api.nvim_win_get_cursor(0)[1] - 1
		for _, block in ipairs(BLOCKS[bufnr] or {}) do
			local target = block.targets[block.selected or 0]
			if target and block_row(bufnr, block) == row then
				vim.cmd.edit(vim.fn.fnameescape(target.path))
				return
			end
		end
		local keys = require("obsidian.api").smart_action()
		if type(keys) == "string" then
			vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "n", false)
		end
	end, { buffer = bufnr, desc = "Open selected Base note, else Obsidian smart action" })
end

--- Refresh the display without modifying buffer contents or the native undo tree.
function M.render_buffer(bufnr)
	if not vim.api.nvim_buf_is_loaded(bufnr) then
		return
	end
	local name = vim.api.nvim_buf_get_name(bufnr)
	local is_base = name:match("%.base$") ~= nil
	if not (is_base or name:match("%.md$")) then
		return
	end
	local source = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	if not is_base and not BLOCKS[bufnr] then
		local has_embed = false
		for _, line in ipairs(source) do
			if line:match("!%[%[[^%]#]+%.base") then
				has_embed = true
				break
			end
		end
		if not has_embed then
			return
		end
	end
	if not (_G.Obsidian and _G.Obsidian.workspace) then
		pcall(function()
			require("lazy").load({ plugins = { "obsidian.nvim" } })
		end)
	end
	if not (_G.Obsidian and _G.Obsidian.workspace) or not vim.fs.relpath(vault_root(), name) then
		return
	end

	local scan, blocks
	blocks = {}
	local function add_block(row, path, view_name, this_note)
		local ok, parsed = pcall(M.load, path)
		if not ok then
			return
		end
		local block = { row = row, lines = {}, styles = {}, targets = {} }
		for _, view in ipairs(parsed.views or {}) do
			if not view_name or view_name == "" or view.name == view_name then
				scan = scan or M.scan_vault()
				local valid, rows = pcall(M.run_view, parsed, view, this_note, scan)
				if valid then
					local columns = view.order and #view.order > 0 and view.order or { "file.name" }
					local lines, styles = render_table(columns, rows)
					local offset = #block.lines
					vim.list_extend(block.lines, lines)
					vim.list_extend(block.styles, styles)
					for i, note in ipairs(rows) do
						block.targets[#block.targets + 1] = { line = offset + i + 2, path = note.path }
					end
				end
			end
		end
		if #block.lines > 0 then
			blocks[#blocks + 1] = block
		end
	end

	if is_base then
		add_block(#source - 1, name)
	else
		local ok, this_note = pcall(require("obsidian.note").from_buffer, bufnr)
		for i, line in ipairs(source) do
			local path, view = line:match("!%[%[([^%]#]+%.base)#?([^%]]*)%]%]")
			if path then
				local full = resolve_base_path(vault_root(), path)
				if full then
					add_block(i - 1, full, view, ok and this_note or nil)
				end
			end
		end
	end
	vim.api.nvim_buf_clear_namespace(bufnr, render_ns, 0, -1)
	BLOCKS[bufnr] = #blocks > 0 and blocks or nil
	for _, block in ipairs(blocks) do
		draw_block(bufnr, block)
	end
	if #blocks > 0 then
		setup_navigation(bufnr)
	end
	M.setup_cr_override(bufnr)
end

return M
