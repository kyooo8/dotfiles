return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")

		local project = require("kyooo8.util.project")

		local is_biome = project.is_biome()
		local is_deno = not is_biome and project.is_deno()

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

		local function js_linter()
			if is_biome then
				return {}
			end -- biome LSP handles diagnostics
			if is_deno then
				return executable_linter("deno")
			end
			return executable_linter("eslint_d")
		end

		lint.linters_by_ft = {
			javascript = js_linter(),
			typescript = js_linter(),
			javascriptreact = js_linter(),
			typescriptreact = js_linter(),
			vue = js_linter(),
			svelte = executable_linter("eslint_d"),
			python = executable_linter("pylint"),
		}

		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			group = lint_augroup,
			callback = function()
				lint.try_lint()
			end,
		})

		vim.keymap.set("n", "<leader>ll", function()
			lint.try_lint()
		end, { desc = "Trigger linting for current file" })
	end,
}
