return {
	{
		"stevearc/oil.nvim",
		dependencies = {
			{ "nvim-mini/mini.icons" },
			{ "refractalize/oil-git-status.nvim" },
		},

		opts = {
			default_file_explorer = false,
			columns = { "icon", "size", "mtime" },

			view_options = {
				show_hidden = true,
			},
			win_options = {
				signcolumn = "yes:1",
			},

			keymaps = {
				["q"] = "actions.close",
				["<backspace>"] = "actions.parent",
				["|"] = { "actions.select", opts = { vertical = true } },
				["-"] = { "actions.select", opts = { horizontal = true } },
				["t"] = { "actions.select", opts = { tab = true } },
				["<C-p>"] = "actions.preview",
				["r"] = "actions.refresh",
				["?"] = "actions.show_help",
				["<CR>"] = "actions.select",
				["."] = "actions.open_cwd",
				["c"] = "actions.cd",
				["~"] = "actions.tcd",
				["g."] = "actions.toggle_hidden",
			},
			use_default_keymaps = false,
		},

		config = function(_, opts)
			require("oil").setup(opts)
			vim.keymap.set("n", "<leader>o", function()
				require("oil").open()
			end, { desc = "open oil" })
		end,
	},
}
