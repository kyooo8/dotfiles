return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	init = function()
		vim.o.timeout = true
		vim.o.timeoutlen = 500
	end,
	opts = {
		spec = {
			{ "<leader>t", group = "tabs" },
			{ "<leader>e", group = "explorer" },
			{ "<leader>f", group = "finds" },
			{ "<leader>s", group = "split window" },
			{ "<leader>w", group = "session" },
			{ "<leader>x", group = "trouble" },
		},
	},
}
