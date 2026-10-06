return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")

		local project = require("kyooo8.util.project")

		local function executable_path(name)
			local path = vim.fn.exepath(name)
			if path ~= "" then
				return path
			end

			local mason_path = vim.fn.stdpath("data") .. "/mason/bin/" .. name
			if vim.fn.executable(mason_path) == 1 then
				return mason_path
			end

			return nil
		end

		local function executable_linter(name)
			local path = executable_path(name)
			if path == nil then
				return {}
			end

			lint.linters[name].cmd = path
			return { name }
		end

		lint.linters_by_ft = {
			javascript = {},
			typescript = {},
			javascriptreact = {},
			typescriptreact = {},
			vue = {},
			svelte = executable_linter("eslint_d"),
			python = executable_linter("pylint"),
		}

		local js_filetypes = {
			javascript = true,
			typescript = true,
			javascriptreact = true,
			typescriptreact = true,
			vue = true,
		}

		local function try_lint()
			if not js_filetypes[vim.bo.filetype] then
				lint.try_lint()
				return
			end

			local filename = vim.api.nvim_buf_get_name(0)
			if filename == "" then
				return
			end
			local deno_root = project.deno_root(filename)
			local biome_root = vim.fs.root(filename, { "biome.json", "biome.jsonc" })
			if biome_root and (not deno_root or #biome_root >= #deno_root) then
				return -- biome LSP handles diagnostics
			end

			if deno_root then
				return -- denols handles lint diagnostics, including unsaved changes
			end

			lint.try_lint(executable_linter("eslint_d"))
		end

		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			group = lint_augroup,
			callback = function()
				try_lint()
			end,
		})

		vim.keymap.set("n", "<leader>ll", function()
			try_lint()
		end, { desc = "Trigger linting for current file" })
	end,
}
