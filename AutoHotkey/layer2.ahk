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
        "i", Send1, "o", Send2, "p", Send3,
        "k", Send4, "l", Send5, ";", Send6,
        ",", Send7, ".", Send8, "/", Send9,
        "m", Send0,
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

SC073::
{
    Layer2_On()
    while GetKeyState("SC073", "P")
        Sleep(10)
    Layer2_Off()
}
