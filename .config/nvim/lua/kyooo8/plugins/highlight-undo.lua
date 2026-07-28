return {
	"tzachar/highlight-undo.nvim",
	opts = {
		hlgroup = "HighlightUndo",
		duration = 300,
		pattern = { "*" },
		ignored_filetypes = { "neo-tree", "fugitive", "fzf", "mason", "lazy" },
	},
}
