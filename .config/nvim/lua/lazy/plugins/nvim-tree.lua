return {
	"nvim-tree/nvim-tree.lua",
	dependencies = "nvim-tree/nvim-web-devicons",
	config = function()
		local nvimtree = require("nvim-tree")

		-- recommended settings from nvim-tree documentation
		vim.g.loaded_netrw = 1
		vim.g.loaded_netrwPlugin = 1

		nvimtree.setup({
			view = {
				side = "right",
				width = 60,
				relativenumber = true,
			},
			-- change folder arrow icons
			renderer = {
				indent_markers = {
					enable = true,
				},
				icons = {
					glyphs = {
						folder = {
							arrow_closed = "", -- arrow when folder is closed
							arrow_open = "", -- arrow when folder is open
						},
					},
				},
			},
			-- disable window_picker for
			-- explorer to work well with
			-- window splits
			actions = {
				open_file = {
					window_picker = {
						enable = false,
					},
					quit_on_open = true,
				},
			},
			on_attach = function(bufnr)
				local api = require("nvim-tree.api")

				local function opts(desc)
					return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
				end

				-- デフォルトマッピング
				api.config.mappings.default_on_attach(bufnr)

				-- カスタムマッピング
				vim.keymap.set("n", "v", api.node.open.vertical, opts("Open: Vertical Split"))
				vim.keymap.set("n", "s", api.node.open.horizontal, opts("Open: Horizontal Split"))
				vim.keymap.set("n", "t", api.node.open.tab, opts("Open: New Tab"))
			end,

			filters = {
				custom = { ".DS_Store" },
			},
			git = {
				ignore = false,
			},
		})
		-- set keymaps
		local keymap = vim.keymap -- for conciseness

		keymap.set("n", "<leader>ee", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" }) -- toggle file explorer
		keymap.set(
			"n",
			"<leader>ef",
			"<cmd>NvimTreeFindFileToggle<CR>",
			{ desc = "Toggle file explorer on current file" }
		) -- toggle file explorer on current file
		keymap.set("n", "<leader>ec", "<cmd>NvimTreeCollapse<CR>", { desc = "Collapse file explorer" }) -- collapse file explorer
		keymap.set("n", "<leader>er", "<cmd>NvimTreeRefresh<CR>", { desc = "Refresh file explorer" }) -- refresh file explorer
	end,
}
