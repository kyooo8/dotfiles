return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local harpoon = require("harpoon")
		harpoon:setup()

		vim.keymap.set("n", "<leader>hh", function()
			harpoon.ui:toggle_quick_menu(harpoon:list())
		end, { desc = "Harpoon: toggle quick menu" })

		vim.api.nvim_create_autocmd("FileType", {
			pattern = "harpoon",
			callback = function(args)
				vim.schedule(function()
					if not vim.api.nvim_buf_is_valid(args.buf) then
						return
					end

					vim.keymap.set("n", "|", function()
						harpoon.ui:select_menu_item({ vsplit = true })
					end, { buffer = args.buf, silent = true, desc = "Harpoon: open in vertical split" })

					vim.keymap.set("n", "_", function()
						harpoon.ui:select_menu_item({ split = true })
					end, { buffer = args.buf, silent = true, desc = "Harpoon: open in horizontal split" })
				end)
			end,
		})

		vim.keymap.set("n", "<leader>hp", function()
			local list = harpoon:list()
			local before = list:length()
			list:add()
			local after = list:length()
			local name = vim.fn.expand("%:t")

			if after > before then
				vim.notify(
					string.format("Harpoon: pinned \"%s\" (%d/%d)", name, after, after),
					vim.log.levels.INFO,
					{ title = "Harpoon" }
				)
			else
				vim.notify(
					string.format("Harpoon: \"%s\" is already pinned", name),
					vim.log.levels.WARN,
					{ title = "Harpoon" }
				)
			end
		end, { desc = "Harpoon: pin file" })

	end,
}
