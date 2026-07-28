return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	init = function()
		vim.o.timeout = true
		vim.o.timeoutlen = 500
	end,
	config = function()
		local wk = require("which-key")
		wk.setup()
		wk.add({
			{ "<leader>f", group = "Find" },
			{ "<leader>e", group = "Explorer" },
			{ "<leader>g", group = "Git" },
			{ "<leader>w", group = "Workspace" },
			{ "<leader>l", group = "Lazy" },
			{ "<leader>z", group = "Zen Mode" },
			{ "<leader>c", group = "Color" },
			{ "<leader>x", group = "Trouble" },
			{ "<leader>m", group = "Format" },
			{ "<leader>o", group = "Oil" },
		})
	end,
}
