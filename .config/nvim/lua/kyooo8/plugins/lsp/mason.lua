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
				"emmet_ls",
				"prismals",
				"gopls",
				"intelephense",
				"terraformls",
				"marksman",
			},
		},
		config = function(_, opts)
			require("mason-lspconfig").setup(opts)
			vim.lsp.enable("biome")
			vim.lsp.enable("ruby_lsp")
			vim.lsp.enable("rubocop")
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
				"goimports",
				"gofumpt",
				"markdownlint",
				"php-cs-fixer",
				"htmlbeautifier",
				"biome",
				"typescript-language-server",
			},
		},
		dependencies = {
			"williamboman/mason.nvim",
		},
	},
}
