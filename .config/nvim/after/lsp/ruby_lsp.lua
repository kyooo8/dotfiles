return {
	init_options = {
		formatter = "none",
		linters = { "rubocop" },
	},
	on_attach = function(client)
		client.server_capabilities.documentFormattingProvider = false
		client.server_capabilities.documentRangeFormattingProvider = false
	end,
}
