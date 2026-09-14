vim.filetype.add({
	extension = {
		slim = "slim",
	},
})

vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained", "CursorHold", "CursorHoldI", "WinEnter" }, {
	pattern = "*",
	callback = function()
		if vim.fn.mode() ~= "c" then
			vim.cmd.checktime()
		end
	end,
	desc = "Auto reload if file changed",
})

vim.api.nvim_create_autocmd("Filetype", {
	pattern = "*",
	callback = function()
		vim.opt_local.formatoptions:remove({ "c", "r", "o" })
	end,
	desc = "Disable comment continuation",
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "markdown", "text", "gitcommit" },
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.linebreak = false
		vim.opt_local.breakindent = true
		vim.opt_local.breakindentopt = "list:-1,min:40"
		vim.opt_local.showbreak = ""
	end,
	desc = "Wrap prose at word boundaries",
})
