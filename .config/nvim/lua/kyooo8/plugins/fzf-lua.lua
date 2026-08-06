local function dirs_cmd()
	if vim.fn.executable("fd") == 1 then
		return "printf '.\n'; fd --color=never --type d --hidden --exclude .git --exclude .jj"
	end

	return "find . -type d -not -path '*/.git/*' -not -path '*/.jj/*' -print | sed 's#^./##'"
end

local function pick_dir(prompt, on_select)
	require("fzf-lua").fzf_exec(dirs_cmd(), {
		prompt = prompt,
		actions = {
			["default"] = function(selected)
				local dir = selected[1]
				if not dir or dir == "" then
					return
				end

				on_select(vim.fs.normalize(dir))
			end,
		},
	})
end

local function files_in_selected_dir()
	pick_dir("Files dir> ", function(dir)
		require("fzf-lua").files({ cwd = dir })
	end)
end

local function grep_in_selected_dir()
	pick_dir("Grep dir> ", function(dir)
		require("fzf-lua").live_grep({ cwd = dir })
	end)
end

local function todos_in_selected_dir()
	pick_dir("Todos dir> ", function(dir)
		require("todo-comments.fzf").todo({ cwd = dir })
	end)
end

return {
	"ibhagwan/fzf-lua",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = {
		buffers = {
			formatter = "path.filename_first",
			path_shorten = 3,
			winopts = { height = 0.95, width = 0.95 },
		},
	},
	keys = {
		{ "<leader>ff", function() require("fzf-lua").files() end, desc = "Fuzzy find files in cwd" },
		{ "<leader>fF", files_in_selected_dir, desc = "Fuzzy find files in selected dir" },
		{ "<leader>fb", function() require("fzf-lua").buffers() end, desc = "Fuzzy find open buffers" },
		{ "<leader>fr", function() require("fzf-lua").oldfiles() end, desc = "Fuzzy find recent files" },
		{ "<leader>fs", function() require("fzf-lua").live_grep() end, desc = "Find string in cwd" },
		{ "<leader>fS", grep_in_selected_dir, desc = "Find string in selected dir" },
		{ "<leader>fc", function() require("fzf-lua").grep_cword() end, desc = "Find string under cursor in cwd" },
		{ "<leader>ft", "<cmd>TodoFzfLua<cr>", desc = "Find todos" },
		{ "<leader>fT", todos_in_selected_dir, desc = "Find todos in selected dir" },
		{ "<leader>fd", function() require("fzf-lua").lsp_document_symbols() end, desc = "Fuzzy find symbols in current file" },
	},
}
