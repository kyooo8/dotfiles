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
		opts = {
			workspaces = {
				{
					name = "MyVault",
					path = "~/Shared/obsidian-vault/",
				},
			},
			completion = { nvim_cmp = true },
			picker = { name = "telescope.nvim" },
		},
	},
}
