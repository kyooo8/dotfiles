return {
	{
		"williamboman/mason-lspconfig.nvim",
		opts = {
			ensure_installed = {
				"denols",
				"html",
				"cssls",
				"tailwindcss",
				"svelte",
				"lua_ls",
				"graphql",
				"emmet_ls",
				"prismals",
				"gopls",
				"intelephense",
				"ruby_lsp",
				"terraformls",
				"marksman",
			},
		},
		config = function(_, opts)
			require("mason-lspconfig").setup(opts)
			vim.lsp.enable("biome")
		end,
		dependencies = {
			{
				"williamboman/mason.nvim",
				opts = {
					ui = {
						icons = {
							package_installed = "✓",
							package_pending = "➜",
							package_uninstalled = "✗",
						},
					},
				},
			},
			"neovim/nvim-lspconfig",
		},
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		opts = {
			ensure_installed = {
				"prettier",
				"stylua",
				"isort",
				"black",
				"pylint",
				"eslint_d",
				"rubocop",
				"goimports",
				"gofumpt",
				"markdownlint",
				"php-cs-fixer",
				"htmlbeautifier",
				"biome",
			},
		},
		dependencies = {
			"williamboman/mason.nvim",
		},
	},
}
