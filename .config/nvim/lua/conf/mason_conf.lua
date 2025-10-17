local M = {}

M.lsp_servers = {
	-- web / js / ts
	"ts_ls",
	"html",
	"cssls",
	"tailwindcss",
	"svelte",
	"graphql",
	"emmet_ls",
	-- lua
	"lua_ls",
	-- python
	"pyright",
	-- go
	"gopls",
	-- ruby
	"ruby_lsp",
	-- php
	"intelephense",
}
M.tools = {
	"prettier", -- prettier formatter
	"stylua", -- lua formatter
	"isort", -- python formatter
	"black", -- python formatter
	"pylint", -- python linter
	"eslint_d", -- js linter
	"golangci-lint",
	"gofumpt",
	"goimports-reviser",
	"rubocop",
	"php-cs-fixer",
	"phpstan",
}

return M
