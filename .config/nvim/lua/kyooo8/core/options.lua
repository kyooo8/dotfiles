-- 基本設定
vim.cmd("language ja_JP.UTF-8")

local opt = vim.opt
-- 行番号関連
opt.number = true
opt.relativenumber = true

-- インデント・タブ設定
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true

-- 検索/置換
opt.ignorecase = true
opt.smartcase = true

-- UI / 表示
opt.title = true
opt.cursorline = true
opt.termguicolors = true
opt.signcolumn = "yes"
opt.visualbell = true
opt.showmatch = true
opt.scrolloff = 8

-- 操作性 / 便利設定
opt.backspace = "indent,eol,start"
opt.clipboard:append("unnamedplus")

-- ウィンドウ分割関連
opt.splitright = true
opt.splitbelow = true

-- ファイル
opt.swapfile = false
opt.autoread = true
opt.fileencoding = "utf-8"
opt.fixendofline = true
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*",
	callback = function()
		require("kyooo8.util.buffer").trim_trailing_blank_lines(vim.api.nvim_get_current_buf())
	end,
})

-- TODO: これ使ってるか調べる
opt.exrc = true
opt.secure = true

-- メニューとコマンド
opt.laststatus = 3
