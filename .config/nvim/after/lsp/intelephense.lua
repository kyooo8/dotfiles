local function detect_wp_project()
  if vim.g.wp_project ~= nil then
    return vim.g.wp_project == true
  end
  local cwd = vim.fn.getcwd()
  local composer_path = cwd .. "/composer.json"
  if vim.fn.filereadable(composer_path) == 1 then
    local ok, lines = pcall(vim.fn.readfile, composer_path)
    if ok then
      local contents = table.concat(lines, "\n")
      if contents:find("wp%-coding%-standards/wpcs") then
        return true
      end
    end
  end
  local phpcs_files = { "/phpcs.xml", "/phpcs.xml.dist" }
  for _, suffix in ipairs(phpcs_files) do
    local path = cwd .. suffix
    if vim.fn.filereadable(path) == 1 then
      local ok, lines = pcall(vim.fn.readfile, path)
      if ok then
        local contents = table.concat(lines, "\n")
        if contents:find("WordPress") then
          return true
        end
      end
    end
  end
  return false
end

local is_wp = detect_wp_project()

return {
	on_attach = function(client, bufnr)
		-- フォーマット機能を完全に無効化
		client.server_capabilities.documentFormattingProvider = false
		client.server_capabilities.documentRangeFormattingProvider = false
		client.server_capabilities.documentFormatting = false
		client.server_capabilities.documentRangeFormatting = false

		-- 保存時に didSave 通知を送信（intelephenseが必要とする挙動）
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
