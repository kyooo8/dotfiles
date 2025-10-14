return {
	"akinsho/bufferline.nvim",
	version = "*",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
		"catppuccin/nvim", -- インストールと読み込み順の保証用
	},

	config = function()
		local bufferline = require("bufferline")
		-- ここは好きな flavour に合わせて "mocha" や "macchiato" にする
		local palette = require("catppuccin.palettes").get_palette("macchiato")

		bufferline.setup({
			options = {
				mode = "tabs",
				separator_style = "sloped",
				show_buffer_close_icons = true,
				show_close_icon = false,
			},
			highlights = require("catppuccin.special.bufferline").get_theme({
				styles = { "italic", "bold" },
				custom = {
					all = {
						fill = { bg = "#000000" },
					},
					macchiato = {
						background = { fg = palette.text },
					},
					latte = {
						background = { fg = "#000000" },
					},
				},
			}),
		})
	end,
}
