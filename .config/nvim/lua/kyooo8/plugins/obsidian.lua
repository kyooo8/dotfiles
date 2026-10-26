return {
	"obsidian-nvim/obsidian.nvim",
	version = "*",
	ft = "markdown",
	keys = {
		{ "<leader>ot", "<cmd>Obsidian new_from_template<cr>", desc = "Obsidian: new note from template" },
		{ "<leader>oT", "<cmd>Obsidian template<cr>", desc = "Obsidian: insert template" },
	},
	---@module 'obsidian'
	---@type obsidian.config
	opts = {
		legacy_commands = false,
		templates = {
			folder = "Templates",
		},
		workspaces = {
			{
				name = "vault",
				path = "~/dev/obsidian-vault",
			},
		},
		picker = {
			name = "snacks.picker",
		},
		-- match the vault's Tasks plugin core statuses (Todo <-> Done);
		-- In Progress ("/") and Cancelled ("-") are set via obsidian-tasks.nvim commands instead
		checkbox = {
			order = { " ", "x" },
		},
		callbacks = {
			-- bullets.vim also claims normal-mode <CR> on markdown buffers (see bullets.lua);
			-- re-set it here so obsidian's smart_action (link follow / checkbox / fold) wins
			-- inside the vault regardless of plugin load order.
			enter_note = function()
				-- Restore Base row jumps whenever obsidian.nvim resets <CR>.
				require("kyooo8.util.obsidian_base").setup_cr_override(vim.api.nvim_get_current_buf())
			end,
		},
	},
}
