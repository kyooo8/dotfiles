local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.color_scheme = "Catppuccin Macchiato" -- or Macchiato, Frappe, Latte, Mocha
config.font = wezterm.font_with_fallback({ "JetBrainsMono Nerd Font", "Cica" }, { weight = "Bold" })
config.font_size = 12
config.use_ime = true

config.window_background_opacity = 0.85
config.macos_window_background_blur = 20

config.window_decorations = "RESIZE"
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.show_new_tab_button_in_tab_bar = false
config.tab_bar_at_bottom = true

return config
