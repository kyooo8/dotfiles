; 数字は参照元と同じ通常の数字キー。NumLock OFF でも数字を入力する。
NumberKeys() {
    return Map(
        "q", "Home",
        "w", "Up",
        "e", "End",
        "y", "0",
        "u", "7",
        "i", "8",
        "o", "9",
        "a", "Left",
        "s", "Down",
        "d", "Right",
        "g", "Delete",
        "h", "Backspace",
        "j", "4",
        "k", "5",
        "l", "6",
        "m", "1",
        ",", "2",
        ".", "3",
        "/", "NumLock"
    )
}

SendNumberKey(key, *) {
    ; Shift 選択、Ctrl+矢印など、押されている修飾キーを維持する。
    Send("{Blind}{" key "}")
}

RegisterNumberLayer(predicate) {
    HotIf(predicate)
    for key, target in NumberKeys()
        Hotkey("*" key, SendNumberKey.Bind(target), "On")
    HotIf()
}
