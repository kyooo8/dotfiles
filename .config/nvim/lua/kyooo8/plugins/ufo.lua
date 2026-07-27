return {
	{
		"kevinhwang91/nvim-ufo",
		dependencies = "kevinhwang91/promise-async",
		event = "BufReadPost",
		config = function()
			vim.o.foldcolumn = "1"
			vim.o.foldlevel = 99
			vim.o.foldlevelstart = 99
			vim.o.foldenable = true

			require("ufo").setup({
				provider_selector = function(_, filetype)
					return { "treesitter", "indent" }
				end,
			})

			vim.keymap.set("n", "zR", require("ufo").openAllFolds)
			vim.keymap.set("n", "zM", require("ufo").closeAllFolds)
			vim.keymap.set("n", "zr", require("ufo").openFoldsExceptKinds)
			vim.keymap.set("n", "zm", require("ufo").closeFoldsWith)

			vim.keymap.set("n", "K", function()
				require("ufo").peekFoldedLinesUnderCursor()
			end)

			local C = require("catppuccin.palettes").get_palette("macchiato")
			vim.api.nvim_set_hl(0, "UfoFoldedBg", { bg = C.surface0 })
			vim.api.nvim_set_hl(0, "UfoFoldedFg", { fg = C.text })
			vim.api.nvim_set_hl(0, "UfoFoldedEllipsis", { fg = C.overlay2 })
		end,
	},
}
