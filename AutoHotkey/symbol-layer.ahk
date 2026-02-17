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
SendDai(*)          => SendFW("<", "＜")
SendShou(*)         => SendFW(">", "＞")
SendQuestion(*)     => SendFW("?", "？")
SendColon(*)        => SendFW(":", "：")

SymbolLayerActive(*) {
    global symbolLayerHeld
    return symbolLayerHeld 
  }

Layer1_Init() {
    global layer1Keys := Map(
        "q", SendTilde,
        "w", SendExclam,
        "e", SendEqual,
        "r", SendBackQuote,
        "t", SendBraceL,
        "y", SendBraceR,
        "u", SendUnderscore,
        "i", SendPipe,
        "p", SendPercent,

        "a", SendAt,
        "s", SendHash,
        "d", SendDollar,
        "f", SendDoubleQuote,
        "g", SendParenL,
        "h", SendParenR,
        "j", SendPlus,
        "k", SendAmp,
        "l", SendBackslash,
        ";", SendColon,
        
        "x", SendStar,
        "c", SendCaret,
        "v", SendQuote,
        "b", SendBracketL,
        "n", SendBracketR,
        "m", SendMinus,
        ",", SendDai,
        ".", SendShou,
        "/", SendQuestion,
        "[", (*) => Send("{Delete}")
    )

    HotIf SymbolLayerActive
    for key, fn in layer1Keys
        Hotkey("*" . key, fn, "On")
    HotIf
}

Layer1_Init()
