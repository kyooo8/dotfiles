return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },

	config = function()
		local conform = require("conform")
		local util = require("conform.util")

		local project = require("lazy.util.project")

		local is_biome = project.is_biome()
		local is_deno = not is_biome and project.is_deno()
		local is_wp = project.is_wordpress()

		local php_cs_fixer = require("conform.formatters.php_cs_fixer")
		local formatters = {
			phpcsfixer = vim.tbl_extend("force", php_cs_fixer, {
				command = util.find_executable({
					"vendor/bin/php-cs-fixer",
				}, "php-cs-fixer"),
				args = util.extend_args(php_cs_fixer.args, {
					"--using-cache=no",
					"--allow-unsupported-php-version=yes",
				}, { append = true }),
			}),
		}

		if is_wp then
			local phpcbf = require("conform.formatters.phpcbf")
			formatters.phpcbf_wordpress = vim.tbl_extend("force", phpcbf, {
				command = util.find_executable({
					"vendor/bin/phpcbf",
				}, "phpcbf"),
				args = { "--standard=WordPress", "$FILENAME" },
			})
		end

		local prettier = require("conform.formatters.prettier")

		formatters.prettier_markdown = vim.tbl_extend("force", prettier, {
			args = util.extend_args(prettier.args, { "--tab-width", "4" }, { append = true }),
		})

		local formatters_by_ft = {
			javascript = { "prettier" },
			typescript = { "prettier" },
			javascriptreact = { "prettier" },
			typescriptreact = { "prettier" },
			svelte = { "prettier" },
			css = { "prettier" },
			html = { "prettier" },
			json = { "prettier" },
			yaml = { "prettier" },
			markdown = { "prettier_markdown" },
			graphql = { "prettier" },
			liquid = { "prettier" },
			lua = { "stylua" },
			python = { "isort", "black" },
			ruby = { "rubocop" },
			eruby = { "htmlbeautifier" },
			ejs = { "htmlbeautifier" },
			go = { "gofmt", "goimports" },
			terraform = { "terraform_fmt" },
		}

		formatters_by_ft.php = is_wp and { "phpcbf_wordpress", "phpcsfixer" } or { "phpcsfixer" }

		if is_biome then
			local biome_targets = {
				"javascript",
				"typescript",
				"javascriptreact",
				"typescriptreact",
				"json",
				"jsonc",
			}

			for _, ft in ipairs(biome_targets) do
				formatters_by_ft[ft] = { "biome" }
			end
		elseif is_deno then
			local deno_targets = {
				"javascript",
				"typescript",
				"javascriptreact",
				"typescriptreact",
				"json",
				"jsonc",
			}

			for _, ft in ipairs(deno_targets) do
				formatters_by_ft[ft] = { "deno_fmt" }
			end
		end

		conform.setup({
			formatters = formatters,
			formatters_by_ft = formatters_by_ft,

			format_on_save = {
				lsp_fallback = true,
				async = false,
				timeout_ms = 1000,
			},
		})

		vim.keymap.set({ "n", "v" }, "<leader>mp", function()
			conform.format({
				lsp_fallback = true,
				async = false,
				timeout_ms = 1000,
			})
		end, { desc = "Format file or range (in visual mode)" })
	end,
}
