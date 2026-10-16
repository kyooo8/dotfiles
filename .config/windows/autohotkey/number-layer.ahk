#Include ".\getIme.ahk"

NumSendModifier(keyName) {
    Send("{" . keyName . "}")
}

NumSendLiteral(text) {
    SendText(text)
}

NumSendNumpadDigit(digit) {
    Send("{Numpad" . digit . "}")
}

NumSend1(*) => NumSendNumpadDigit("1")
NumSend2(*) => NumSendNumpadDigit("2")
NumSend3(*) => NumSendNumpadDigit("3")
NumSend4(*) => NumSendNumpadDigit("4")
NumSend5(*) => NumSendNumpadDigit("5")
NumSend6(*) => NumSendNumpadDigit("6")
NumSend7(*) => NumSendNumpadDigit("7")
NumSend8(*) => NumSendNumpadDigit("8")
NumSend9(*) => NumSendNumpadDigit("9")
NumSend0(*) => NumSendNumpadDigit("0")

NumberLayerActive(*) {
    global numberLayerHeld
    return numberLayerHeld 
}

Layer2_Init() {
    global layer2Keys := Map(
        ; Shift 併用で範囲選択になるよう {Blind}
        "e", (*) => Send("{Blind}{End}"),
        "a", (*) => Send("{Blind}{Home}"),
        "f", (*) => Send("{Blind}{Right}"),
        "b", (*) => Send("{Blind}{Left}"),
        "n", (*) => Send("{Blind}{Down}"),
        "p", (*) => Send("{Blind}{Up}"),
        "d", (*) => Send("{Blind}{Delete}"),
        "h", (*) => Send("{Blind}{Backspace}"),

        "m", NumSend1,
        ",", NumSend2,
        ".", NumSend3,
        "j", NumSend4,
        "k", NumSend5,
        "l", NumSend6,
        "u", NumSend7,
        "i", NumSend8,
        "o", NumSend9,
        ";", NumSend0,
    )

    HotIf NumberLayerActive
    for key, fn in layer2Keys
        Hotkey("*" . key, fn, "On")
    HotIf
}

Layer2_Init()
