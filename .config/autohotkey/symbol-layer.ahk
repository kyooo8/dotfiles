#Include ".\getIme.ahk"

SendConditionalSymbol(fullWidth, halfWidth) {
    SendText(IME_Get() ? fullWidth : halfWidth)
}

SendLiteralSymbol(char) {
    SendText(char)
}

SendArrow(keyName) {
    Send("{" . keyName . "}")
}

SendFW(half, full) {
    SendText( IME_Get() ? full : half )
}

SendTilde(*)        => SendFW("~", "～")
SendAt(*)           => SendFW("@", "＠")
SendExclam(*)       => SendFW("!", "！")
SendHash(*)         => SendFW("#", "＃")
SendStar(*)         => SendFW("*", "＊")
SendEqual(*)        => SendFW("=", "＝")
SendDollar(*)       => SendFW("$", "＄")
SendCaret(*)        => SendFW("^", "＾")
SendBraceL(*)       => SendFW("{", "｛")
SendParenL(*)       => SendFW("(", "（")
SendBracketL(*)     => SendFW("[", "［")
SendBraceR(*)       => SendFW("}", "｝")
SendParenR(*)       => SendFW(")", "）")
SendBracketR(*)     => SendFW("]", "］")
SendUnderscore(*)   => SendFW("_", "＿")
SendPlus(*)         => SendFW("+", "＋")
SendMinus(*)        => SendFW("-", "－")
SendPipe(*)         => SendFW("|", "｜")
SendAmp(*)          => SendFW("&", "＆")
SendPercent(*)      => SendFW("%", "％")
SendBackslash(*)    => SendFW("\", "＼")
SendBackQuote(*) => SendFW(Chr(0x60), "｀")
SendQuote(*)        => SendFW("'", "’")
SendDoubleQuote(*)  => SendFW('"', '”')
SendSlash(*)  => SendFW('/', '・')
SendQuestion(*)  => SendFW('?', '？')

SymbolLayerActive(*) {
    global symbolLayerHeld, SpacePressTime, OverlapThreshold
    if !symbolLayerHeld
        return false
    ; オーバーラップ保護: Space を押してから OverlapThreshold ms 未満はレイヤー無効
    return A_TickCount - SpacePressTime >= OverlapThreshold
}

Layer1_Init() {
    global layer1Keys := Map(
        "q", SendQuestion,
        "w", SendExclam,
        "e", SendEqual,
        "t", SendTilde,
        "u", SendUnderscore,
        "i", SendPipe,
        "o", SendSlash,
        "p", SendPercent,

        "a", SendAt,
        "s", SendHash,
        "d", SendDollar,
        "f", SendParenL,
        "g", SendBraceL,
        "h", SendBraceR,
        "j", SendParenR,
        "k", SendAmp,
        "l", SendBackslash,
        ";", SendDoubleQuote,
        
        "z", SendBackQuote,
        "x", SendStar,
        "c", SendCaret,
        "b", SendBracketL,
        "n", SendBracketR,
        "m", SendMinus,
        ",", SendPlus,
        "/", SendQuote,
        "[", (*) => Send("{Delete}")
    )

    HotIf SymbolLayerActive
    for key, fn in layer1Keys
        Hotkey("*" . key, fn, "On")
    HotIf
}

Layer1_Init()
