return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		{ "antosha417/nvim-lsp-file-operations", config = true },
		{ "folke/lazydev.nvim", opts = {} },
	},
	config = function()
		local cmp_nvim_lsp = require("cmp_nvim_lsp")
		local capabilities = cmp_nvim_lsp.default_capabilities()

		vim.lsp.config("*", { capabilities = capabilities })

		vim.api.nvim_create_autocmd("LspAttach", {
			callback = function(ev)
				local bufnr = ev.buf

				for _, key in ipairs({ "gra", "gri", "grn", "grr", "grt" }) do
					pcall(vim.keymap.del, "n", key)
				end

				local function map(mode, lhs, rhs, desc)
					vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
				end

				map("n", "K", vim.lsp.buf.hover, "LSP Hover")
				map({ "n" }, "gh", vim.lsp.buf.signature_help, "Signature Help")

				map("n", "gd", "<CMD>Glance definitions<CR>", "Go Definition")
				map("n", "gr", "<CMD>Glance references<CR>", "Go References")
				map("n", "gR", "<CMD>LspRestart<CR>", "Restart LSP")
				map("n", "gt", "<CMD>Glance type_definitions<CR>", "Go Type Definition")
				map("n", "gi", "<CMD>Glance implementations<CR>", "Go Implementation")
				map("n", "gD", vim.lsp.buf.declaration, "Go Declaration")
				map("n", "ga", function()
					require("actions-preview").code_actions()
				end, "Code Action Preview")
				map("n", "cr", vim.lsp.buf.rename, "Rename Symbol")

				map("n", "[d", vim.diagnostic.goto_prev, "Prev Diagnostic")
				map("n", "]d", vim.diagnostic.goto_next, "Next Diagnostic")
				map("n", "gl", vim.diagnostic.open_float, "Line Diagnostic")

				map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, "Add Workspace")
				map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, "Remove Workspace")
				map("n", "<leader>wl", function()
					print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
				end, "List Workspace")
			end,
		})

		local severity = vim.diagnostic.severity
		vim.diagnostic.config({
			signs = {
				text = {
					[severity.ERROR] = " ",
					[severity.WARN] = " ",
					[severity.HINT] = " ",
					[severity.INFO] = " ",
				},
			},
		})
	end,
}
