local filetypes = { "html" }
local ok, html_config = pcall(require, "lspconfig.server_configurations.html")

if ok then
	filetypes = vim.deepcopy(html_config.default_config.filetypes or filetypes)
end

if not vim.tbl_contains(filetypes, "ejs") then
	table.insert(filetypes, "ejs")
end

return {
	filetypes = filetypes,
}
