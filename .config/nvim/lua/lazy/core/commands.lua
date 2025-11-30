vim.api.nvim_create_user_command("Config", function()
	vim.cmd.e(vim.fn.stdpath("config"))
end, {})
