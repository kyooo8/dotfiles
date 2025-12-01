vim.g.mapleader = " "

local keymap = vim.keymap

keymap.set("i", "jk", "<Esc>", { noremap = true })
keymap.set("n", ";", ":")
keymap.set("n", ":", ";")

keymap.set({ "n", "v" }, "s", "<Nop>")

keymap.set("n", "nh", ":nohl<CR>", { desc = "Clear search highlights" })

keymap.set("n", "+", "<C-a>")
keymap.set("n", "-", "<C-x>")

keymap.set("n", "s|", "<cmd>vsplit<CR>")
keymap.set("n", "s-", "<cmd>split<CR>")
keymap.set("n", "sq", "<cmd>close<CR>")

keymap.set("n", "<tab>", "<cmd>tabn<CR>")
keymap.set("n", "<s-tab>", "<cmd>tabp<CR>")
keymap.set("n", "th", "<cmd>tabfirst<CR>")
keymap.set("n", "tj", "<cmd>tabn<CR>")
keymap.set("n", "tk", "<cmd>tabp<CR>")
keymap.set("n", "tl", "<cmd>tablast<CR>")
keymap.set("n", "tt", "<cmd>tabe .<CR>")
keymap.set("n", "tq", "<cmd>tabclose<CR>")

keymap.set("n", "s", "<Nop>")

vim.keymap.set("n", "i", function()
	return vim.fn.len(vim.fn.getline(".")) ~= 0 and "i" or '"_cc'
end, { expr = true, silent = true })
vim.keymap.set("n", "A", function()
	return vim.fn.len(vim.fn.getline(".")) ~= 0 and "A" or '"_cc'
end, { expr = true, silent = true })

keymap.set({ "n", "v" }, "x", '"_x')
keymap.set({ "n", "v" }, "X", '"_d$')
keymap.set("n", "U", "<C-r>")
keymap.set("n", "M", "%")
keymap.set("x", "p", "P")
keymap.set("x", "y", "mzy`z")

-- TODO :%sが簡単にできる設定入れたい
keymap.set("v", "<", "<gv")
keymap.set("v", ">", ">gv")
