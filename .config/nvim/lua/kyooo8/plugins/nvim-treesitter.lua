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
	-- The frozen master branch only supports Neovim 0.10/0.11.
	branch = "main",
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

		local function start_highlight(bufnr)
			if not vim.api.nvim_buf_is_loaded(bufnr) or vim.bo[bufnr].buftype ~= "" then
				return
			end
			if pcall(vim.treesitter.start, bufnr) then
				vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			end
		end

		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("kyooo8-treesitter", { clear = true }),
			callback = function(args)
				start_highlight(args.buf)
			end,
		})

		local installed = treesitter.get_installed()
		local missing = vim.tbl_filter(function(lang)
			return not vim.list_contains(installed, lang)
		end, ensure_installed)
		if #missing == 0 then
			return
		end
		if vim.fn.executable("tree-sitter") == 0 then
			vim.notify(
				"Treesitter: パーサーの自動導入には brew install tree-sitter-cli が必要です",
				vim.log.levels.WARN
			)
			return
		end

		treesitter.install(missing):await(function(err, success)
			vim.schedule(function()
				if err or not success then
					vim.notify(
						"Treesitter: パーサーの導入に失敗しました。:checkhealth nvim-treesitter を確認してください",
						vim.log.levels.WARN
					)
				end
				for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
					start_highlight(bufnr)
				end
			end)
		end)
	end,
}
