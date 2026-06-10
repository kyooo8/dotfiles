return {
	"preservim/vim-markdown",
	ft = "markdown",
	dependencies = { "godlygeek/tabular" },
	config = function()
		local function find_vault_root(path)
			local dir = vim.fs.dirname(path)
			while dir and dir ~= "/" do
				if vim.uv.fs_stat(dir .. "/.obsidian") then
					return dir
				end
				dir = vim.fs.dirname(dir)
			end
		end

		local function resolve_image_path(document_path, image_path)
			image_path = image_path:gsub("|.*$", ""):gsub("#.*$", "")
			if vim.startswith(image_path, "/") then
				return image_path
			end

			local document_dir = vim.fs.dirname(document_path)
			local relative_path = vim.fs.normalize(document_dir .. "/" .. image_path)
			if vim.fn.filereadable(relative_path) == 1 then
				return relative_path
			end

			local vault_root = find_vault_root(document_path)
			if vault_root then
				local vault_path = vim.fs.normalize(vault_root .. "/" .. image_path)
				if vim.fn.filereadable(vault_path) == 1 then
					return vault_path
				end
			end

			return relative_path
		end

		local function preview_image_under_cursor()
			local line = vim.api.nvim_get_current_line()
			local image_path = line:match("!%[%[([^%]]+)%]%]") or line:match("!%b[]%(([^)]+)%)")

			if not image_path then
				vim.notify("No image link on the current line", vim.log.levels.WARN)
				return
			end

			local document_path = vim.api.nvim_buf_get_name(0)
			require("lazy.core.wezterm_image").preview(resolve_image_path(document_path, image_path))
		end

		local function attach(buf)
			vim.keymap.set("n", "<leader>ip", preview_image_under_cursor, {
				buffer = buf,
				desc = "Preview image in WezTerm",
			})
		end

		vim.api.nvim_create_user_command("MarkdownImagePreview", preview_image_under_cursor, {
			desc = "Preview image link on the current line in WezTerm",
		})

		attach(0)
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "markdown",
			callback = function(event)
				attach(event.buf)
			end,
		})
	end,
}
