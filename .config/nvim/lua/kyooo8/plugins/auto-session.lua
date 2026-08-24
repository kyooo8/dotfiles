return {
	"rmagatti/auto-session",
	cmd = {
		"SessionRestore",
		"SessionSave",
		"AutoSession",
	},
	keys = {
		{ "<leader>wo", "<cmd>SessionRestore<CR>", desc = "Restore session for cwd" },
		{ "<leader>ws", "<cmd>SessionSave<CR>", desc = "Save session for auto session root dir" },
		{ "<leader>wf", "<cmd>AutoSession search<CR>", desc = "Find/search saved sessions" },
	},
	config = function()
		local auto_session = require("auto-session")

		auto_session.setup({
			auto_restore_enabled = false,
			bypass_save_filetypes = { "snacks_dashboard" },
			auto_session_suppress_dirs = { "~/", "~/dev/", "~/tmp/", "~/tools/", "~/Shared/" },
		})
	end,
}
