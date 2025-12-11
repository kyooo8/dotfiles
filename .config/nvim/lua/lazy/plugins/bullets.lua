return {
	{
		"dkarter/bullets.vim",
		ft = { "markdown", "text" },
		config = function()
			vim.g.bullets_delete_last_bullet_if_empty = 1
			vim.g.bullets_auto_indent_after_colon = 1
			vim.g.bullets_renumber_on_change = 1
			vim.g.bullets_outline_levels = { "std-" }
			vim.g.bullets_checkbox_markers = " .oOX"

			vim.opt.breakindent = true
			vim.opt.breakindentopt = "shift:2"

			vim.api.nvim_create_autocmd("FileType", {
				pattern = "markdown",
				callback = function()
					local function is_bullet()
						local line = vim.fn.getline(".")
						return (
							line:match("^%s*[%-%*+] +")
							or line:match("^%s*[%-%*+] %[[%sOoXx%.%-]%]")
							or line:match("^%s*%d+%. +")
						)
					end

					local ignore_key = vim.api.nvim_replace_termcodes("<Ignore>", true, false, true)

					vim.keymap.set("i", "<CR>", function()
						local bufnr = vim.api.nvim_get_current_buf()
						local row = vim.fn.line(".") - 1
						local line = vim.fn.getline(".")
						local indent = line:match("^(%s*)")

						local function replace_line(new_text, cursor_col, post_keys)
							local target_col = cursor_col or #new_text
							vim.schedule(function()
								if not vim.api.nvim_buf_is_valid(bufnr) then
									return
								end
								local ok = pcall(vim.api.nvim_buf_set_lines, bufnr, row, row + 1, false, { new_text })
								if not ok then
									return
								end
								pcall(vim.api.nvim_win_set_cursor, 0, { row + 1, target_col })
							end)
							return post_keys or ignore_key
						end

						local checkbox = line:match("^%s*[%-%*+] %[[%sOoXx%.%-]%] ")
						if checkbox then
							return "<CR>" .. indent .. "- [ ] "
						end

						if is_bullet() then
							local raw = line:gsub("^%s*[%-%*+] ?", "")
							local is_empty = raw:match("^%s*$") ~= nil
							local sw = vim.bo.shiftwidth > 0 and vim.bo.shiftwidth or 2

							if is_empty then
								if indent ~= "" then
									local cut = #indent - sw
									if cut < 0 then
										cut = 0
									end
									local new_indent = indent:sub(1, cut)

									return replace_line(new_indent .. "- ", #new_indent + 2, "<Esc>A")
								else
									return replace_line("", 0, "<Esc>A")
								end
							end

							return "<Plug>(bullets-newline)"
						end

						return "<CR>"
					end, { expr = true, buffer = true })

					vim.keymap.set("i", "<Tab>", function()
						return is_bullet() and "<Plug>(bullets-demote)" or "<Tab>"
					end, { expr = true, buffer = true })

					vim.keymap.set("i", "<S-Tab>", function()
						return is_bullet() and "<Plug>(bullets-promote)" or "<S-Tab>"
					end, { expr = true, buffer = true })

					vim.keymap.set("n", "<Tab>", function()
						return is_bullet() and "<Plug>(bullets-demote)" or "<Tab>"
					end, { expr = true, buffer = true })

					vim.keymap.set("n", "<S-Tab>", function()
						return is_bullet() and "<Plug>(bullets-promote)" or "<S-Tab>"
					end, { expr = true, buffer = true })
				end,
			})
		end,
	},
}
