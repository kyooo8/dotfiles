return {
	"nvim-neorg/neorg",
	lazy = false,
	version = "*",
	config = function()
		require("neorg").setup({
			load = {
				["core.defaults"] = {},
				["core.concealer"] = {},
				["core.completion"] = {
					config = {
						engine = "nvim-cmp",
					},
				},
				["core.integrations.nvim-cmp"] = {},
				["core.dirman"] = {
					config = {
						workspaces = {
							neorg = "~/neorg",
						},
						default_workspace = "neorg",
					},
				},
			},
		})

		vim.keymap.set("n", "<leader>nn", function()
			vim.cmd("Neorg workspace neorg")
		end)
		vim.keymap.set("n", "<leader>nr", function()
			vim.cmd("Neorg return")
		end)
	end,
}
