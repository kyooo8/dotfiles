return {
	cmd = function(dispatchers, config)
		return vim.lsp.rpc.start(
			{ vim.fn.expand("~/.local/share/mise/shims/rubocop"), "--lsp" },
			dispatchers,
			config and config.root_dir and { cwd = config.root_dir }
		)
	end,
}
