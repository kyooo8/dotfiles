
#SingleInstance Force
; ===============================
; Mouse Keys Mode v15
; （d + hjklでON、単押しdは入力OK、フォーカス中でも誤入力防止）
; ===============================

mouseKeysMode := false
scrollMode := false
moveDir := {x: 0, y: 0}
dPressed := false
dUsedForMouse := false

; ===============================
; GUI（右下ステータス表示）
; ===============================
mouseGui := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x20")
mouseGui.SetFont("s11 Bold", "Segoe UI")
modeText := mouseGui.Add("Text", "vModeText cBlack BackgroundFFFFFF", "Mouse Mode: OFF")
mouseGui.Show("x" . (A_ScreenWidth - 250) . " y" . (A_ScreenHeight - 140) . " AutoSize")
mouseGui.Hide()

UpdateGui(state) {
    global mouseGui, modeText
    modeText.Value := "Mouse Mode: " . (state ? "ON" : "OFF")
    mouseGui.Show()
}

; ===============================
; dキーでマウス制御（単押し vs コンボ判定）
; ===============================
$d::
{
    global dPressed, dUsedForMouse
    dPressed := true
    dUsedForMouse := false
}

$d up::
{
    global dPressed, dUsedForMouse, mouseKeysMode, scrollMode, moveDir
    dPressed := false

    ; マウスモードを使わなかったなら普通にd入力
    if !dUsedForMouse {
        Send "d"
        return
    }

    ; マウスモード解除処理
    mouseKeysMode := false
    scrollMode := false
    moveDir.x := 0
    moveDir.y := 0
    UpdateGui(false)
    mouseGui.Hide()
}
; ===============================
; 条件付きホットキー（d押してる間）
; ===============================
#HotIf GetKeyState("d", "P")

; ====== hjklで移動 ======
h::
{
    global mouseKeysMode, moveDir, dUsedForMouse
    dUsedForMouse := true
    mouseKeysMode := true
    moveDir.x := -1
    UpdateGui(true)
}
h up::
{
    global moveDir
    if (moveDir.x = -1)
        moveDir.x := 0
}

l::
{
    global mouseKeysMode, moveDir, dUsedForMouse
    dUsedForMouse := true
    mouseKeysMode := true
    moveDir.x := 1
    UpdateGui(true)
}
l up::
{
    global moveDir
    if (moveDir.x = 1)
        moveDir.x := 0
}

j::
{
    global mouseKeysMode, moveDir, dUsedForMouse
    dUsedForMouse := true
    mouseKeysMode := true
    moveDir.y := 1
    UpdateGui(true)
}
j up::
{
    global moveDir
    if (moveDir.y = 1)
        moveDir.y := 0
}

k::
{
    global mouseKeysMode, moveDir, dUsedForMouse
    dUsedForMouse := true
    mouseKeysMode := true
    moveDir.y := -1
    UpdateGui(true)
}
k up::
{
    global moveDir
    if (moveDir.y = -1)
        moveDir.y := 0
}

; ====== スクロールモード ======
s::
{
    global scrollMode, mouseKeysMode, dUsedForMouse
    dUsedForMouse := true
    mouseKeysMode := true
    scrollMode := true
    UpdateGui(true)
}
s up::
{
    global scrollMode
    scrollMode := false
}

; ====== クリック ======
v::
{
    global mouseKeysMode, dUsedForMouse
    dUsedForMouse := true
    mouseKeysMode := true
    MouseClick "Left"
}
b::
{
    global mouseKeysMode, dUsedForMouse
    dUsedForMouse := true
    mouseKeysMode := true
    MouseClick "Middle"
}
n::
{
    global mouseKeysMode, dUsedForMouse
    dUsedForMouse := true
    mouseKeysMode := true
    MouseClick "Right"
}

#HotIf

; ===============================
; マウス移動・スクロール制御
; ===============================
SetTimer(UpdateMouse, 10)

UpdateMouse() {
    global mouseKeysMode, scrollMode, moveDir
    if !mouseKeysMode
        return

    if (moveDir.x = 0 && moveDir.y = 0)
        return

    speed := 14
    if GetKeyState("f", "P")
        speed := 30
    else if GetKeyState("g", "P")
        speed := 2

    dx := moveDir.x * speed
    dy := moveDir.y * speed

    if scrollMode {
        if dx > 0
            MouseClick "WheelRight",,, 1
        else if dx < 0
            MouseClick "WheelLeft",,, 1
        if dy > 0
            MouseClick "WheelDown",,, 1
        else if dy < 0
            MouseClick "WheelUp",,, 1
        return
    }

    MouseMove dx, dy, 0, "R"
}

