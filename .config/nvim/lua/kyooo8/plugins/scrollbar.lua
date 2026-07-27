return {
	{
		"petertriho/nvim-scrollbar",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			local C = require("catppuccin.palettes").get_palette("mocha")

			require("scrollbar").setup({
				handle = {
					color = C.surface2,
				},
				marks = {
					Cursor = { color = C.surface2 }, -- カーソル位置
					Search = { color = C.yellow }, -- / 検索
					Error = { color = C.red }, -- LSP Diagnostic
					Warn = { color = C.peach },
					Info = { color = C.sky },
					Hint = { color = C.teal },
					Misc = { color = C.mauve }, -- その他
					GitAdd = { color = C.green },
					GitChange = { color = C.blue },
					GitDelete = { color = C.red },
				},
			})

			require("scrollbar.handlers.search").setup()
			require("scrollbar.handlers.gitsigns").setup()
		end,
	},

	-- search連携
	{
		"kevinhwang91/nvim-hlslens",
		event = "VeryLazy",
		config = function()
			require("hlslens").setup()
		end,
	},
}
