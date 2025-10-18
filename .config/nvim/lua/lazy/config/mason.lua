local M = {}

-- LSP Servers
M.lsp_servers = {
	-- Web系
	"ts_ls",
	"html",
	"cssls",
	"tailwindcss",
	"svelte",
	"lua_ls",
	"graphql",
	"emmet_ls",
	"prismals",
	"pyright",

	-- Go
	"gopls", -- Go LSP (formatting, completion, diagnostics)

	-- PHP
	"intelephense", -- 高速で安定した PHP LSP
	-- "phpactor",   -- alternative: より軽量だが補完は限定的

	-- Ruby
	"solargraph", -- Ruby LSP (定番)
	-- "ruby_ls",  -- alternative: 新しめのRuby LSP
}

-- Formatters / Linters / Tools
M.tools = {
	-- JS / TS / Web
	"prettier", -- formatter
	"eslint_d", -- linter

	-- Lua
	"stylua", -- formatter

	-- Python
	"isort", -- import sorter
	"black", -- formatter
	"pylint", -- linter

	-- Go
	"gofumpt", -- gofmt拡張版: コードフォーマッタ
	"golangci-lint", -- go用の包括的なLinter

	-- PHP
	"php-cs-fixer", -- formatter
	"phpstan", -- 静的解析

	-- Ruby
	"rubocop", -- formatter + linter
}

return M
