return {
	"uga-rosa/ccc.nvim",
	event = "VeryLazy",
	config = function()
		require("ccc").setup()
		vim.keymap.set("n", "<leader>cp", ":CccPick<CR>", { desc = "Color picker" })
		vim.keymap.set("i", "<C-c>", "<Plug>(ccc-insert)", { desc = "Insert color code" })
		vim.keymap.set("n", "<leader>ch", ":CccHighlighterToggle<CR>", { desc = "Toggle ccc highlight" })
	end,
}
