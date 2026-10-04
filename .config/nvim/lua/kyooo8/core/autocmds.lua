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

-- tmux/tuiosの別paneでAI等が書き換えた場合、フォーカス移動イベントが
-- 発火しないままnvim側が気づかないケースがあるため、タイマーでも定期確認する
local checktime_timer = vim.uv.new_timer()
checktime_timer:start(1000, 1000, function()
	vim.schedule(function()
		if vim.fn.mode() ~= "c" then
			vim.cmd.checktime()
		end
	end)
end)

vim.api.nvim_create_autocmd("Filetype", {
	pattern = "*",
	callback = function()
		vim.opt_local.formatoptions:remove({ "c", "r", "o" })
	end,
	desc = "Disable comment continuation",
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "markdown", "text" },
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.linebreak = true
		vim.opt_local.breakindent = true
		vim.opt_local.breakindentopt = "list:-1"
	end,
	desc = "Wrap long lines at word boundaries for md/txt",
})
