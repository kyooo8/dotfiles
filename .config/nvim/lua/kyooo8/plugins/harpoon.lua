return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local harpoon = require("harpoon")
		harpoon:setup({
			marks = {
				equals = function(a, b)
					if a == nil and b == nil then
						return true
					elseif a == nil or b == nil then
						return false
					end
					return a.value == b.value and a.context.row == b.context.row
				end,
				display = function(item)
					return string.format("%s:%d", item.value, item.context.row)
				end,
				autocmds = {},
				select = function(list_item, list, options)
					if list_item == nil then
						return
					end
					options = options or {}

					local bufnr = vim.fn.bufnr(list_item.value, true)
					if not vim.api.nvim_buf_is_loaded(bufnr) then
						vim.fn.bufload(bufnr)
						vim.api.nvim_set_option_value("buflisted", true, { buf = bufnr })
					end

					if options.vsplit then
						vim.cmd("vsplit")
					elseif options.split then
						vim.cmd("split")
					end

					vim.api.nvim_set_current_buf(bufnr)

					local lines = vim.api.nvim_buf_line_count(bufnr)
					local row = math.min(list_item.context.row or 1, lines)
					vim.api.nvim_win_set_cursor(0, { row, list_item.context.col or 0 })
				end,
			},
		})

		vim.keymap.set("n", "<leader>hh", function()
			harpoon.ui:toggle_quick_menu(harpoon:list())
		end, { desc = "Harpoon: toggle quick menu" })

		vim.keymap.set("n", "<leader>hm", function()
			harpoon.ui:toggle_quick_menu(harpoon:list("marks"))
		end, { desc = "Harpoon: toggle line marks menu" })

		vim.api.nvim_create_autocmd("FileType", {
			pattern = "harpoon",
			callback = function(args)
				vim.keymap.set("n", "|", function()
					harpoon.ui:select_menu_item({ vsplit = true })
				end, { buffer = args.buf, silent = true, desc = "Harpoon: open in vertical split" })

				vim.keymap.set("n", "_", function()
					harpoon.ui:select_menu_item({ split = true })
				end, { buffer = args.buf, silent = true, desc = "Harpoon: open in horizontal split" })
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

		vim.keymap.set("n", "<leader>hl", function()
			local list = harpoon:list("marks")
			local before = list:length()
			list:add()
			local after = list:length()
			local name = vim.fn.expand("%:t")
			local row = vim.api.nvim_win_get_cursor(0)[1]

			if after > before then
				vim.notify(
					string.format("Harpoon: marked \"%s:%d\" (%d/%d)", name, row, after, after),
					vim.log.levels.INFO,
					{ title = "Harpoon" }
				)
			else
				vim.notify(
					string.format("Harpoon: \"%s:%d\" is already marked", name, row),
					vim.log.levels.WARN,
					{ title = "Harpoon" }
				)
			end
		end, { desc = "Harpoon: mark current line" })
	end,
}
