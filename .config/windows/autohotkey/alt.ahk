#SingleInstance Force

;--- Alt + Q → アプリを閉じる（macの⌘+Q）---
!q::WinClose("A")

IsWezTermActive() {
    return WinActive("ahk_exe wezterm-gui.exe") || WinActive("ahk_exe wezterm.exe")
}

; wezterm以外
#HotIf !IsWezTermActive()
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
#HotIf IsWezTermActive()
!c::Send("^+c")
!v::Send("^+v")
!x::Send("^+x")
!a::Send("^+a")
!f::Send("^+f")
#HotIf
