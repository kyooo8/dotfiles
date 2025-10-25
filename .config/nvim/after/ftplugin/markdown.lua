-- チェックボックス切替（Obsidian互換・プラグイン不要）
vim.keymap.set("n", "<leader>tc", function()
	local line = vim.api.nvim_get_current_line()
	-- トグルロジック
	if line:match("%- %[ %]") then
		line = line:gsub("%- %[ %]", "- [x]", 1)
	elseif line:match("%- %[x%]") then
		line = line:gsub("%- %[x%]", "- [ ]", 1)
	end
	vim.api.nvim_set_current_line(line)
end, { desc = "チェックボックス切替" })
