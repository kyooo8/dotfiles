#Include ".\getIme.ahk"
#Include ".\keymap-input.ahk"

; Karabiner symbol-layer.json / homemade-keyboard keymap.yaml の Symbol 配列。
; IME ON 時の全角入力は既存の Windows 版の振る舞いを保つ。
SymbolKeys() {
    return Map(
        "q", ["'", "’"],
        "w", ["!", "！"],
        "e", ["=", "＝"],
        "r", ["%", "％"],
        "t", ["~", "～"],
        "u", ["_", "＿"],
        "i", ["{", "｛"],
        "o", ["}", "｝"],
        "p", ["|", "｜"],
        "a", ["@", "＠"],
        "s", ["#", "＃"],
        "d", ["$", "＄"],
        "j", ["+", "＋"],
        "k", ["(", "（"],
        "l", [")", "）"],
        ";", ["&", "＆"],
        "z", ["``", "｀"],
        "x", ["*", "＊"],
        "c", ["^", "＾"],
        "v", ['"', '”'],
        "b", ["\", "＼"],
        "m", ["-", "－"],
        ",", ["[", "［"],
        ".", ["]", "］"]
    )
}

SendFW(half, full, *) {
    SendText(IME_GET() ? full : half)
}

RegisterSymbolLayer(predicate) {
    HotIf(predicate)
    for key, chars in SymbolKeys()
        Hotkey("*" key, RunMappedKey.Bind(key, SendFW.Bind(chars[1], chars[2])), "On")
    HotIf()
}
