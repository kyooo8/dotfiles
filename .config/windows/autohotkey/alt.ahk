#SingleInstance Force
;--- Alt + Q → アプリを閉じる（macの⌘+Q）---
!q::WinClose("A")
IsHyperTerminalActive() {
    return WinActive("ahk_exe Hyper.exe")
}

IsWezTermActive() {
    return WinActive("ahk_exe wezterm-gui.exe") || WinActive("ahk_exe wezterm.exe")
}

IsTerminalActive() {
    return IsHyperTerminalActive() || IsWezTermActive()
}

; --- Alt → Ctrlマッピング系（macっぽく操作統一）---
; Hyperキー（RShift/Esc）押下中は発火しない
; ターミナル以外
#HotIf !IsHyperHeld() && !IsTerminalActive()
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

; Hyper 専用
#HotIf !IsHyperHeld() && IsHyperTerminalActive()
!c::Send("^+c")
!v::Send("^+v")
!x::Send("^+x")
~!z::return
!a::Send("^+a")
!f::Send("^+f")
~!w::Send("^+w")
~!+w::return
~!t::Send("^+t")
~!d::Send("^+d")
~!+d::Send("^+e")
~!n::return
#HotIf

; wezterm 専用
#HotIf !IsHyperHeld() && IsWezTermActive()
!c::Send("^+c")
!v::Send("^+v")
!x::Send("^+x")
!a::Send("^+a")
!f::Send("^+f")
#HotIf
