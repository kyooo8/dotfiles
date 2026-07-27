if vim.g.vscode then
	vim.g.mapleader = " "
	vim.opt.clipboard = "unnamedplus"
else
	require("kyooo8.core")
	require("kyooo8.lazy")
end
