#SingleInstance Force
;--- Alt + Q → アプリを閉じる（macの⌘+Q）---
!q::WinClose("A")
; --- Alt → Ctrlマッピング系（macっぽく操作統一）---
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

; --- Hyperターミナル専用 Alt → Ctrl+Shift マッピング ---
#HotIf WinActive("ahk_exe Hyper.exe") || WinActive("ahk_exe wezterm-gui.exe")
!c::Send("^+c")
!v::Send("^+v")
!x::Send("^+x")
~!z::return
!a::Send("^+a")
!f::Send("^+f")
~!w::return
~!+w::return
~!t::return
~!n::return
#HotIf