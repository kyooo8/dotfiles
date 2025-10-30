#SingleInstance Force
#Include "C:\Users\kyosu\Documents\AutoHotkey\getime.ahk"
; =====================================================
; === Layer1 ===
; =====================================================
SendTilde(*) {
    if IME_Get() {
        Send("{Text}～")  ; 日本語モード → 全角
    } else {
        Send("{Text}~")   ; 英語モード → 半角
    }
}SendAt(*)         => Send("{@}")
SendExclam(*)     => Send("{!}")
SendHash(*)       => Send("{#}")
SendStar(*)       => Send("{*}")
SendEqual(*)      => Send("{=}")
SendDollar(*) {
    if IME_Get() {
        Send("{Text}＄")  ; 日本語モード → 全角
    } else {
        Send("{Text}$")   ; 英語モード → 半角
    }
}
SendCaret(*)      => Send("{^}")
SendBraceL(*)     => Send("{{}")
SendParenL(*)     => Send("{(}")
SendBracketL(*)   => Send("{[}")
SendBraceR(*)     => Send("{}}")
SendParenR(*)     => Send("{)}")
SendBracketR(*)   => Send("{]}")
SendUnderscore(*) => Send("{_}")
SendPlus(*)       => Send("{+}")
SendMinus(*)      => Send("{-}")
SendPipe(*)       => Send("{|}")
SendAmp(*)        => Send("{&}")
SendPercent(*)    => Send("{%}")
SendBackslash(*)  => Send("{\}")
SendBackQuote(*)  => Send("{``}")
SendDubleQuote(*) => Send('{"}')
SendQuote(*) {
    SendText(IME_Get() ? "’" : "'")
}
SendDai(*)        => Send("{<}")
SendShou(*)       => Send("{>}")
SendQuestion(*)   => Send("{?}")

Layer1_Init() {
    global layer1Keys := Map(
        "q", SendTilde,
        "a", SendAt,
        "w", SendExclam,
        "s", SendHash,
        "x", SendStar,
        "e", SendEqual,
        "d", SendDollar,
        "c", SendCaret,
        "t", SendBraceL,
        "g", SendParenL,
        "b", SendBracketL,
        "y", SendBraceR,
        "h", SendParenR,
        "n", SendBracketR,
        "u", SendUnderscore,
        "j", SendPlus,
        "m", SendMinus,
        "i", SendPipe,
        "k", SendAmp,
        "p", SendPercent,
        ";", SendBackslash,
        "'", SendQuote,
        "r", SendQuote,
        "f", SendDubleQuote,
        "v", SendBackQuote,
        ",", SendDai,
        ".", SendShou,
        "/", SendQuestion
    )

    for key, fn in layer1Keys
        Hotkey(key, fn, "Off")
}

Layer1_On() {
    for key, fn in layer1Keys
        Hotkey(key, fn, "On")
}

Layer1_Off() {
    for key, fn in layer1Keys
        Hotkey(key, fn, "Off")
}


Layer1_Init()

$Space::
{
    Layer1_On()
    otherKeyPressed := false

    while GetKeyState("Space", "P") {
        for key, fn in layer1Keys {
            if GetKeyState(key, "P") {
                otherKeyPressed := true
                break
            }
        }
        Sleep(5)
    }

    ; スペース離した時点で判定
    if !otherKeyPressed {
        Send(" ")
    }

    Layer1_Off()
}
