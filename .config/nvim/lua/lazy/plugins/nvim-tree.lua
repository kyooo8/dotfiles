return {
	"nvim-tree/nvim-tree.lua",
	dependencies = "nvim-tree/nvim-web-devicons",
	event = "VeryLazy",
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
				icons = { glyphs = {
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
						enable = true,
					},
					quit_on_open = true,
				},
			},
			on_attach = function(bufnr)
				local api = require("nvim-tree.api")
				local core = require("nvim-tree.core")
				local history = {}
				local image_extensions = {
					avif = true,
					gif = true,
					jpeg = true,
					jpg = true,
					png = true,
					webp = true,
				}
				local function opts(desc)
					return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
				end

				-- デフォルトマッピング
				api.config.mappings.default_on_attach(bufnr)

				-- カーソル下のディレクトリをルートにして履歴に追加
				local function open_dir_as_root()
					local node = api.tree.get_node_under_cursor()
					if not node or node.type ~= "directory" then
						print("Select a directory to make it root")
						return
					end

					local root = core.get_cwd()
					if root then
						table.insert(history, root)
					end

					api.tree.change_root(node.absolute_path)
				end

				-- 戻る
				local function back_dir()
					local prev = table.remove(history)
					if prev then
						api.tree.change_root(prev)
					else
						print("No previous directory")
					end
				end

				-- 親ディレクトリへ移動
				local function go_parent_dir()
					local root = core.get_cwd()
					if not root then
						print("No current root directory")
						return
					end

					local parent = vim.fn.fnamemodify(root, ":h")
					if parent == root then
						print("Already at the top directory")
						return
					end

					table.insert(history, root)
					api.tree.change_root(parent)
				end

				local function open_with_image_preview()
					local node = api.tree.get_node_under_cursor()
					local extension = node and node.extension and node.extension:lower()

					if not node or node.type ~= "file" or not image_extensions[extension] then
						api.node.open.edit()
						return
					end

					require("lazy.core.wezterm_image").preview(node.absolute_path)
				end

				-- カスタムマッピング
				vim.keymap.set("n", "<CR>", open_with_image_preview, opts("Open / Preview Image"))
				vim.keymap.set("n", "i", api.node.open.vertical, opts("Open: Vertical Split"))
				vim.keymap.set("n", "u", api.node.open.horizontal, opts("Open: Horizontal Split"))
				vim.keymap.set("n", "t", api.node.open.tab, opts("Open: New Tab"))
				vim.keymap.set("n", "b", back_dir, opts("Back: previous directory"))
				vim.keymap.set("n", "B", go_parent_dir, opts("Up: parent directory"))
				vim.keymap.set("n", "n", open_dir_as_root, opts("Next: set node as root"))
				vim.keymap.set("n", "o", api.node.run.system, opts("Run System"))
				vim.keymap.del("n", "s", { buffer = bufnr })
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
