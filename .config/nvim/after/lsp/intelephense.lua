local is_wp = require("lazy.util.project").is_wordpress()

return {
	on_attach = function(client, bufnr)
		client.server_capabilities.documentFormattingProvider = false
		client.server_capabilities.documentRangeFormattingProvider = false
		client.server_capabilities.documentFormatting = false
		client.server_capabilities.documentRangeFormatting = false

		local uri = vim.uri_from_bufnr(bufnr)
		local did_save_group = vim.api.nvim_create_augroup("IntelephenseDidSave", { clear = false })
		vim.api.nvim_clear_autocmds({ group = did_save_group, buffer = bufnr })
		vim.api.nvim_create_autocmd("BufWritePost", {
			group = did_save_group,
			buffer = bufnr,
			callback = function()
				client.notify("textDocument/didSave", { textDocument = { uri = uri } })
			end,
		})
	end,

	settings = {
		intelephense = is_wp and {
			environment = {
				includePaths = { "vendor/php-stubs/wordpress-stubs" },
			},
			stubs = {
				"wordpress",
				"bcmath",
				"bz2",
				"Core",
				"curl",
				"date",
				"dom",
				"filter",
				"gd",
				"hash",
				"iconv",
				"imap",
				"json",
				"libxml",
				"mbstring",
				"mysqli",
				"openssl",
				"pcre",
				"PDO",
				"Phar",
				"readline",
				"Reflection",
				"session",
				"SimpleXML",
				"sockets",
				"sodium",
				"standard",
				"tokenizer",
				"xml",
				"xmlreader",
				"xmlwriter",
				"zip",
				"zlib",
			},
			files = {
				maxMemory = 4096,
			},
		} or {},
	},
}
