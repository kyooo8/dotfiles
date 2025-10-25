return {
	{
		"obsidian-nvim/obsidian.nvim",
		version = "*",
		lazy = true,
		ft = "markdown",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
		},
		opts = function()
			local uname = vim.loop.os_uname()
			local home = vim.fn.expand("~")
			local vault_path

			-- OS判定
			if uname.sysname == "Linux" and uname.release:match("Microsoft") then
				vault_path = home .. "/Shared/obsidian-vault/"
			elseif uname.sysname == "Darwin" then
				vault_path = home .. "/obsidian-vault/"
			else
				vault_path = home .. "/obsidian-vault/"
			end

			return {
				workspaces = {
					{
						name = "MyVault",
						path = vault_path,
					},
				},
				completion = { nvim_cmp = true },
				picker = { name = "telescope.nvim" },
			}
		end,
	},
}
