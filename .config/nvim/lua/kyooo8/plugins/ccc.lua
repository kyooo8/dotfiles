return {
	"uga-rosa/ccc.nvim",
	event = "VeryLazy",
	keys = {
		{ "<leader>cp", "<cmd>CccPick<CR>", desc = "Color picker" },
		{
			"<leader>ch",
			function()
				local bufnr = vim.api.nvim_get_current_buf()
				local lsp_enabled = vim.lsp.document_color.is_enabled({ bufnr = bufnr })
				local ccc_highlighter = require("ccc.highlighter")
				local ccc_enabled = ccc_highlighter.attached_buffer[bufnr] == true
				local enable = not (lsp_enabled or ccc_enabled)

				vim.lsp.document_color.enable(enable, { bufnr = bufnr })

				if enable then
					ccc_highlighter:enable(bufnr)
				else
					ccc_highlighter:disable(bufnr)
				end
			end,
			desc = "Toggle color highlight",
		},
	},
	config = function()
		require("ccc").setup()
		vim.keymap.set("i", "<C-c>", "<Plug>(ccc-insert)", { desc = "Insert color code" })
	end,
}
