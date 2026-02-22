if vim.g.vscode then
	vim.g.mapleader = " "
	vim.opt.clipboard = "unnamedplus"
else
	require("lazy.core")
	require("lazy.lazy")
end
