local util = require("lspconfig.util")

return {
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
		root_files = util.root_markers_with_field(root_files, { "mix.lock", "Gemfile.lock" }, "tailwind", fname)

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
}
