local wezterm = require("wezterm")
local config = wezterm.config_builder()
local mux = wezterm.mux

-- ======== 設定値 ======== --
local DEFAULT_OPACITY = 0.70
local BLUR_ON = 60
local BLUR_OFF = 0

local WIN_BLUR_ON = "Acrylic"
local WIN_BLUR_OFF = "Disable"

local TOGGLE_OPACITY = 0.40

local is_mac = wezterm.target_triple:find("apple") ~= nil
local is_win = wezterm.target_triple:find("windows") ~= nil

-- ======== 基本設定 ======== --
config.color_scheme = "Catppuccin Macchiato"
config.font = wezterm.font_with_fallback({ "JetBrainsMonoNL Nerd Font Mono", "Cica" })
config.font_size = 12
config.use_ime = true

config.window_background_opacity = DEFAULT_OPACITY
if is_mac then
	config.macos_window_background_blur = BLUR_ON
end
if is_win then
	config.win32_system_backdrop = WIN_BLUR_ON
end

config.window_decorations = "RESIZE"
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.show_new_tab_button_in_tab_bar = false
config.tab_bar_at_bottom = false

-- ======== 透過トグル ======== --
wezterm.on("toggle-visual", function(window, _)
	local overrides = window:get_config_overrides() or {}
	local toggled = overrides.window_background_opacity ~= nil

	if toggled then
		overrides.window_background_opacity = nil
		if is_mac then
			overrides.macos_window_background_blur = nil
		end
		if is_win then
			overrides.win32_system_backdrop = nil
		end
	else
		overrides.window_background_opacity = TOGGLE_OPACITY
		if is_mac then
			overrides.macos_window_background_blur = BLUR_OFF
		end
		if is_win then
			overrides.win32_system_backdrop = WIN_BLUR_OFF
		end
	end

	window:set_config_overrides(overrides)
end)

-- 起動時最大化
wezterm.on("gui-startup", function(cmd)
	local _, _, window = mux.spawn_window(cmd or {})
	window:gui_window():maximize()
end)

config.keys = {
	{ key = "o", mods = "CTRL", action = wezterm.action.EmitEvent("toggle-visual") },
}

return config
