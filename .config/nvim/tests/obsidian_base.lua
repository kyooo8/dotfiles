local config = vim.env.BASE_TEST_RTP or vim.fs.dirname(vim.fs.dirname(debug.getinfo(1, 'S').source:sub(2)))
local root = vim.fn.tempname()
vim.fn.mkdir(root, 'p')
root = vim.uv.fs_realpath(root)
vim.opt.rtp:prepend(config)
_G.Obsidian = { workspace = { path = root } }
package.preload['obsidian.note'] = function()
  return { from_buffer = function() return { id = 'source', path = root .. '/source.md' } end }
end
package.preload['obsidian.api'] = function()
  return { smart_action = function() return '' end }
end
local base = require('kyooo8.util.obsidian_base')
local notes = {
  { id = '日本語ノート', path = root .. '/日本語ノート.md' },
  { id = 'beta', path = root .. '/beta.md' },
}
for _, note in ipairs(notes) do
  note.get_field = function() return '2026-10-26' end
end
for _, note in ipairs(notes) do vim.fn.writefile({ '# ' .. note.id }, note.path) end
vim.fn.writefile({ 'views: []' }, root .. '/test.base')
base.scan_vault = function() return {} end
base.load = function() return { views = { { name = 'Empty' }, { name = 'First', order = { 'file.name', 'created' } }, { name = 'Second' } } } end
base.run_view = function(_, view)
  if view.name == 'Empty' then return {} end
  return notes
end
dofile(config .. '/lua/kyooo8/core/autocmds.lua')
for _, ext in ipairs({ 'md', 'base' }) do
  local path = root .. '/source.' .. ext
  local original = ext == 'md' and { '# Source', '![[test.base]]', 'tail', '![[test.base#Second]]', 'end' } or { 'views: []' }
  vim.fn.writefile(original, path)
  vim.cmd.edit(path)
  vim.wait(50)
  local buf = vim.api.nvim_get_current_buf()
  local rendered = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  assert(#rendered > #original, 'automatic render missing')
  assert(not vim.bo[buf].modified, 'render marked buffer modified')
  local date_column
  local namespace = vim.api.nvim_create_namespace('kyooo8_obsidian_base')
  local headers, links = 0, 0
  for _, mark in ipairs(vim.api.nvim_buf_get_extmarks(buf, namespace, 0, -1, { details = true })) do
    local line = rendered[mark[2] + 1]
    assert(not line:match('^Empty %(') and not line:match('^First %(') and not line:match('^Second %('), 'view title should be hidden')
    assert(not line:find('|', 1, true), 'vertical borders should be absent')
    if line:find('2026-10-26', 1, true) then
      local byte = line:find('2026-10-26', 1, true)
      local column = vim.fn.strdisplaywidth(line:sub(1, byte - 1))
      date_column = date_column or column
      assert(column == date_column, 'Japanese and ASCII columns should align')
    end
    local details = mark[4]
    if line:match('^ノート') then
      headers = headers + 1
      assert(details.line_hl_group == 'ObsidianBaseHeader', 'header background missing')
    elseif line:match('^日本語ノート') or line:match('^beta') then
      links = links + 1
      assert(details.hl_group == 'ObsidianBaseLink', 'note link highlight missing')
      local name = line:match('^日本語ノート') or 'beta'
      assert(mark[3] == 0 and details.end_col == #name, 'link highlight must cover only the note name')
    end
  end
  assert(headers == (ext == 'md' and 4 or 3), 'all view headers should be visible')
  assert(links == (ext == 'md' and 6 or 4), 'all note names should be highlighted')
  base.render_buffer(buf)
  assert(vim.deep_equal(rendered, vim.api.nvim_buf_get_lines(buf, 0, -1, false)), 'render duplicated rows')
  local count = 0
  for row, line in ipairs(rendered) do
    for _, note in ipairs(notes) do
      if vim.trim(line):sub(1, #note.id) == note.id then
        count = count + 1
        vim.api.nvim_set_current_buf(buf)
        -- Simulate obsidian.nvim resetting <CR> when returning to the note.
        vim.keymap.set('n', '<CR>', function() end, { buffer = buf })
        base.setup_cr_override(buf)
        vim.api.nvim_win_set_cursor(0, { row, 0 })
        vim.cmd('normal \r')
        assert(vim.api.nvim_buf_get_name(0) == note.path, ext .. ' row ' .. row .. ' should jump to ' .. note.id .. ', got ' .. vim.api.nvim_buf_get_name(0))
      end
    end
  end
  assert(count == (ext == 'md' and 6 or 4), 'expected all data rows')
  vim.api.nvim_set_current_buf(buf)
  vim.cmd.write()
  vim.wait(50)
  assert(vim.deep_equal(vim.fn.readfile(path), original), 'rendered lines leaked to disk')
  assert(not vim.bo[buf].modified, 'save/re-render marked buffer modified')
  vim.api.nvim_buf_set_lines(buf, 0, 0, false, { 'user edit' })
  base.render_buffer(buf)
  assert(vim.bo[buf].modified, 'render lost modified flag')
  vim.cmd.write()
  vim.wait(50)
  table.insert(original, 1, 'user edit')
  assert(vim.deep_equal(vim.fn.readfile(path), original), 'save lost user edit or included render')
  print('PASS ' .. ext .. ': all row jumps, multiple/empty views, re-render and clean save')
end

-- A Base can put file.name after another column; Enter anywhere on the row still follows it.
base.load = function() return { views = { { name = 'Reordered', order = { 'created', 'file.name' } } } } end
vim.cmd.edit(root .. '/source.md')
local buf = vim.api.nvim_get_current_buf()
base.render_buffer(buf)
for _, mark in ipairs(vim.api.nvim_buf_get_extmarks(buf, vim.api.nvim_create_namespace('kyooo8_obsidian_base'), 0, -1, { details = true })) do
  if mark[4].hl_group == 'ObsidianBaseLink' then
    assert(mark[3] > 0, 'link highlight should begin at the note column')
    local line = vim.api.nvim_buf_get_lines(buf, mark[2], mark[2] + 1, false)[1]
    local name = line:sub(mark[3] + 1, mark[4].end_col)
    vim.api.nvim_set_current_buf(buf)
    vim.api.nvim_win_set_cursor(0, { mark[2] + 1, 0 })
    vim.cmd('normal \r')
    assert(vim.api.nvim_buf_get_name(0) == root .. '/' .. name .. '.md', 'Enter failed with reordered columns')
  end
end
print('PASS UI: hidden titles, header/link highlights, Japanese widths, reordered columns')
