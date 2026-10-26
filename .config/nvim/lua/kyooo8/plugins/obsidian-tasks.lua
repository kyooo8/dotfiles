return {
	"snapwich/obsidian-tasks.nvim",
	ft = "markdown",
	dependencies = { "obsidian-nvim/obsidian.nvim" },
	config = function()
		require("obsidian-tasks").setup({})
	end,
}
