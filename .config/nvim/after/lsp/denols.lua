local util = require("lspconfig.util")

local deno_root =
	util.root_pattern("deno.json", "deno.jsonc", "deno.lock", "import_map.json", "fresh.config.ts", "fresh.gen.ts")
local node_root = util.root_pattern("package.json", "tsconfig.json", "jsconfig.json")

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
		return nil
	end

	return root
end

return {
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
}
