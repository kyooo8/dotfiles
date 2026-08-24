return {
	"tzachar/highlight-undo.nvim",
	event = { "TextChanged", "TextChangedI" },
	opts = {
		hlgroup = "HighlightUndo",
		duration = 300,
		pattern = { "*" },
		ignored_filetypes = { "neo-tree", "fugitive", "fzf", "mason", "lazy" },
	},
}
