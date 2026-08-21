local wezterm = require("wezterm")
local config = wezterm.config_builder()
local mux = wezterm.mux
local act = wezterm.action

local DEFAULT_OPACITY = 0.9
local BLUR_ON = 40
local BLUR_OFF = 0

local WIN_BLUR_ON = "Acrylic"
local WIN_BLUR_OFF = "Disable"

local TOGGLE_OPACITY = 0.2
local TOGGLE_TEXT_BRIGHTNESS = 0.35
local GREP_MATCH_COLOR = "1;35"

local is_mac = wezterm.target_triple:find("apple") ~= nil
local is_win = wezterm.target_triple:find("windows") ~= nil

local catppuccin_accents = {
	"#f4dbd6", -- Rosewater
	"#f0c6c6", -- Flamingo
	"#f5bde6", -- Pink
	"#c6a0f6", -- Mauve
	"#ed8796", -- Red
	"#ee99a0", -- Maroon
	"#f5a97f", -- Peach
	"#eed49f", -- Yellow
	"#a6da95", -- Green
	"#8bd5ca", -- Teal
	"#91d7e3", -- Sky
	"#7dc4e4", -- Sapphire
	"#8aadf4", -- Blue
	"#b7bdf8", -- Lavender
}

local BORDER_WIDTH = "8px"
local BORDER_SPEED = 0.04

config.color_scheme = "Catppuccin Macchiato"
config.font = wezterm.font_with_fallback({ "JetBrainsMonoNL Nerd Font Mono", "Cica" })
config.font_size = 12
config.use_ime = true
config.set_environment_variables = {
	GREP_COLOR = GREP_MATCH_COLOR,
	GREP_OPTIONS = "--color=auto",
}

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

wezterm.on("toggle-visual", function(window, _)
	local overrides = window:get_config_overrides() or {}
	local toggled = overrides.window_background_opacity ~= nil

	if toggled then
		overrides.window_background_opacity = nil
		overrides.foreground_text_hsb = nil
		if is_mac then
			overrides.macos_window_background_blur = nil
		end
		if is_win then
			overrides.win32_system_backdrop = nil
		end
	else
		overrides.window_background_opacity = TOGGLE_OPACITY
		overrides.foreground_text_hsb = { hue = 1.0, saturation = 1.0, brightness = TOGGLE_TEXT_BRIGHTNESS }
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
	{
		key = "e",
		mods = "CMD",
		action = wezterm.action.PromptInputLine({
			description = "Enter new tab title:",
			action = wezterm.action_callback(function(window, pane, line)
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},
	{ key = "w", mods = "CMD", action = act.CloseCurrentPane({ confirm = true }) },
	{ key = "W", mods = "CMD|SHIFT", action = act.CloseCurrentTab({ confirm = true }) },
	{ key = "z", mods = "CMD", action = act.TogglePaneZoomState },
	{ key = "s", mods = "CMD", action = act.PaneSelect({ mode = "SwapWithActiveKeepFocus" }) },
	{ key = "S", mods = "CMD|SHIFT", action = act.PaneSelect({ mode = "MoveToNewTab" }) },
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
	{ key = ".", mods = "CMD", action = act.QuickSelect },
	{ key = "b", mods = "CMD", action = act.ActivateCopyMode },
	{ key = "/", mods = "CMD", action = act.Search({ CaseSensitiveString = "" }) },
	{ key = "r", mods = "CMD", action = act.Multiple({ act.ResetFontSize }) },
}

config.keys = keys

local function hex_to_rgb(hex)
	hex = hex:gsub("#", "")
	return tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16)
end

local function lerp(a, b, t)
	return a + (b - a) * t
end

local function lerp_color(hex1, hex2, t)
	local r1, g1, b1 = hex_to_rgb(hex1)
	local r2, g2, b2 = hex_to_rgb(hex2)
	local r = math.floor(lerp(r1, r2, t) + 0.5)
	local g = math.floor(lerp(g1, g2, t) + 0.5)
	local b = math.floor(lerp(b1, b2, t) + 0.5)
	return string.format("#%02x%02x%02x", r, g, b)
end

wezterm.GLOBAL.progress = wezterm.GLOBAL.progress or 0

local function animate_border(window)
	if not window then
		wezterm.log_error("animate_border: window is nil")
		return
	end

	wezterm.GLOBAL.progress = (wezterm.GLOBAL.progress + BORDER_SPEED) % #catppuccin_accents

	local index1 = math.floor(wezterm.GLOBAL.progress) + 1
	local index2 = (index1 % #catppuccin_accents) + 1
	local t = wezterm.GLOBAL.progress - math.floor(wezterm.GLOBAL.progress)

	local c = lerp_color(catppuccin_accents[index1], catppuccin_accents[index2], t)

	local ok, err = pcall(function()
		local overrides = window:get_config_overrides() or {}
		overrides.window_frame = {
			border_left_width = BORDER_WIDTH,
			border_right_width = BORDER_WIDTH,
			border_top_height = BORDER_WIDTH,
			border_bottom_height = BORDER_WIDTH,
			border_left_color = c,
			border_top_color = c,
			border_right_color = c,
			border_bottom_color = c,
		}
		window:set_config_overrides(overrides)
	end)

	if not ok then
		wezterm.log_error("set_config_overrides failed: " .. tostring(err))
	end

	wezterm.time.call_after(0.033, function()
		animate_border(window)
	end)
end

wezterm.on("gui-startup", function()
	local tab, pane, window = wezterm.mux.spawn_window({})
	animate_border(window:gui_window())
end)

return config
