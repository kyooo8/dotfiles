; ~/.config/karabiner/assets/complex_modifications と ~/dev/homemade-keyboard/keymap.yaml の
; ノートPC内蔵キーボード向けレイヤーを Windows で再現する。
; 前提: Change Key で CapsLock の位置を F18 にしてある。
; 記号キーは物理位置で指定するためスキャンコードを使う (SC027=; SC035=/ SC028=' SC01A=[)。
#Requires AutoHotkey v2.0
#SingleInstance Force

MOUSE_SPEED := 8      ; 10ms あたりの移動 px。f 押下中は 2 倍
TAP_TIMEOUT := 1000   ; Karabiner の to_if_alone_timeout_milliseconds 既定値に合わせる
layer := ""

; 押している間 name レイヤー、他のキーを押さずに離したら tap を送る (Karabiner の to_if_alone 相当)
HoldLayer(name, key, tap) {
    global layer := name
    KeyWait key
    layer := ""
    if A_PriorKey = GetKeyName(key) && A_TimeSinceThisHotkey < TAP_TIMEOUT
        Send "{Blind}" tap
}

; Hyper: 押下中 Ctrl+Alt+Shift+Win、単押しで F18
*F18:: {
    Send "{Blind}{Ctrl down}{Alt down}{Shift down}{LWin down}"
    KeyWait "F18"
    ; vkE8 を挟まないと Ctrl+Alt+Shift+Win 単体の離上で Office アプリが開く
    Send "{Blind}{vkE8}{Ctrl up}{Alt up}{Shift up}{LWin up}"
    if A_PriorKey = "F18" && A_TimeSinceThisHotkey < TAP_TIMEOUT
        Send "{F18}"
}

; レイヤーキー。自レイヤー中も条件に含め、オートリピートが素の文字として漏れないようにする
#HotIf layer = "" || layer = "number"
*SC027::HoldLayer("number", "SC027", "{SC027}")
#HotIf layer = "" || layer = "symbol"
*SC035::HoldLayer("symbol", "SC035", "{SC035}")
#HotIf layer = "" || layer = "mouse"
*RShift:: {
    SetTimer MoveMouse, 10
    HoldLayer("mouse", "RShift", "{Esc}")
    SetTimer MoveMouse, 0
}

#HotIf layer = "number"
q::Home
w::Up
e::End
a::Left
s::Down
d::Right
g::Delete
h::Backspace
y::0
u::7
i::8
o::9
j::4
k::5
l::6
m::1
,::2
.::3
SC035::NumLock

#HotIf layer = "symbol"
*q::SendText "'"
*w::SendText "!"
*e::SendText "="
*r::SendText "%"
*t::SendText "~"
*u::SendText "_"
*i::SendText "{"
*o::SendText "}"
*p::SendText "|"
*a::SendText "@"
*s::SendText "#"
*d::SendText "$"
*j::SendText "+"
*k::SendText "("
*l::SendText ")"
*SC027::SendText "&"
*z::SendText "``"
*x::SendText "*"
*c::SendText "^"
*v::SendText '"'
*b::SendText "\"
*m::SendText "-"
*,::SendText "["
*.::SendText "]"

#HotIf layer = "mouse"
i::LButton
p::RButton
SC035::MButton
SC01A::XButton1
SC028::XButton2
*u::Send "{WheelDown}"
*j::Send "{WheelUp}"
*,::Send "{WheelLeft}"
*.::Send "{WheelRight}"
*a::Send "{Volume_Up}"
*z::Send "{Volume_Down}"
*m::Send "{Volume_Mute}"
*d::Brightness(10)
*c::Brightness(-10)
; 移動キーは MoveMouse が物理状態を読むので、ここでは入力を握りつぶすだけ
*o::
*l::
*k::
*SC027::
*f::return
#HotIf

; ponytail: 等速移動のみ。Karabiner のような加速が欲しくなったら押下時間で速度を上げる
MoveMouse() {
    s := GetKeyState("f", "P") ? MOUSE_SPEED * 2 : MOUSE_SPEED
    dx := (GetKeyState("SC027", "P") - GetKeyState("k", "P")) * s
    dy := (GetKeyState("l", "P") - GetKeyState("o", "P")) * s
    if dx || dy
        MouseMove dx, dy, 0, "R"
}

; 内蔵ディスプレイのみ対応 (外部モニターは WMI で輝度を変えられない)
Brightness(delta) {
    wmi := ComObjGet("winmgmts:\\.\root\WMI")
    for m in wmi.ExecQuery("SELECT CurrentBrightness FROM WmiMonitorBrightness")
        cur := m.CurrentBrightness
    for m in wmi.ExecQuery("SELECT * FROM WmiMonitorBrightnessMethods")
        m.WmiSetBrightness(1, Max(0, Min(100, cur + delta)))
}
