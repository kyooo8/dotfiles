return {
	"nvim-neorg/neorg",
	build = ":Neorg sync-parsers",
	lazy = false,
	version = "*",
	config = function()
		require("neorg").setup({
			load = {
				["core.defaults"] = {},
				["core.concealer"] = {},
				["core.summary"] = {},
				["core.completion"] = {
					config = {
						engine = "nvim-cmp",
					},
				},
				["core.integrations.nvim-cmp"] = {},
				["core.dirman"] = {
					config = {
						workspaces = {
							neorg = "~/neorg",
						},
						default_workspace = "neorg",
					},
				},
				["core.presenter"] = {
					config = {
						zen_mode = "zen-mode",
					},
				},
				["core.integrations.zen_mode"] = {},
				["core.export"] = {},
				["core.export.markdown"] = {},
				["core.export.html"] = {},
				["core.text-objects"] = {},
			},
		})

		-- ワークスペースを開く
		vim.keymap.set("n", "<leader>nn", function()
			vim.cmd("Neorg workspace neorg")
		end, { desc = "Neorg open workspace" })
		vim.keymap.set("n", "<leader>ni", function()
			vim.cmd("vsplit")
			vim.cmd("Neorg workspace neorg")
		end, { desc = "Neorg vertical split" })
		vim.keymap.set("n", "<leader>nu", function()
			vim.cmd("split")
			vim.cmd("Neorg workspace neorg")
		end, { desc = "Neorg horizontal split" })
		vim.keymap.set("n", "<leader>nt", function()
			vim.cmd("tabnew")
			vim.cmd("Neorg workspace neorg")
		end, { desc = "Neorg new tab" })
		vim.keymap.set("n", "<leader>nr", function()
			vim.cmd("Neorg return")
		end, { desc = "Neorg return" })

		-- ジャーナル
		vim.keymap.set("n", "<leader>njt", function()
			vim.cmd("Neorg journal today")
		end, { desc = "Neorg journal today" })
		vim.keymap.set("n", "<leader>njy", function()
			vim.cmd("Neorg journal yesterday")
		end, { desc = "Neorg journal yesterday" })
		vim.keymap.set("n", "<leader>njm", function()
			vim.cmd("Neorg journal tomorrow")
		end, { desc = "Neorg journal tomorrow" })

		-- 日付挿入（カレンダーUI付き）
		vim.keymap.set("n", "<leader>nd", "<Plug>(neorg.tempus.insert-date)", { desc = "Neorg insert date" })
		vim.keymap.set("i", "<C-d>", "<Plug>(neorg.tempus.insert-date.insert-mode)", { desc = "Neorg insert date (insert mode)" })

		-- ドキュメント操作
		vim.keymap.set("n", "<leader>nc", function()
			vim.cmd("Neorg toc")
		end, { desc = "Neorg table of contents" })
		vim.keymap.set("n", "<leader>nm", function()
			vim.cmd("Neorg generate-metadata")
		end, { desc = "Neorg generate metadata" })
		vim.keymap.set("n", "<leader>nT", function()
			vim.cmd("Neorg tangle current-file")
		end, { desc = "Neorg tangle current file" })

		-- エクスポート
		vim.keymap.set("n", "<leader>nem", function()
			local out = vim.fn.expand("%:r") .. ".md"
			vim.cmd("Neorg export to-file " .. out)
		end, { desc = "Neorg export to markdown" })
		vim.keymap.set("n", "<leader>neh", function()
			local out = vim.fn.expand("%:r") .. ".html"
			vim.cmd("Neorg export to-file " .. out)
		end, { desc = "Neorg export to html" })

		-- プレゼンター（.norg ファイル内でのみ有効）
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "norg",
			callback = function(ev)
				vim.keymap.set("n", "<leader>np", "<cmd>Neorg presenter start<CR>", { buffer = ev.buf, desc = "Neorg presenter start" })
				vim.keymap.set("n", "<leader>nq", "<cmd>Neorg presenter close<CR>", { buffer = ev.buf, desc = "Neorg presenter close" })
				vim.keymap.set("n", "<Right>", "<Plug>(neorg.presenter.next-page)", { buffer = ev.buf, desc = "Neorg presenter next" })
				vim.keymap.set("n", "<Left>", "<Plug>(neorg.presenter.previous-page)", { buffer = ev.buf, desc = "Neorg presenter prev" })
			end,
		})
	end,
}
