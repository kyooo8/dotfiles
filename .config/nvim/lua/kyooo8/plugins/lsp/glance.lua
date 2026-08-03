return {
	"dnlhc/glance.nvim",
	cmd = "Glance",
	opts = function()
		local actions = require("glance").actions
		return {
			height = 30,
			border = {
				enable = true,
			},
			mappings = {
				list = {
					["|"] = actions.jump_vsplit,
					["_"] = actions.jump_split,
				},
			},
		}
	end,
}
