return {
	{
		"williamboman/mason-lspconfig.nvim",
		opts = {
			ensure_installed = {
				"denols",
				"ts_ls",
				"html",
				"cssls",
				"tailwindcss",
				"svelte",
				"lua_ls",
				"graphql",
				"emmet_ls",
				"prismals",
				"gopls",
				"intelephense",
				"ruby_lsp",
				"terraformls",
				"marksman",
			},
		},
	config = function(_, opts)
		local util = require("lspconfig.util")
		local function extend_filetypes(server_name, extras)
			local ok, server = pcall(require, "lspconfig.server_configurations." .. server_name)
			local defaults = ok and server.default_config and server.default_config.filetypes or {}
			local filetypes = defaults and vim.deepcopy(defaults) or {}

			for _, ft in ipairs(extras) do
				if not vim.tbl_contains(filetypes, ft) then
					table.insert(filetypes, ft)
				end
			end

			return filetypes
		end

		local deno_root = util.root_pattern(
			"deno.json",
				"deno.jsonc",
				"deno.lock",
				"import_map.json",
				"fresh.config.ts",
				"fresh.gen.ts"
			)
			local ts_root = util.root_pattern("package.json", "tsconfig.json", "jsconfig.json", ".git")

			local function is_deno_project(path)
				return deno_root(path) ~= nil
			end

			local function configure_ts(server)
				vim.lsp.config(server, {
					root_dir = function(bufnr, on_dir)
						local fname = vim.api.nvim_buf_get_name(bufnr)
						if fname == "" or is_deno_project(fname) then
							on_dir(nil)
							return
						end

						local root = ts_root(fname)
						on_dir(root)
					end,
					workspace_required = true,
					single_file_support = false,
				})
			end

			configure_ts("ts_ls")

			local tailwind_filetypes = extend_filetypes("tailwindcss", { "ejs" })

			vim.lsp.config("tailwindcss", {
				root_dir = function(bufnr, on_dir)
					local root_files = {
						"tailwind.config.js",
						"tailwind.config.cjs",
						"tailwind.config.mjs",
						"tailwind.config.ts",
						"tailwind.config.json",
						"postcss.config.js",
						"postcss.config.cjs",
						"postcss.config.mjs",
						"postcss.config.ts",
						"fresh.config.ts",
						"fresh.gen.ts",
						"deno.json",
						"deno.jsonc",
						"deno.lock",
						"import_map.json",
						".git",
					}

					local fname = vim.api.nvim_buf_get_name(bufnr)
					root_files = util.insert_package_json(root_files, "tailwindcss", fname)
					root_files =
						util.root_markers_with_field(root_files, { "mix.lock", "Gemfile.lock" }, "tailwind", fname)

					local found = vim.fs.find(root_files, { path = fname, upward = true })
					on_dir(found[1] and vim.fs.dirname(found[1]) or nil)
				end,
				filetypes = tailwind_filetypes,
				settings = {
					tailwindCSS = {
						includeLanguages = {
							ejs = "html",
						},
						experimental = {
							classRegex = {
								"tw`([^`]*)`",
								"tw\\(([^)]*)\\)",
								{ "cva\\(([^)]*)\\)", "['\"`]([^'\"`]*)['\"`]" },
							},
						},
					},
				},
				workspace_required = true,
			})
			vim.lsp.enable("tailwindcss")

			vim.lsp.config("denols", {
				root_dir = function(bufnr, on_dir)
					local fname = vim.api.nvim_buf_get_name(bufnr)
					on_dir(fname ~= "" and deno_root(fname) or nil)
				end,
				workspace_required = true,
				settings = {
					deno = {
						lint = true,
						unstable = true,
						suggest = {
							imports = {
								hosts = {
									["https://deno.land"] = true,
									["https://esm.sh"] = true,
								},
							},
						},
					},
				},
			})
			vim.lsp.enable("denols")

			require("mason-lspconfig").setup(opts)
		end,
		dependencies = {
			{
				"williamboman/mason.nvim",
				opts = {
					ui = {
						icons = {
							package_installed = "✓",
							package_pending = "➜",
							package_uninstalled = "✗",
						},
					},
				},
			},
			"neovim/nvim-lspconfig",
		},
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		opts = {
			ensure_installed = {
				"prettier",
				"stylua",
				"isort",
				"black",
				"pylint",
				"eslint_d",
				"rubocop",
				"goimports",
				"gofumpt",
				"markdownlint",
				"php-cs-fixer",
				"htmlbeautifier",
			},
		},
		dependencies = {
			"williamboman/mason.nvim",
		},
	},
}
