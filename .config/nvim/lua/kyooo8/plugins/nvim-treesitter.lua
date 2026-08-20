return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	build = ":TSUpdate",
	lazy = false,
	config = function()
		local treesitter = require("nvim-treesitter")
		treesitter.setup()

		-- ensure these language parsers are installed
		local ensure_installed = {
			"json",
			"javascript",
			"typescript",
			"tsx",
			"yaml",
			"html",
			"php",
			"css",
			"scss",
			"prisma",
			"markdown",
			"markdown_inline",
			"svelte",
			"graphql",
			"bash",
			"lua",
			"vim",
			"dockerfile",
			"gitignore",
			"query",
			"vimdoc",
			"c",
		}
		treesitter.install(ensure_installed)

		vim.api.nvim_create_autocmd("FileType", {
			callback = function(args)
				local lang = vim.treesitter.language.get_lang(args.match) or args.match

				-- auto_install相当: 未インストールの言語を検出時にインストールする
				if
					vim.tbl_contains(treesitter.get_available(), lang)
					and not vim.tbl_contains(treesitter.get_installed(), lang)
				then
					treesitter.install(lang):wait(60000)
				end

				-- highlightの有効化
				pcall(vim.treesitter.start)
				-- indentの有効化
				vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			end,
		})
	end,
}
