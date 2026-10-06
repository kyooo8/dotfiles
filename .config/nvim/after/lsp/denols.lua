local project = require("kyooo8.util.project")

return {
	root_dir = function(bufnr, on_dir)
		local fname = vim.api.nvim_buf_get_name(bufnr)
		on_dir(project.deno_root(fname))
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
