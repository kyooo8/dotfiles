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
