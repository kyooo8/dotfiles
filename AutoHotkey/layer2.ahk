#SingleInstance Force
; =====================================================
; === 固定関数群 ===
; =====================================================
Send1(*) => Send("1")
Send2(*) => Send("2")
Send3(*) => Send("3")
Send4(*) => Send("4")
Send5(*) => Send("5")
Send6(*) => Send("6")
Send7(*) => Send("7")
Send8(*) => Send("8")
Send9(*) => Send("9")
Send0(*) => Send("0")

SendF1(*) => Send("{F1}")
SendF2(*) => Send("{F2}")
SendF3(*) => Send("{F3}")
SendF4(*) => Send("{F4}")
SendF5(*) => Send("{F5}")
SendF6(*) => Send("{F6}")
SendF7(*) => Send("{F7}")
SendF8(*) => Send("{F8}")
SendF9(*) => Send("{F9}")
SendF10(*) => Send("{F10}")
SendF11(*) => Send("{F11}")
SendF12(*) => Send("{F12}")

Mute(*) => Send("{Volume_Mute}")
VolUp(*) => Send("{Volume_Up}")
VolDown(*) => Send("{Volume_Down}")

; =====================================================
; === Layer2登録 ===
; =====================================================
Layer2_Init() {
    global layer2Keys := Map(
        "u", Send1, "i", Send2, "o", Send3,
        "j", Send4, "k", Send5, "l", Send6,
        "m", Send7, ",", Send8, ".", Send9,
        "n", Send0,
        "q", SendF1, "w", SendF2, "e", SendF3, "r", SendF4,
        "a", SendF5, "s", SendF6, "d", SendF7, "f", SendF8,
        "z", SendF9, "x", SendF10, "c", SendF11, "v", SendF12,
        "t", Mute, "g", VolUp, "b", VolDown
    )

    for key, fn in layer2Keys
        Hotkey(key, fn, "Off") ; 初期登録
}

Layer2_On() {
    for key, fn in layer2Keys
        Hotkey(key, fn, "On")
}

Layer2_Off() {
    for key, fn in layer2Keys
        Hotkey(key, fn, "Off")
}

; =====================================================
; === メイン処理 ===
; =====================================================
Layer2_Init()

$Tab::
{
    Layer2_On()
    otherKeyPressed := false
    while GetKeyState("Tab", "P"){
        for key, fn in layer2Keys {
            if GetKeyState(key, "P") {
                otherKEyPressed := true
                break
            }
        }
        Sleep(5)
    }
    if !otherKeyPressed {
        send("{Tab}")
    }
    Layer2_Off()
}


$;::
{
    Layer2_On()
    otherKeyPressed := false
    while GetKeyState(";", "P") {
        for key, fn in layer2Keys {
            if GetKeyState(key, "P") {
                otherKeyPressed := true
                break
            }
        }
        Sleep(10)  ; CPU負荷軽減
    }
    if !otherKeyPressed {
        SendInput(";") 
    }
    Layer2_Off()
}
