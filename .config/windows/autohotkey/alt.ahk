#SingleInstance Force
;--- Alt + Q → アプリを閉じる（macの⌘+Q）---
!q::WinClose("A")
; --- Alt → Ctrlマッピング系（macっぽく操作統一）---
; Hyperキー（RShift/Esc）押下中は発火しない
; ターミナル以外 かつ Hyper 以外
#HotIf !IsHyperHeld() && !WinActive("ahk_exe Hyper.exe")
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

; ターミナル専用（Hyper 以外）
#HotIf !IsHyperHeld() && WinActive("ahk_exe Hyper.exe")
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
