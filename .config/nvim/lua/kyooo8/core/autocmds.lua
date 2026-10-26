vim.filetype.add({
	extension = {
		slim = "slim",
		base = "yaml", -- Obsidian Bases file; see ObsidianBaseView for rendering
	},
})

vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained", "CursorHold", "CursorHoldI", "WinEnter" }, {
	pattern = "*",
	callback = function()
		if vim.fn.mode() ~= "c" then
			vim.cmd.checktime()
		end
	end,
	desc = "Auto reload if file changed",
})

-- tmux/tuiosの別paneでAI等が書き換えた場合、フォーカス移動イベントが
-- 発火しないままnvim側が気づかないケースがあるため、タイマーでも定期確認する
local checktime_timer = vim.uv.new_timer()
checktime_timer:start(1000, 1000, function()
	vim.schedule(function()
		if vim.fn.mode() ~= "c" then
			vim.cmd.checktime()
		end
	end)
end)

vim.api.nvim_create_autocmd("Filetype", {
	pattern = "*",
	callback = function()
		vim.opt_local.formatoptions:remove({ "c", "r", "o" })
	end,
	desc = "Disable comment continuation",
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "markdown", "text" },
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.linebreak = true
		vim.opt_local.breakindent = true
		vim.opt_local.breakindentopt = "list:-1"
	end,
	desc = "Wrap long lines at word boundaries for md/txt",
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function()
		-- required for obsidian.nvim to conceal wikilink brackets ([[note|Label]] -> Label)
		vim.opt_local.conceallevel = 2
		vim.opt_local.concealcursor = "nc"
	end,
	desc = "Conceal markup for obsidian.nvim wikilinks",
})

do
	local function render_obsidian_base(bufnr)
		vim.schedule(function()
			local ok, obsidian_base = pcall(require, "kyooo8.util.obsidian_base")
			if ok then
				pcall(obsidian_base.render_buffer, bufnr)
			end
		end)
	end

	vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave", "TextChanged" }, {
		pattern = { "*.md", "*.base" },
		callback = function(ev)
			render_obsidian_base(ev.buf)
		end,
		desc = "Auto-render Obsidian Bases embeds/views inline",
	})

	vim.api.nvim_create_autocmd("FocusGained", {
		pattern = "*",
		callback = function()
			local bufnr = vim.api.nvim_get_current_buf()
			local name = vim.api.nvim_buf_get_name(bufnr)
			if name:match("%.md$") or name:match("%.base$") then
				render_obsidian_base(bufnr)
			end
		end,
		desc = "Refresh Obsidian Bases render on focus",
	})
end
