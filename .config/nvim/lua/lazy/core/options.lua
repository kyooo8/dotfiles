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
opt.visualbell = true
opt.showmatch = true
opt.list = true
opt.listchars = {
	space = "·",
	tab = "┊ ",
	trail = "·",
	eol = "↴",
}

-- 操作性 / 便利設定
opt.backspace = "indent,eol,start"
opt.clipboard:append("unnamedplus")

-- ウィンドウ分割関連
opt.splitright = true
opt.splitbelow = true

-- ファイル
opt.swapfile = false
opt.fileencoding = "utf-8"
opt.fixendofline = true
-- 最後の改行が一行になるように変更
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*",
	callback = function()
		local buf = vim.api.nvim_get_current_buf()
		local last = vim.api.nvim_buf_line_count(buf)

		while last > 1 do
			local line = vim.api.nvim_buf_get_lines(buf, last - 1, last, false)[1]
			if line ~= "" then
				break
			end
			last = last - 1
		end
		vim.api.nvim_buf_set_lines(buf, last, -1, false, {})
	end,
})
opt.exrc = true
opt.secure = true

-- メニューとコマンド
opt.wildmenu = true
opt.cmdheight = 1
opt.laststatus = 3
opt.showcmd = true
