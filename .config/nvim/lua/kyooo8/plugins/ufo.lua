return {
	{
		"kevinhwang91/nvim-ufo",
		dependencies = "kevinhwang91/promise-async",
		event = "BufReadPost",
		config = function()
			-- UFO recommended settings
			vim.o.foldcolumn = "1"
			vim.o.foldlevel = 99
			vim.o.foldlevelstart = 99
			vim.o.foldenable = true

			require("ufo").setup({
				provider_selector = function(_, filetype)
					-- LSP > Treesitter > Indent の順に優先
					return { "treesitter", "indent" }
				end,
			})

			-- Keymaps
			vim.keymap.set("n", "zR", require("ufo").openAllFolds) -- 全展開
			vim.keymap.set("n", "zM", require("ufo").closeAllFolds) -- 全閉じ
			vim.keymap.set("n", "zr", require("ufo").openFoldsExceptKinds) -- コメント除外とかに使える
			vim.keymap.set("n", "zm", require("ufo").closeFoldsWith)

			-- Hover時にfold preview → なければLSP hover
			vim.keymap.set("n", "K", function()
				local winid = require("ufo").peekFoldedLinesUnderCursor()
				if not winid then
					vim.lsp.buf.hover()
				end
			end)

			-- 🎨 Catppuccin Mocha foldの配色
			local C = require("catppuccin.palettes").get_palette("mocha")
			vim.api.nvim_set_hl(0, "UfoFoldedBg", { bg = C.surface0 })
			vim.api.nvim_set_hl(0, "UfoFoldedFg", { fg = C.text })
			vim.api.nvim_set_hl(0, "UfoFoldedEllipsis", { fg = C.overlay2 })
		end,
	},
}
