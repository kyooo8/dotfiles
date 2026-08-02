return {
	"folke/noice.nvim",
	lazy = false,
	dependencies = {
		"MunifTanjim/nui.nvim",
		"rcarriga/nvim-notify",
	},
	config = function()
		require("notify").setup({
			background_colour = "#000000",
			top_down = false,
			position = "bottom_right",
		})
		require("noice").setup({
			-- 通知をすべて右下に統一（snacks ではなく nvim-notify のみ使用）
			views = {
				notify = {
					backend = "notify",
				},
			},

			cmdline = {
				-- `:` コマンドラインのみ中央に表示する（`/` `?` 検索は bottom_search プリセットで下部表示のまま）
				format = {
					cmdline = {
						opts = {
							position = {
								row = "50%",
								col = "50%",
							},
						},
					},
				},
			},
			lsp = {
				-- override markdown rendering so that **cmp** and other plugins use **Treesitter**
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
				},
			},
			-- you can enable a preset for easier configuration
			presets = {
				bottom_search = true, -- use a classic bottom cmdline for search
				command_palette = false, -- position the cmdline and popupmenu together
				long_message_to_split = true, -- long messages will be sent to a split
				inc_rename = false, -- enables an input dialog for inc-rename.nvim
				lsp_doc_border = false, -- add a border to hover docs and signature help
			},
		})

		-- `:Noice last` と同じ仕組み(noice.message.manager)で直近のメッセージを取得する。
		-- vim.notify由来の通知だけでなく、Ctrl-gのようなecho系メッセージも対象になる。
		vim.keymap.set("n", "<leader>ny", function()
			local manager = require("noice.message.manager")
			local messages = manager.get(nil, { history = true, sort = true })
			local last = messages[#messages]
			if not last then
				vim.notify("No notifications yet", vim.log.levels.WARN)
				return
			end

			vim.fn.setreg("+", last:content())
			vim.notify("Copied last message to clipboard", vim.log.levels.INFO)
		end, { desc = "Copy last notification/message text" })
	end,
}
