local M = {}

local function is_wsl()
	local release = vim.uv.os_uname().release:lower()
	return release:find("microsoft", 1, true) ~= nil or release:find("wsl", 1, true) ~= nil
end

local function is_executable(command)
	return vim.fn.executable(command) == 1
end

local function find_wezterm()
	local candidates = {}

	if vim.env.WEZTERM_EXECUTABLE then
		local executable = vim.env.WEZTERM_EXECUTABLE
		if vim.fs.basename(executable) == "wezterm-gui" then
			table.insert(candidates, vim.fs.dirname(executable) .. "/wezterm")
		end

		table.insert(candidates, vim.env.WEZTERM_EXECUTABLE)
	end

	if is_wsl() then
		table.insert(candidates, "/mnt/c/Program Files/WezTerm/wezterm.exe")
	else
		vim.list_extend(candidates, {
			"wezterm",
			"/opt/homebrew/bin/wezterm",
			"/usr/local/bin/wezterm",
			"/Applications/WezTerm.app/Contents/MacOS/wezterm",
		})
	end

	for _, candidate in ipairs(candidates) do
		if is_executable(candidate) then
			return candidate
		end
	end

	return nil
end

local function image_path_for_wezterm(path)
	if not is_wsl() then
		return path
	end

	local result = vim.system({ "wslpath", "-w", path }, { text = true }):wait()
	local windows_path = result.stdout:gsub("%s+$", "")
	if result.code ~= 0 or windows_path == "" then
		return nil, "Failed to convert image path for WezTerm"
	end

	return windows_path
end

local function get_pane_id()
	if vim.env.WEZTERM_PANE then
		return vim.env.WEZTERM_PANE
	end

	local wezterm = find_wezterm()
	if not wezterm then
		return nil, "WezTerm executable not found"
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

	local wezterm = find_wezterm()
	if not wezterm then
		vim.notify("WezTerm executable not found", vim.log.levels.ERROR)
		return
	end

	local pane_id, pane_error = get_pane_id()
	if not pane_id then
		vim.notify(pane_error, vim.log.levels.ERROR)
		return
	end

	local image_path, path_error = image_path_for_wezterm(path)
	if not image_path then
		vim.notify(path_error, vim.log.levels.ERROR)
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
		image_path,
	}, { text = true }):wait()

	if result.code ~= 0 then
		vim.notify("WezTerm image preview failed: " .. result.stderr, vim.log.levels.ERROR)
	end
end

return M
