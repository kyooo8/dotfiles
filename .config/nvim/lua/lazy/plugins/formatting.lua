return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },

	config = function()
		local conform = require("conform")
		local util = require("conform.util")

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

		local function detect_wp_project()
			if vim.g.wp_project ~= nil then
				return vim.g.wp_project == true
			end
			local cwd = vim.fn.getcwd()
			local composer_path = cwd .. "/composer.json"
			if vim.fn.filereadable(composer_path) == 1 then
				local ok, lines = pcall(vim.fn.readfile, composer_path)
				if ok then
					local contents = table.concat(lines, "\n")
					if contents:find("wp%-coding%-standards/wpcs") then
						return true
					end
				end
			end
			local phpcs_paths = { "/phpcs.xml", "/phpcs.xml.dist" }
			for _, suffix in ipairs(phpcs_paths) do
				local path = cwd .. suffix
				if vim.fn.filereadable(path) == 1 then
					local ok, lines = pcall(vim.fn.readfile, path)
					if ok then
						local contents = table.concat(lines, "\n")
						if contents:find("WordPress") then
							return true
						end
					end
				end
			end
			return false
		end

		local is_deno = detect_deno_project()
		local is_wp = detect_wp_project()

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
			markdown = { "prettier" },
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

		if is_deno then
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
