local function harpoon_section()
	local ok, harpoon = pcall(require, "harpoon")
	if not ok then
		return {}
	end

	local list = harpoon:list()
	local items = {}
	for i = 1, list:length() do
		local entry = list:get(i)
		if entry then
			items[#items + 1] = {
				file = entry.value,
				icon = "file",
				action = ":e " .. vim.fn.fnameescape(entry.value),
				autokey = true,
			}
		end
	end
	return items
end

local function git_section()
	if vim.fn.system("git rev-parse --is-inside-work-tree 2>/dev/null"):match("true") == nil then
		return {}
	end

	local branch = vim.fn.system("git branch --show-current 2>/dev/null"):gsub("%s+$", "")
	local dirty = vim.fn.system("git status --porcelain 2>/dev/null")
	local status = dirty == "" and "clean" or (#vim.split(dirty, "\n", { trimempty = true }) .. " changed")

	return {
		{ icon = " ", text = { { branch ~= "" and branch or "(no branch)", hl = "special" } } },
		{ icon = dirty == "" and " " or " ", text = { { status, hl = dirty == "" and "dir" or "file" } } },
	}
end

local function dirs()
	local items = { "." }

	if vim.fn.executable("fd") == 1 then
		vim.list_extend(items, vim.fn.systemlist({
			"fd",
			"--color=never",
			"--type",
			"d",
			"--hidden",
			"--exclude",
			".git",
			"--exclude",
			".jj",
		}))
		return items
	end

	local cwd = vim.uv.cwd()
	local function scan(dir)
		for name, type in vim.fs.dir(dir) do
			if type == "directory" and name ~= ".git" and name ~= ".jj" then
				local path = vim.fs.joinpath(dir, name)
				items[#items + 1] = vim.fs.relpath(cwd, path) or path
				scan(path)
			end
		end
	end

	scan(cwd)
	return items
end

local function pick_dir(prompt, on_select)
	vim.ui.select(dirs(), { prompt = prompt }, function(dir)
		if not dir or dir == "" then
			return
		end

		on_select(vim.fs.normalize(vim.fn.fnamemodify(dir, ":p")))
	end)
end

local function files_in_selected_dir()
	pick_dir("Files dir> ", function(dir)
		Snacks.picker.files({ cwd = dir })
	end)
end

local function grep_in_selected_dir()
	pick_dir("Grep dir> ", function(dir)
		Snacks.picker.grep({ cwd = dir })
	end)
end

local function todo_comments(opts)
	require("lazy").load({ plugins = { "todo-comments.nvim" } })
	Snacks.picker.sources.todo_comments = require("todo-comments.snacks").source
	Snacks.picker.pick("todo_comments", opts)
end

local function todos_in_selected_dir()
	pick_dir("Todos dir> ", function(dir)
		todo_comments({ cwd = dir })
	end)
end

local function explorer()
	Snacks.explorer()
end

local function reveal_in_explorer()
	Snacks.explorer.reveal()
end

local function close_explorer()
	local picker = Snacks.picker.get({ source = "explorer" })[1]
	if picker then
		picker:close()
	end
end

local function refresh_explorer()
	local picker = Snacks.picker.get({ source = "explorer" })[1]
	if picker then
		picker:find()
		return
	end

	Snacks.explorer()
end

return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	keys = {
		{ "<leader>d", function() Snacks.dashboard() end, desc = "Open dashboard" },
		{ "<leader>ee", explorer, desc = "Toggle file explorer" },
		{ "<leader>ef", reveal_in_explorer, desc = "Reveal current file in explorer" },
		{ "<leader>ec", close_explorer, desc = "Close file explorer" },
		{ "<leader>er", refresh_explorer, desc = "Refresh file explorer" },
		{ "<leader>ff", function() Snacks.picker.files() end, desc = "Find files in cwd" },
		{ "<leader>fF", files_in_selected_dir, desc = "Find files in selected dir" },
		{ "<leader>fb", function() Snacks.picker.buffers() end, desc = "Find open buffers" },
		{ "<leader>fr", function() Snacks.picker.recent() end, desc = "Find recent files" },
		{ "<leader>fs", function() Snacks.picker.grep() end, desc = "Find string in cwd" },
		{ "<leader>fS", grep_in_selected_dir, desc = "Find string in selected dir" },
		{ "<leader>fc", function() Snacks.picker.grep_word() end, desc = "Find word under cursor in cwd", mode = { "n", "x" } },
		{ "<leader>ft", function() todo_comments() end, desc = "Find todos" },
		{ "<leader>fT", todos_in_selected_dir, desc = "Find todos in selected dir" },
		{ "<leader>fd", function() Snacks.picker.lsp_symbols() end, desc = "Find symbols in current file" },
		{ "<leader>lg", function() Snacks.lazygit() end, desc = "Open lazy git" },
		{ "<leader>lf", function() Snacks.lazygit.log_file() end, desc = "LazyGit: current file history" },
		{ "<leader>zz", function() Snacks.zen() end, desc = "Zen Mode" },
		{ "<leader>zc", function() Snacks.zen.zoom() end, desc = "Zoom Window" },
	},
	opts = {
		explorer = {
			replace_netrw = true,
		},
		picker = {
			sources = {
				explorer = {
					hidden = true,
					ignored = true,
					exclude = { ".DS_Store" },
					jump = { close = true },
					layout = {
						preset = "sidebar",
						preview = false,
						layout = {
							position = "right",
							width = 60,
						},
					},
					win = {
						list = {
							keys = {
								["|"] = "edit_vsplit",
								["_"] = "edit_split",
								["t"] = "tab",
								["q"] = "close",
							},
						},
					},
				},
			},
		},
		input = {
			enabled = true,
		},
		scroll = {
			enabled = true,
		},
		zen = {},
		lazygit = {
			config = {
				os = { editPreset = "nvim-remote" },
			},
		},
		styles = {
			input = {
				border = "rounded",
				relative = "cursor",
				wo = {
					colorcolumn = "",
					conceallevel = 0,
					cursorline = true,
					foldenable = false,
					list = true,
					listchars = "precedes:…,extends:…",
					number = true,
					relativenumber = true,
					signcolumn = "yes",
					spell = false,
					wrap = false,
				},
			},
		},
		dashboard = {
			preset = {
				header = "⚡ kyooo8.nvim",
			},
			sections = {
				{ section = "header" },
				{ section = "keys", gap = 1, padding = 1 },
				{
					pane = 1,
					{ icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1, limit = 5 },
					{ icon = " ", title = "Harpoon", indent = 2, padding = 1, harpoon_section },
				},
				{
					pane = 2,
					{ icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1, limit = 5 },
					{ icon = " ", title = "Git", indent = 2, padding = 1, git_section },
				},
				{ section = "startup" },
			},
		},
	},
}
