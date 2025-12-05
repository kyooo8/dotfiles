local wezterm = require("wezterm")
local config = wezterm.config_builder()
local mux = wezterm.mux
local act = wezterm.action

local DEFAULT_OPACITY = 0.85
local BLUR_ON = 60
local BLUR_OFF = 0

local WIN_BLUR_ON = "Acrylic"
local WIN_BLUR_OFF = "Disable"

local TOGGLE_OPACITY = 0.40

local is_mac = wezterm.target_triple:find("apple") ~= nil
local is_win = wezterm.target_triple:find("windows") ~= nil

config.color_scheme = "Catppuccin Macchiato"
config.font = wezterm.font_with_fallback({ "JetBrainsMonoNL Nerd Font Mono", "Cica" })
config.font_size = 12.5
config.use_ime = true

config.window_background_opacity = DEFAULT_OPACITY
if is_mac then
	config.macos_window_background_blur = BLUR_ON
end
if is_win then
	config.win32_system_backdrop = WIN_BLUR_ON
end

config.inactive_pane_hsb = {
	saturation = 0.9,
	brightness = 0.3,
}
config.window_decorations = "RESIZE"
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.show_new_tab_button_in_tab_bar = false
config.tab_bar_at_bottom = false

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

local keys = {
	{ key = "o", mods = "CMD", action = act.EmitEvent("toggle-visual") },
	{ key = "u", mods = "CMD", action = act({ SplitVertical = { domain = "CurrentPaneDomain" } }) },
	{ key = "i", mods = "CMD", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "t", mods = "CMD", action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "w", mods = "CMD", action = act.CloseCurrentPane({ confirm = true }) },
	{ key = "W", mods = "CMD|SHIFT", action = act.CloseCurrentTab({ confirm = true }) },
	{ key = "z", mods = "CMD", action = act.TogglePaneZoomState },
	{ key = "s", mods = "CMD", action = act.PaneSelect },
	{ key = "S", mods = "CMD|SHIFT", action = act.PaneSelect({ mode = "SwapWithActiveKeepFocus" }) },
	{ key = "h", mods = "CMD", action = act.ActivatePaneDirection("Left") },
	{ key = "j", mods = "CMD", action = act.ActivatePaneDirection("Down") },
	{ key = "k", mods = "CMD", action = act.ActivatePaneDirection("Up") },
	{ key = "l", mods = "CMD", action = act.ActivatePaneDirection("Right") },
	{ key = "H", mods = "CMD|SHIFT", action = act.AdjustPaneSize({ "Left", 5 }) },
	{ key = "J", mods = "CMD|SHIFT", action = act.AdjustPaneSize({ "Down", 5 }) },
	{ key = "K", mods = "CMD|SHIFT", action = act.AdjustPaneSize({ "Up", 5 }) },
	{ key = "L", mods = "CMD|SHIFT", action = act.AdjustPaneSize({ "Right", 5 }) },
	{ key = "(", mods = "CMD|SHIFT", action = act.MoveTabRelative(-1) },
	{ key = ")", mods = "CMD|SHIFT", action = act.MoveTabRelative(1) },
	{ key = "n", mods = "CMD", action = act.ActivateTabRelative(1) },
	{ key = "p", mods = "CMD", action = act.ActivateTabRelative(-1) },
	{ key = ";", mods = "CMD", action = act.QuickSelect },
}

config.keys = keys

return config
