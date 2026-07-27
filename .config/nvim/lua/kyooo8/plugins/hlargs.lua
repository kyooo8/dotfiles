return {
	"m-demare/hlargs.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		require("hlargs").setup()
	end,
}
