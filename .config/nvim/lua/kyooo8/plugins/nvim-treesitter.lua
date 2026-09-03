local ensure_installed = {
	"json",
	"javascript",
	"typescript",
	"tsx",
	"yaml",
	"html",
	"pug",
	"slim",
	"php",
	"css",
	"scss",
	"vue",
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

return {
	"nvim-treesitter/nvim-treesitter",
	branch = "master",
	build = function()
		local treesitter = require("nvim-treesitter")
		treesitter.install(ensure_installed):wait(300000)
		treesitter.update(ensure_installed):wait(300000)
	end,
	lazy = false,
	config = function()
		local treesitter = require("nvim-treesitter")
		treesitter.setup()
		vim.treesitter.language.register("yaml", "eruby.yaml")

		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("kyooo8-treesitter", { clear = true }),
			callback = function(args)
				local has_parser = pcall(vim.treesitter.start, args.buf)
				if not has_parser then
					return
				end

				vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			end,
		})
	end,
}
