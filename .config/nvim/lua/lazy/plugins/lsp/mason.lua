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

			local function get_default_filetypes(server_name)
				local filetypes = {}

				local paths = vim.api.nvim_get_runtime_file("lsp/" .. server_name .. ".lua", false)
				local config_path = paths[1]
				if config_path then
					local ok, config = pcall(dofile, config_path)
					if ok and type(config) == "table" then
						filetypes = config.filetypes or {}
					end
				end

				if vim.tbl_isempty(filetypes) then
					local ok, server = pcall(require, "lspconfig.server_configurations." .. server_name)
					if not ok then
						ok, server = pcall(require, "lspconfig.configs." .. server_name)
					end
					if ok and type(server) == "table" then
						local defaults = server.default_config and server.default_config.filetypes
						filetypes = defaults or {}
					end
				end

				return vim.deepcopy(filetypes or {})
			end

			local function extend_filetypes(server_name, extras)
				local filetypes = get_default_filetypes(server_name)

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
			local node_root = util.root_pattern("package.json", "tsconfig.json", "jsconfig.json")
			local ts_root = util.root_pattern("package.json", "tsconfig.json", "jsconfig.json", ".git")

			local function get_deno_workspace(path)
				if path == "" then
					return nil
				end

				local root = deno_root(path)
				if not root then
					return nil
				end

				local node = node_root(path)
				if node and util.path.is_descendant(root, node) then
					-- Nested Node workspace should use tsserver instead of denols.
					return nil
				end

				return root
			end

			local function is_deno_project(path)
				return get_deno_workspace(path) ~= nil
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

			local html_filetypes = extend_filetypes("html", { "ejs" })
			vim.lsp.config("html", {
				filetypes = html_filetypes,
			})
			vim.lsp.enable("html")

			local emmet_filetypes = extend_filetypes("emmet_ls", { "ejs" })
			vim.lsp.config("emmet_ls", {
				filetypes = emmet_filetypes,
			})
			vim.lsp.enable("emmet_ls")

			vim.lsp.config("tailwindcss", {
				filetypes = {
					"html",
					"css",
					"scss",
					"javascript",
					"javascriptreact",
					"typescript",
					"typescriptreact",
					"ejs",
				},
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
					on_dir(get_deno_workspace(fname))
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
