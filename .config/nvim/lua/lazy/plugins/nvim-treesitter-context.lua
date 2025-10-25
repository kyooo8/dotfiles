return {
	"nvim-treesitter/nvim-treesitter-context",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		require("treesitter-context").setup({
			enable = true, -- 有効化
			max_lines = 3, -- 固定表示する最大行数
			min_window_height = 10, -- 小さいウィンドウでは無効化
			multiline_threshold = 20, -- 長すぎる場合にまとめる
			trim_scope = "outer", -- スコープが多い場合の省略方法
			mode = "cursor", -- カーソル位置で判定（または"topline"）
			separator = nil, -- 区切り線が欲しければここに文字を指定
		})
	end,
}
