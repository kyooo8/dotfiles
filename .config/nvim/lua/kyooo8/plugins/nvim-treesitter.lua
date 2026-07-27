return {
	"nvim-treesitter/nvim-treesitter",
	event = { "BufReadPre", "BufNewFile" },
	build = ":TSUpdate",
	config = function()
		local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
		parser_config.norg_meta = {
			install_info = {
				url = "https://github.com/nvim-neorg/tree-sitter-norg-meta",
				files = { "src/parser.c" },
				branch = "main",
			},
		}

		-- import nvim-treesitter plugin
		local treesitter = require("nvim-treesitter.configs")

		-- configure treesitter
		treesitter.setup({ -- enable syntax highlighting
			modules = {},
			sync_install = false,
			ignore_install = {},
			auto_install = true,
			highlight = {
				enable = true,
			},
			-- enable indentation
			indent = { enable = true },
			-- ensure these language parsers are installed
			ensure_installed = {
				"json",
				"javascript",
				"typescript",
				"tsx",
				"yaml",
				"html",
				"php",
				"css",
				"prisma",
				"markdown",
				"markdown_inline",
				"svelte",
				"graphql",
				"bash",
				"lua",
				"vim",
				"dockerfile",
				"gitignore",
				"query",
				"vimdoc",
				"c",
				"norg",
			},
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<C-CR>",
					node_incremental = "<C-CR>",
					scope_incremental = false,
					node_decremental = "<bs>",
				},
			},
		})

		vim.treesitter.language.register("html", "ejs")
	end,
}
