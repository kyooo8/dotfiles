local M = {}

local function file_exists(path)
	return vim.fn.filereadable(path) == 1
end

local function file_contains(path, pattern)
	if not file_exists(path) then
		return false
	end

	local ok, lines = pcall(vim.fn.readfile, path)
	if not ok then
		return false
	end

	return table.concat(lines, "\n"):find(pattern) ~= nil
end

function M.is_deno()
	local cwd = vim.fn.getcwd()
	local markers = {
		"/deno.json",
		"/deno.jsonc",
		"/deno.lock",
		"/import_map.json",
		"/fresh.config.ts",
		"/fresh.gen.ts",
	}

	for _, marker in ipairs(markers) do
		if file_exists(cwd .. marker) then
			return true
		end
	end

	return false
end

function M.is_biome()
	local cwd = vim.fn.getcwd()
	return file_exists(cwd .. "/biome.json") or file_exists(cwd .. "/biome.jsonc")
end

function M.is_wordpress()
	if vim.g.wp_project ~= nil then
		return vim.g.wp_project == true
	end

	local cwd = vim.fn.getcwd()

	if file_contains(cwd .. "/composer.json", "wp%-coding%-standards/wpcs") then
		return true
	end

	for _, suffix in ipairs({ "/phpcs.xml", "/phpcs.xml.dist" }) do
		if file_contains(cwd .. suffix, "WordPress") then
			return true
		end
	end

	return false
end

return M
