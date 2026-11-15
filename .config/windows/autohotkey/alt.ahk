#SingleInstance Force

; 単体起動も可能。レイヤー中は配列を優先し、Hyper を横取りしない。
BaseShortcutsAllowed() {
    global layerState, hyperState
    return !IsSet(layerState) || (layerState.Active = "" && hyperState.Active = "")
}

#HotIf BaseShortcutsAllowed()
;--- Alt + Q → アプリを閉じる（macの⌘+Q）---
!q::WinClose("A")

IsWezTermActive() {
    return WinActive("ahk_exe wezterm-gui.exe") || WinActive("ahk_exe wezterm.exe")
}

; wezterm以外
#HotIf BaseShortcutsAllowed() && !IsWezTermActive()
!c::Send("^c")
!v::Send("^v")
!x::Send("^x")
!z::Send("^z")
!a::Send("^a")
!f::Send("^f")
!w::Send("^w")
!t::Send("^t")
!n::Send("^n")
!r::Send("^r")
!y::Send("^y")
!m::WinMinimize("A")
!+t::Send("^+t")
#HotIf

; wezterm 専用
#HotIf BaseShortcutsAllowed() && IsWezTermActive()
!c::Send("^+c")
!v::Send("^+v")
!x::Send("^+x")
!a::Send("^+a")
!f::Send("^+f")
#HotIf
