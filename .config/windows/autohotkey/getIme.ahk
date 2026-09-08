
#SingleInstance Force

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

IME_GET(WinTitle := "A") {
    hwnd := GetTargetHwnd(WinTitle)
    if !hwnd
        return 0
    def := DllCall("imm32\ImmGetDefaultIMEWnd", "Ptr", hwnd, "Ptr")
    return DllCall("User32\SendMessageW"
        , "Ptr", def, "UInt", 0x0283, "Ptr", 0x0005, "Ptr", 0, "Ptr")
}
