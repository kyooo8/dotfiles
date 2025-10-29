local ts = vim.treesitter

if not ts or type(ts.get_node_text) ~= "function" then
  return
end

local function clamp(value, min_value, max_value)
  if value < min_value then
    return min_value
  end
  if value > max_value then
    return max_value
  end
  return value
end

local original_get_node_text = ts.get_node_text

---@param node userdata
---@param source integer|string|table|function
---@param opts table|nil
---@return string
ts.get_node_text = function(node, source, opts)
  if not node then
    return ""
  end

  local ok, text = pcall(original_get_node_text, node, source, opts)
  if ok then
    return text
  end

  -- When the original helper fails (e.g. parser reports an out-of-range column),
  -- try again with clamped ranges so the highlighter stays functional.
  if type(source) == "string" or type(source) == "table" then
    return ""
  end

  local bufnr = source
  if type(bufnr) ~= "number" or bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end

  local line_count = vim.api.nvim_buf_line_count(bufnr)
  if line_count == 0 then
    return ""
  end

  local start_row, start_col, end_row, end_col = node:range()

  start_row = clamp(start_row, 0, line_count - 1)
  end_row = clamp(end_row, start_row, line_count - 1)

  local first_line = vim.api.nvim_buf_get_lines(bufnr, start_row, start_row + 1, false)[1] or ""
  local safe_start_col = clamp(start_col, 0, #first_line)

  local last_line = vim.api.nvim_buf_get_lines(bufnr, end_row, end_row + 1, false)[1]
  if not last_line then
    return ""
  end

  -- Tree-sitter columns are byte-based, so #last_line is a suitable clamp.
  local safe_end_col = clamp(end_col, 0, #last_line)

  if end_row == start_row and safe_end_col < safe_start_col then
    safe_end_col = safe_start_col
  end

  local success, pieces = pcall(vim.api.nvim_buf_get_text, bufnr, start_row, safe_start_col, end_row, safe_end_col, {})
  if not success then
    return ""
  end

  return table.concat(pieces, "\n")
end
