local M = {}

local wezterm = "/mnt/c/Program Files/WezTerm/wezterm.exe"

local function get_pane_id()
	if vim.env.WEZTERM_PANE then
		return vim.env.WEZTERM_PANE
	end

	local result = vim.system({ wezterm, "cli", "list", "--format", "json" }, { text = true }):wait()
	if result.code ~= 0 then
		return nil, "Failed to get WezTerm panes"
	end

	local panes = vim.json.decode(result.stdout)
	local buffer_name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t")

	if buffer_name ~= "" then
		for _, pane in ipairs(panes) do
			if pane.title and pane.title:find(buffer_name, 1, true) then
				return tostring(pane.pane_id)
			end
		end
	end

	for _, pane in ipairs(panes) do
		if pane.title and pane.title:match("NvimTree") then
			return tostring(pane.pane_id)
		end
	end

	return nil, "Could not find the current WezTerm pane"
end

function M.preview(path)
	if vim.fn.filereadable(path) ~= 1 then
		vim.notify("Image not found: " .. path, vim.log.levels.ERROR)
		return
	end

	local pane_id, pane_error = get_pane_id()
	if not pane_id then
		vim.notify(pane_error, vim.log.levels.ERROR)
		return
	end

	local windows_path = vim.fn.system({ "wslpath", "-w", path }):gsub("%s+$", "")
	if vim.v.shell_error ~= 0 or windows_path == "" then
		vim.notify("Failed to convert image path for WezTerm", vim.log.levels.ERROR)
		return
	end

	local result = vim.system({
		wezterm,
		"cli",
		"split-pane",
		"--pane-id",
		pane_id,
		"--right",
		"--percent",
		"40",
		"--",
		wezterm,
		"imgcat",
		"--hold",
		windows_path,
	}, { text = true }):wait()

	if result.code ~= 0 then
		vim.notify("WezTerm image preview failed: " .. result.stderr, vim.log.levels.ERROR)
	end
end

return M
