vim.api.nvim_create_user_command("Config", function()
	vim.cmd.e(vim.fn.stdpath("config"))
end, {})

vim.api.nvim_create_user_command("ObsidianBaseView", function()
	require("kyooo8.util.obsidian_base").open_at_cursor()
end, { desc = "Render an Obsidian Bases (.base) table view from the cursor's .base file or ![[x.base#View]] embed" })
