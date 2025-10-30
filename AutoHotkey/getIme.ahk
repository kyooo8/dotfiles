#SingleInstance Force
;=============================================================================
; IME Control for AutoHotkey v2 (single file)
;   - v1 の IME.ahk + Alt 空打ち切替 を統合し、v2 構文へ移植
;   - AHK v2.0 以降
;   - x64/Unicode 対応、GUIThreadInfo を利用
;   - アクティブ/非アクティブ双方で可能な範囲で IME 状態取得を試行
; Author (port): you & ChatGPT
;=============================================================================

;---------------------------
; 内部共通：対象 HWND の取得
;   優先順位：
;   1) アクティブ窓なら GUIThreadInfo の hwndFocus
;   2) 指定窓のフォーカス Control の HWND
;   3) 指定窓の HWND
;---------------------------
GetTargetHwnd(WinTitle := "A") {
    hwnd := 0

    if WinActive(WinTitle) {
        ; GUITHREADINFO 構造体確保
        ; cbSize= 4 + 4 + (Ptr*6) + 16
        cbSize := 4 + 4 + (A_PtrSize * 6) + 16
        buf := Buffer(cbSize, 0)
        NumPut "UInt", cbSize, buf, 0
        if DllCall("GetGUIThreadInfo", "UInt", 0, "Ptr", buf.Ptr, "UInt") {
            ; hwndFocus は offset 8 + PtrSize
            hwnd := NumGet(buf, 8 + A_PtrSize, "Ptr")
        }
    }

    if !hwnd {
        classNN := ControlGetFocus(WinTitle)
        if classNN {
            try hwnd := ControlGetHwnd(classNN, WinTitle)
        }
    }

    if !hwnd {
        try hwnd := WinGetID(WinTitle)
    }
    return hwnd
}

;=====================================================================
; IME 基本：ON / OFF
;   戻り値: 1 (ON) / 0 (OFF)
;=====================================================================
IME_GET(WinTitle := "A") {
    hwnd := GetTargetHwnd(WinTitle)
    if !hwnd
        return 0
    def := DllCall("imm32\ImmGetDefaultIMEWnd", "Ptr", hwnd, "Ptr")
    ; WM_IME_CONTROL(0x283), IMC_GETOPENSTATUS(0x0005)
    return DllCall("User32\SendMessageW"
        , "Ptr", def, "UInt", 0x0283, "Ptr", 0x0005, "Ptr", 0, "Ptr")
}

; 成功: 0、失敗: 非0（Win32 の慣習だが v1 互換でそのまま返す）
IME_SET(SetSts, WinTitle := "A") {
    hwnd := GetTargetHwnd(WinTitle)
    if !hwnd
        return -1
    def := DllCall("imm32\ImmGetDefaultIMEWnd", "Ptr", hwnd, "Ptr")
    ; WM_IME_CONTROL(0x283), IMC_SETOPENSTATUS(0x0006)
    return DllCall("User32\SendMessageW"
        , "Ptr", def, "UInt", 0x0283, "Ptr", 0x0006, "Ptr", SetSts, "Ptr")
}
