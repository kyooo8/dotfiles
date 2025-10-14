return {
	"norcalli/nvim-colorizer.lua",
	cmd = { "ColorizerToggle", "ColorizerAttachToBuffer", "ColorizerDetachFromBuffer" },
	keys = { { "<leader>uc", "<cmd>ColorizerToggle<cr>", desc = "Toggle Color Preview" } },
	config = function()
		require("colorizer").setup({
			"*", -- 全ファイルタイプで有効化
		}, {
			RGB = true, -- #RGB
			RRGGBB = true, -- #RRGGBB
			names = true, -- "Red" "Blue" とか CSS カラー名
			RRGGBBAA = true, -- #RRGGBBAA
			rgb_fn = true, -- rgb() / rgba()
			hsl_fn = true, -- hsl() / hsla()
			css = true, -- 上記 CSS 系まとめて
			mode = "background", -- "foreground" にすると文字色が変わる
		})
	end,
}
