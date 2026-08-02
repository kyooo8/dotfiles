return {
	cmd = function(dispatchers, config)
		return vim.lsp.rpc.start(
			{ vim.fn.expand("~/.local/share/mise/shims/ruby-lsp") },
			dispatchers,
			config and config.root_dir and { cwd = config.cmd_cwd or config.root_dir }
		)
	end,
	init_options = {
		formatter = "none",
		linters = { "rubocop" },
	},
	on_attach = function(client)
		client.server_capabilities.documentFormattingProvider = false
		client.server_capabilities.documentRangeFormattingProvider = false
	end,
}
