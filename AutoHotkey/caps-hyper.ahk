
#SingleInstance Force
SetCapsLockState("AlwaysOff")
; 汎用関数: アプリウィンドウをトグル（開く／フォーカス／最小化）
ToggleApp(appExe, appPath)
{
    if WinExist("ahk_exe " appExe)
    {
        if WinActive("ahk_exe " appExe)
            WinMinimize("ahk_exe " appExe) ; すでにフォーカスあり → 最小化
        else
            WinActivate("ahk_exe " appExe)  ; 開いている → フォーカスを当てる
    }
    else
    {
        Run(appPath)                         ; 開いていない → 起動
    }
}
; Explorer専用関数
ToggleExplorer()
{
    if WinExist("ahk_class CabinetWClass")
    {
        if WinActive("ahk_class CabinetWClass")
            WinMinimize("ahk_class CabinetWClass")
        else
            WinActivate("ahk_class CabinetWClass")
    }
    else
    {
        Run("explorer.exe")
    }
}
; --- 左CtrlをHyperに（Ctrl+Alt+Shift） ---
; Hyperモード開始
$CapsLock::
{
    start := A_TickCount

    ; キーが離される or 300ms 経過まで待つ
    KeyWait("LControl", "T0.3")

    if !GetKeyState("LControl", "P") {
        ; --- 単押し（短押し） → Esc ---
        Send("{Esc}")
        return
    }

    ; --- 長押し（Hyperモード） ---
    Send("{Ctrl down}{Alt down}{Shift down}")
    KeyWait("LControl")
    Send("{Shift up}{Alt up}{Ctrl up}")
}

CapsLock & c::Send("{Alt Down}{Shift Down}{Esc}{Shift Up}{Alt Up}")

CapsLock & b:: ToggleApp("chrome.exe"
    , "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Google Chrome.lnk")

CapsLock & n:: ToggleApp("Notion.exe"
    , "C:\Users\" A_UserName "\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Notion.lnk")

CapsLock & s:: ToggleApp("Slack.exe"
    , "C:\Users\" A_UserName "\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Slack Technologies Inc\Slack.lnk")

CapsLock & h:: ToggleApp("Hyper.exe"
    , "C:\Users\" A_UserName "\AppData\Local\Programs\Hyper\Hyper.exe")

CapsLock & t:: ToggleApp("wezterm-gui.exe"
    , "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\WezTerm.lnk")

CapsLock & w:: ToggleApp("WindowsTerminal.exe", "wt.exe")

CapsLock & f:: ToggleExplorer()
CapsLock & d:: ToggleApp("Docker Desktop.exe"
    , "C:\ProgramData\Microsoft\Windows\Start Menu\Docker Desktop.lnk")

CapsLock & l:: ToggleApp("LINE.exe"
    , "C:\Users\" A_UserName "\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\LINE\LINE.lnk")

CapsLock & o:: ToggleApp("Obsidian.exe"
    , "C:\Users\" A_UserName "\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Obsidian.lnk")

