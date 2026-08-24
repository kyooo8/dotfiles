return {
	"dhruvasagar/vim-table-mode",
	ft = "markdown",
	cmd = "TableModeToggle",
	init = function()
		vim.g.table_mode_tableize_map = "<leader>tz"
	end,
}
