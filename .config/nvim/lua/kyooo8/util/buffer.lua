local M = {}

function M.trim_trailing_blank_lines(bufnr)
	bufnr = bufnr or 0
	local last = vim.api.nvim_buf_line_count(bufnr)

	while last > 1 do
		local line = vim.api.nvim_buf_get_lines(bufnr, last - 1, last, false)[1]
		if line ~= "" then
			break
		end
		last = last - 1
	end

	vim.api.nvim_buf_set_lines(bufnr, last, -1, false, {})
end

return M
