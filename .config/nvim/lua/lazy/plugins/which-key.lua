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
			{ "<leader>h", group = "Git Hunks" },
			{ "<leader>w", group = "Workspace" },
			{ "<leader>l", group = "Lazy" },
			{ "<leader>n", group = "Neorg" },
			{ "<leader>nj", group = "Journal" },
			{ "<leader>nf", group = "Files" },
			{ "<leader>ne", group = "Export" },
			{ "<leader>z", group = "Zen Mode" },
			{ "<leader>c", group = "Color" },
			{ "<leader>x", group = "Trouble" },
			{ "<leader>m", group = "Format" },
			{ "<leader>o", group = "Oil" },
		})
	end,
}
