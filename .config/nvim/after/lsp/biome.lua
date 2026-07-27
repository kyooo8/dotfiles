return {
	cmd = { "biome", "lsp-proxy" },
	filetypes = {
		"javascript",
		"typescript",
		"javascriptreact",
		"typescriptreact",
		"json",
		"jsonc",
	},
	root_dir = function(bufnr, on_dir)
		local fname = vim.api.nvim_buf_get_name(bufnr)
		local found = vim.fs.find({ "biome.json", "biome.jsonc" }, { path = fname, upward = true })
		on_dir(found[1] and vim.fs.dirname(found[1]) or nil)
	end,
	workspace_required = true,
}
