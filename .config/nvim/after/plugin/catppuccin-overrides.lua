local cp = require("catppuccin.palettes").get_palette("macchiato")

vim.api.nvim_set_hl(0, "GlancePreviewNormal", { bg = cp.crust })
vim.api.nvim_set_hl(0, "GlancePreviewBorder", { bg = cp.crust, fg = cp.overlay1 })

vim.api.nvim_set_hl(0, "GlanceListNormal", { bg = cp.mantle })
vim.api.nvim_set_hl(0, "GlanceListBorder", { bg = cp.mantle, fg = cp.overlay1 })
vim.api.nvim_set_hl(0, "GlanceWinBar", { bg = cp.mantle, fg = cp.blue })

vim.api.nvim_set_hl(0, "LspInlayHint", { bg = cp.surface0, fg = cp.subtext0 })
