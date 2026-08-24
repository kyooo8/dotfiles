return {
	{
		"williamboman/mason-lspconfig.nvim",
		cmd = {
			"LspInstall",
			"LspUninstall",
		},
		opts = {
			ensure_installed = {
				"denols",
				"html",
				"cssls",
				"tailwindcss",
				"svelte",
				"vue_ls",
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
		end,
		dependencies = {
			{
				"williamboman/mason.nvim",
				cmd = {
					"Mason",
					"MasonInstall",
					"MasonUninstall",
					"MasonUpdate",
					"MasonLog",
				},
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
		cmd = {
			"MasonToolsInstall",
			"MasonToolsUpdate",
			"MasonToolsClean",
		},
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
				"vue-language-server",
				"tailwindcss-language-server",
			},
		},
		dependencies = {
			"williamboman/mason.nvim",
		},
	},
}
