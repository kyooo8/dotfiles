-- 基本設定
vim.cmd("let g:netrw_liststyle = 3")
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
opt.cursorline = true
opt.termguicolors = true
opt.signcolumn = "yes"
opt.wrap = true
opt.visualbell = true
opt.showmatch = true

-- 操作性 / 便利設定
opt.backspace = "indent,eol,start"
opt.clipboard:append("unnamedplus")
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldenable = true
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99

-- ウィンドウ分割関連
opt.splitright = true
opt.splitbelow = true

-- ファイル
opt.swapfile = false
opt.fileencoding = "utf-8"
opt.exrc = true
opt.secure = true

-- メニューとコマンド
opt.wildmenu = true
opt.cmdheight = 1
opt.laststatus = 3
opt.showcmd = true
