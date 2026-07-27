return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lint = require("lint")

    local project = require("kyooo8.util.project")

    local is_biome = project.is_biome()
    local is_deno = not is_biome and project.is_deno()

    local function js_linter()
      if is_biome then return {} end -- biome LSP handles diagnostics
      if is_deno then return { "deno" } end
      return { "eslint_d" }
    end

    lint.linters_by_ft = {
      javascript = js_linter(),
      typescript = js_linter(),
      javascriptreact = js_linter(),
      typescriptreact = js_linter(),
      svelte = { "eslint_d" },
      python = { "pylint" },
    }

    local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
      group = lint_augroup,
      callback = function()
        lint.try_lint()
      end,
    })

    vim.keymap.set("n", "<leader>l", function()
      lint.try_lint()
    end, { desc = "Trigger linting for current file" })
  end,
}
