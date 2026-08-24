return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	build = ":TSUpdate",
	event = { "BufReadPost", "BufNewFile" },
	config = function()
		local treesitter = require("nvim-treesitter")
		treesitter.setup()
		vim.treesitter.language.register("yaml", "eruby.yaml")

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

		local function start_treesitter(buf)
			local filetype = vim.bo[buf].filetype
			if filetype == "" then
				return
			end

			local lang = vim.treesitter.language.get_lang(filetype) or filetype

			-- auto_install相当: 未インストールの言語を検出時にインストールする
			if
				vim.tbl_contains(treesitter.get_available(), lang) and not vim.tbl_contains(treesitter.get_installed(), lang)
			then
				treesitter.install(lang):wait(60000)
			end

			-- highlightの有効化
			pcall(vim.treesitter.start, buf)
			-- indentの有効化
			vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
		end

		vim.api.nvim_create_autocmd("FileType", {
			callback = function(args)
				start_treesitter(args.buf)
			end,
		})

		start_treesitter(vim.api.nvim_get_current_buf())
	end,
}
