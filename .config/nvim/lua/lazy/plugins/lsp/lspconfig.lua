return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		{ "antosha417/nvim-lsp-file-operations", config = true },
		{ "folke/neodev.nvim", opts = {} },
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
	},
	config = function()
		local mason_lspconfig = require("mason-lspconfig")
		local cmp_nvim_lsp = require("cmp_nvim_lsp")
		local lspconfig = require("lspconfig")
		local mason_conf = require("lazy.config.mason")

		local capabilities = cmp_nvim_lsp.default_capabilities()

		-- 🔑 キーマップ設定
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspConfig", {}),
			callback = function(ev)
				local opts = { buffer = ev.buf, silent = true }
				local keymap = vim.keymap
				keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)
				keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
				keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)
				keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)
				keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)
				keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
				keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
				keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)
				keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)
				keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
				keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
				keymap.set("n", "K", vim.lsp.buf.hover, opts)
				keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)
			end,
		})

		-- ⚠️ Diagnostic のアイコン
		local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
		for type, icon in pairs(signs) do
			local hl = "DiagnosticSign" .. type
			vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
		end
		-- Mason LSP Config をセットアップ
		mason_lspconfig.setup({
			ensure_installed = mason_conf.lsp_servers,
			handlers = {
				-- デフォルトハンドラ：全サーバー共通設定
				function(server_name)
					lspconfig[server_name].setup({
						capabilities = capabilities,
					})
				end,

				-- 特殊設定: Lua LS
				["lua_ls"] = function()
					lspconfig.lua_ls.setup({
						capabilities = capabilities,
						settings = {
							Lua = {
								diagnostics = { globals = { "vim" } },
								completion = { callSnippet = "Replace" },
							},
						},
					})
				end,
			},
		})
	end,
}
