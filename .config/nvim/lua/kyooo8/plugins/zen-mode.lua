return {
	"folke/zen-mode.nvim",
	opts = {},
	config = function()
		vim.keymap.set("n", "<leader>zz", "<cmd>ZenMode<CR>", { desc = "Zen Mode" })
		vim.keymap.set("n", "<leader>zc", "<cmd>close<CR>", { desc = "Close Zen Mode" })
	end,
}
