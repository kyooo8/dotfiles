return {
	"HiPhish/rainbow-delimiters.nvim",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
	},
	init = function()
		vim.g.rainbow_delimiters = {
			highlight = {
				"RainbowDelimiterYellow",
				"RainbowDelimiterBlue",
				"RainbowDelimiterOrange",
				"RainbowDelimiterGreen",
				"RainbowDelimiterViolet",
				"RainbowDelimiterCyan",
			},
		}
	end,
}
