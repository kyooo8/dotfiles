return {
	{
		"petertriho/nvim-scrollbar",
		branch = "refactor/v2", -- mainがv2化(2026-11-16予定)されたらbranch指定を外す
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			local C = require("catppuccin.palettes").get_palette("macchiato")

			require("scrollbar").setup({
				marks = {
					Cursor = { highlight = { fg = C.surface2 } }, -- カーソル位置
					Search = { highlight = { fg = C.yellow } }, -- / 検索
					Error = { highlight = { fg = C.red } }, -- LSP Diagnostic
					Warn = { highlight = { fg = C.peach } },
					Info = { highlight = { fg = C.sky } },
					Hint = { highlight = { fg = C.teal } },
					Misc = { highlight = { fg = C.mauve } }, -- その他
					GitAdd = { highlight = { fg = C.green } },
					GitChange = { highlight = { fg = C.blue } },
					GitDelete = { highlight = { fg = C.red } },
				},
				providers = {
					gitsigns = true,
				},
				scrollbar = {
					thumb = {
						highlight = { bg = C.surface2 },
					},
				},
			})
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
