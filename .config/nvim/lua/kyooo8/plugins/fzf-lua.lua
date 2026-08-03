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
		{ "<leader>fb", function() require("fzf-lua").buffers() end, desc = "Fuzzy find open buffers" },
		{ "<leader>fr", function() require("fzf-lua").oldfiles() end, desc = "Fuzzy find recent files" },
		{ "<leader>fs", function() require("fzf-lua").live_grep() end, desc = "Find string in cwd" },
		{ "<leader>fc", function() require("fzf-lua").grep_cword() end, desc = "Find string under cursor in cwd" },
		{ "<leader>ft", "<cmd>TodoFzfLua<cr>", desc = "Find todos" },
		{ "<leader>fd", function() require("fzf-lua").lsp_document_symbols() end, desc = "Fuzzy find symbols in current file" },
	},
}
