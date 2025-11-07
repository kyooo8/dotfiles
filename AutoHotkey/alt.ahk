#SingleInstance Force
#Include ".\AutoHotkey\getIme.ahk"
;--- Alt + Q → アプリを閉じる（macの⌘+Q）---
!q::WinClose("A")
; --- Alt → Ctrlマッピング系（macっぽく操作統一）---
!c::Send("^c")
!v::Send("^v")
!x::Send("^x")
!z::Send("^z")
!a::Send("^a")
!f::Send("^f")
!w::Send("^w")
!t::Send("^t")
!n::Send("^n")
!r::Send("^r")
!y::Send("^y")
!m::WinMinimize("A")
!+t::Send("^+t")
!Tab::Send("^{Tab}")
!+Tab::Send("^+{Tab}")
; --- Hyperターミナル専用 Alt → Ctrl+Shift マッピング ---
#HotIf WinActive("ahk_exe Hyper.exe") || WinActive("ahk_exe wezterm-gui.exe")
!c::Send("^+c")
!v::Send("^+v")
!x::Send("^+x")
!z::Send("^+z")
!a::Send("^+a")
!f::Send("^+f")
!w::Send("^+w")
!t::Send("^+t")
!n::Send("^+n")
!r::Send("^+r")
!y::Send("^+y")
!d::Send("^+d")
!e::Send("^+e")
!m::WinMinimize("A")
!+t::Send("^+t")
!Tab::Send("^+{Tab}")
!+Tab::Send("^+{Tab}")
#HotIf

;=====================================================================
; IME 入力モード (共通)
;   0:かな/半英数, 9:ひらがな, 11:全カナ, 8:全英数 など（環境依存あり）
;=====================================================================
IME_GetConvMode(WinTitle := "A") {
    hwnd := GetTargetHwnd(WinTitle)
    if !hwnd
        return 0
    def := DllCall("imm32\ImmGetDefaultIMEWnd", "Ptr", hwnd, "Ptr")
    ; IMC_GETCONVERSIONMODE(0x001)
    return DllCall("User32\SendMessageW"
        , "Ptr", def, "UInt", 0x0283, "Ptr", 0x0001, "Ptr", 0, "Ptr")
}

IME_SetConvMode(ConvMode, WinTitle := "A") {
    hwnd := GetTargetHwnd(WinTitle)
    if !hwnd
        return -1
    def := DllCall("imm32\ImmGetDefaultIMEWnd", "Ptr", hwnd, "Ptr")
    ; IMC_SETCONVERSIONMODE(0x002)
    return DllCall("User32\SendMessageW"
        , "Ptr", def, "UInt", 0x0283, "Ptr", 0x0002, "Ptr", ConvMode, "Ptr")
}

;=====================================================================
; IME 変換モード（MS-IME / ATOK / WXG / SKK 等で解釈差あり）
;   MS-IME: 0 無変換 / 1 人名地名 / 8 一般 / 16 話し言葉 …など
;=====================================================================
IME_GetSentenceMode(WinTitle := "A") {
    hwnd := GetTargetHwnd(WinTitle)
    if !hwnd
        return 0
    def := DllCall("imm32\ImmGetDefaultIMEWnd", "Ptr", hwnd, "Ptr")
    ; IMC_GETSENTENCEMODE(0x003)
    return DllCall("User32\SendMessageW"
        , "Ptr", def, "UInt", 0x0283, "Ptr", 0x0003, "Ptr", 0, "Ptr")
}

IME_SetSentenceMode(SentenceMode, WinTitle := "A") {
    hwnd := GetTargetHwnd(WinTitle)
    if !hwnd
        return -1
    def := DllCall("imm32\ImmGetDefaultIMEWnd", "Ptr", hwnd, "Ptr")
    ; IMC_SETSENTENCEMODE(0x004)
    return DllCall("User32\SendMessageW"
        , "Ptr", def, "UInt", 0x0283, "Ptr", 0x0004, "Ptr", SentenceMode, "Ptr")
}

;=====================================================================
; IME 入力中/変換中の判定
;   戻り値: 2=候補窓あり, 1=入力/変換中, 0=それ以外
;   ConvCls / CandCls は追加正規表現で拡張可能
;=====================================================================
IME_GetConverting(WinTitle := "A", ConvCls := "", CandCls := "") {
    ; 既定のクラス群（必要に応じて追加）
    ConvCls := (ConvCls ? ConvCls . "|" : "")
        . "ATOK\d+CompStr|imejpstcnv\d+|WXGIMEConv|SKKIME\d+\.*\d+UCompStr|MSCTFIME Composition"
    CandCls := (CandCls ? CandCls . "|" : "")
        . "ATOK\d+Cand|imejpstCandList\d+|imejpstcand\d+|mscandui\d+\.candidate|WXGIMECand|SKKIME\d+\.*\d+UCand"
    CandGCls := "GoogleJapaneseInputCandidateWindow"

    hwnd := GetTargetHwnd(WinTitle)
    if !hwnd
        return 0

    pid := WinGetPID("ahk_id " . hwnd)

    tmm := A_TitleMatchMode
    SetTitleMatchMode "RegEx"

    ret := 0
    if WinExist("ahk_class " . CandCls . " ahk_pid " . pid) {
        ret := 2
    } else if WinExist("ahk_class " . CandGCls) {
        ret := 2
    } else if WinExist("ahk_class " . ConvCls . " ahk_pid " . pid) {
        ret := 1
    }

    SetTitleMatchMode tmm
    return ret
}

;=============================================================================
; ここから：左右 Alt 空打ちで IME OFF/ON
;   - 左 Alt 空打ち：IME OFF（英数）
;   - 右 Alt 空打ち：IME ON（かな）
;   - Alt + 他キー同時押し時は通常 Alt として動作
;=============================================================================

;---------------------------
; パススルー用ホットキー（代表的キーをスルー）
; ※ v1 互換の書き方で OK（v2 でもラベル式ホットキーは有効）
;---------------------------
*~a:: Return
*~b:: Return
*~c:: Return
*~d:: Return
*~e:: Return
*~f:: Return
*~g:: Return
*~h:: Return
*~i:: Return
*~j:: Return
*~k:: Return
*~l:: Return
*~m:: Return
*~n:: Return
*~o:: Return
*~p:: Return
*~q:: Return
*~r:: Return
*~s:: Return
*~t:: Return
*~u:: Return
*~v:: Return
*~w:: Return
*~x:: Return
*~y:: Return
*~z:: Return
*~1:: Return
*~2:: Return
*~3:: Return
*~4:: Return
*~5:: Return
*~6:: Return
*~7:: Return
*~8:: Return
*~9:: Return
*~0:: Return
*~F1:: Return
*~F2:: Return
*~F3:: Return
*~F4:: Return
*~F5:: Return
*~F6:: Return
*~F7:: Return
*~F8:: Return
*~F9:: Return
*~F10:: Return
*~F11:: Return
*~F12:: Return
*~`:: Return
*~~:: Return
*~!:: Return
*~@:: Return
*~#:: Return
*~$:: Return
*~%:: Return
*~^:: Return
*~&:: Return
*~*:: Return
*~(:: Return
*~):: Return
*~-:: Return
*~_:: Return
*~=:: Return
*~+:: Return
*~[:: Return
*~{:: Return
*~]:: Return
*~}:: Return
*~\:: Return
*~|:: Return
*~;:: Return
*~':: Return
*~":: Return
*~,:: Return
*~<:: Return
*~.:: Return
*~>:: Return
*~/:: Return
*~?:: Return
*~Esc:: Return
*~Tab:: Return
*~Space:: Return
*~Left:: Return
*~Right:: Return
*~Up:: Return
*~Down:: Return
*~Enter:: Return
*~PrintScreen:: Return
*~Delete:: Return
*~Home:: Return
*~End:: Return
*~PgUp:: Return
*~PgDn:: Return

;---------------------------
; 上部メニューが勝手にアクティブ化されるのを抑制
;---------------------------
*~LAlt:: {
    Send "{Blind}{vk07}"
}
*~RAlt:: {
    Send "{Blind}{vk07}"
}

;---------------------------
; 左 Alt 空打ち → IME OFF
;---------------------------
LAlt up:: {
    if (A_PriorHotkey = "*~LAlt") {
        IME_SET(0)
    }
}

;---------------------------
; 右 Alt 空打ち → IME ON
;---------------------------
RAlt up:: {
    if (A_PriorHotkey = "*~RAlt") {
        IME_SET(1)
    }
}

