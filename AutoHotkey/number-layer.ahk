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
        "z", NumSend1,
        "x", NumSend2,
        "c", NumSend3,
        "a", NumSend4,
        "s", NumSend5,
        "d", NumSend6,
        "q", NumSend7,
        "w", NumSend8,
        "e", NumSend9,
        "v", NumSend0,

        ",", NumSend1,
        ".", NumSend2,
        "/", NumSend3,
        "k", NumSend4,
        "l", NumSend5,
        ";", NumSend6,
        "i", NumSend7,
        "o", NumSend8,
        "p", NumSend9,
        "m", NumSend0,
    )

    HotIf NumberLayerActive
    for key, fn in layer2Keys
        Hotkey("*" . key, fn, "On")
    HotIf
}

Layer2_Init()
