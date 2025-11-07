#Include ".\getime.ahk"

; === Layer1 ===
SendTilde(*)       { Send(IME_Get() ? "{Text}～" : "{Text}~")}
}SendAt(*)        => Send("{@}")
SendExclam(*)     => Send("{!}")
SendHash(*)       => Send("{#}")
SendStar(*)       => Send("{*}")
SendEqual(*)      => Send("{=}")
SendDollar(*)      { Send(IME_Get() ? "{Text}＄" : "{Text}$")}
SendCaret(*)      => Send("{^}")
SendBraceL(*)      { Send(IME_Get() ? "{Text}｛" : "{Text}{")}
SendParenL(*)     => Send("{(}")
SendBracketL(*)    { Send(IME_Get() ? "{Text}「" : "{Text}[")}
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
SendDubleQuote(*)  { Send(IME_Get() ? "{Text}＂" : '{Text}"')}
SendQuote(*)       { SendText(IME_Get() ? "’" : "'")}
SendDai(*)        => Send("{<}")
SendShou(*)       => Send("{>}")
SendQuestion(*)   => Send("{?}")
Sendcoron(*)      => Send("{:}")
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
        "l", SendBackslash,
        "r", SendQuote,
        "f", SendDubleQuote,
        "v", SendBackQuote,
        ",", SendDai,
        ".", SendShou,
        "/", SendQuestion,
        ";", Sendcoron 
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
        Sleep(0.1)
    }

    if !otherKeyPressed {
        Send(" ")
    }

    Layer1_Off()
}

