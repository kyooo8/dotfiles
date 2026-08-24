return {
	"pmizio/typescript-tools.nvim",
	ft = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
	dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
	opts = {
		on_attach = function(client)
			local root = client.root_dir or vim.fn.getcwd()
			if vim.fn.filereadable(root .. "/deno.json") == 1 or vim.fn.filereadable(root .. "/deno.jsonc") == 1 then
				client.stop()
			end
		end,
	},
}
