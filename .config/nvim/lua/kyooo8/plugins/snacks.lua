local function harpoon_section()
	local ok, harpoon = pcall(require, "harpoon")
	if not ok then
		return {}
	end

	local list = harpoon:list()
	local items = {}
	for i = 1, list:length() do
		local entry = list:get(i)
		if entry then
			items[#items + 1] = {
				file = entry.value,
				icon = "file",
				action = ":e " .. vim.fn.fnameescape(entry.value),
				autokey = true,
			}
		end
	end
	return items
end

local function git_section()
	if vim.fn.system("git rev-parse --is-inside-work-tree 2>/dev/null"):match("true") == nil then
		return {}
	end

	local branch = vim.fn.system("git branch --show-current 2>/dev/null"):gsub("%s+$", "")
	local dirty = vim.fn.system("git status --porcelain 2>/dev/null")
	local status = dirty == "" and "clean" or (#vim.split(dirty, "\n", { trimempty = true }) .. " changed")

	return {
		{ icon = " ", text = { { branch ~= "" and branch or "(no branch)", hl = "special" } } },
		{ icon = dirty == "" and " " or " ", text = { { status, hl = dirty == "" and "dir" or "file" } } },
	}
end

return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	keys = {
		{ "<leader>d", function() Snacks.dashboard() end, desc = "Open dashboard" },
	},
	opts = {
		dashboard = {
			preset = {
				header = "⚡ kyooo8.nvim",
			},
			sections = {
				{ section = "header" },
				{ section = "keys", gap = 1, padding = 1 },
				{
					pane = 1,
					{ icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1, limit = 5 },
					{ icon = " ", title = "Harpoon", indent = 2, padding = 1, harpoon_section },
				},
				{
					pane = 2,
					{ icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1, limit = 5 },
					{ icon = " ", title = "Git", indent = 2, padding = 1, git_section },
				},
				{ section = "startup" },
			},
		},
	},
}
