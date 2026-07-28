return {
	"echasnovski/mini.surround",
	version = "*",
	event = "VeryLazy",
	enabled = true,
	opts = {
		n_lines = 100,
		mappings = {
			add = "sa", -- Add surrounding in Normal and Visual modes
			delete = "sd", -- Delete surrounding
			find = "sf", -- Find surrounding (to the right)
			find_left = "sb", -- Find surrounding (to the left)
			highlight = "", -- Highlight surrounding
			replace = "sr", -- Replace surrounding
			update_n_lines = "sv", -- Update `n_lines`
			suffix_last = "l", -- Suffix to search with "prev" method
			suffix_next = "n", -- Suffix to search with "next" method
		},
	},
	config = function(_, opts)
		require("mini.surround").setup(opts)
	end,
}
