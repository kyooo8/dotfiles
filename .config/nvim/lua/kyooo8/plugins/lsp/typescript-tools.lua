return {
	"pmizio/typescript-tools.nvim",
	ft = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" },
	dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
	opts = {
		root_dir = function(bufnr, on_dir)
			local filename = vim.api.nvim_buf_get_name(bufnr)
			if require("kyooo8.util.project").deno_root(filename) then
				return
			end

			on_dir(require("typescript-tools.utils").get_root_dir(bufnr))
		end,
	},
}
