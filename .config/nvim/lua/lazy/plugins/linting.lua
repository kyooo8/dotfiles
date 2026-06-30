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

    local function detect_biome_project()
      local cwd = vim.fn.getcwd()
      return vim.fn.filereadable(cwd .. "/biome.json") == 1
        or vim.fn.filereadable(cwd .. "/biome.jsonc") == 1
    end

    local is_biome = detect_biome_project()
    local is_deno = not is_biome and detect_deno_project()

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
