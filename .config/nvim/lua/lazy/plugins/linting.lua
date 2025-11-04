return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lint = require("lint")

    local function detect_deno_project()
      local cwd = vim.fn.getcwd()
      local markers = {
        "/deno.json",
        "/deno.jsonc",
        "/deno.lock",
        "/import_map.json",
        "/fresh.config.ts",
        "/fresh.gen.ts",
      }

      for _, marker in ipairs(markers) do
        if vim.fn.filereadable(cwd .. marker) == 1 then
          return true
        end
      end

      return false
    end

    local is_deno = detect_deno_project()

    lint.linters_by_ft = {
      javascript = is_deno and { "deno" } or { "eslint_d" },
      typescript = is_deno and { "deno" } or { "eslint_d" },
      javascriptreact = is_deno and { "deno" } or { "eslint_d" },
      typescriptreact = is_deno and { "deno" } or { "eslint_d" },
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
