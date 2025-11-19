return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	init = function()
		vim.o.timeout = true
		vim.o.timeoutlen = 500
	end,
	opts = {
		spec = {
			{ "<leader>t", group = "tabs,terminal" },
			{ "<leader>e", group = "explorer" },
			{ "<leader>f", group = "finds" },
			{ "<leader>s", group = "split window" },
			{ "<leader>w", group = "session" },
			{ "<leader>x", group = "trouble" },
			{ "<leader>c", group = "code" },
			{ "<leader>m", group = "format" },
			{ "<leader>n", group = "highlight" },
			{ "<leader>l", group = "lazy Git" },
		},
	},
}
