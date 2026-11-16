; 追加ボタン位置は、通常のキーボードを対象とする Karabiner 側に合わせる。
MouseKeys() {
    return Map(
        "u", "WheelDown",
        "i", "LButton",
        "o", "MoveUp",
        "p", "RButton",
        "[", "XButton1",
        "a", "Volume_Up",
        "d", "BrightnessUp",
        "f", "Fast",
        "j", "WheelUp",
        "k", "MoveLeft",
        "l", "MoveDown",
        ";", "MoveRight",
        "'", "XButton2",
        "z", "Volume_Down",
        "c", "BrightnessDown",
        "m", "Volume_Mute",
        ",", "WheelLeft",
        ".", "WheelRight",
        "/", "MButton"
    )
}

RegisterMouseLayer(predicate) {
    global heldMouseButtons := Map()
    for key, action in MouseKeys() {
        HotIf(predicate)
        Hotkey("*" key, MouseAction.Bind(key, action), "On")
        if InStr(action, "Button") {
            ; レイヤーを先に離してもボタンの up を取りこぼさない。
            HotIf(MouseButtonHeld.Bind(key))
            Hotkey("*" key " up", ReleaseMouseButton.Bind(key), "On")
        }
    }
    HotIf()
}

MouseButtonHeld(key, *) {
    global heldMouseButtons
    return heldMouseButtons.Has(key)
}

MouseAction(key, action, *) {
    global heldMouseButtons
    if InStr(action, "Button") {
        if !heldMouseButtons.Has(key) {
            heldMouseButtons[key] := action
            Send("{Blind}{" action " down}")
        }
    } else if action = "BrightnessUp" || action = "BrightnessDown" {
        ChangeBrightness(action = "BrightnessUp" ? 10 : -10)
    } else if SubStr(action, 1, 7) = "Volume_" {
        Send("{" action "}")
    }
    ; 移動・スクロール・加速はタイマーで物理的な押下状態を読む。
}

ReleaseMouseButton(key, *) {
    global heldMouseButtons
    if heldMouseButtons.Has(key) {
        button := heldMouseButtons[key]
        heldMouseButtons.Delete(key)
        ; 実マウスで同じボタンを押している場合は勝手に離さない。
        if !GetKeyState(button, "P")
            Send("{Blind}{" button " up}")
    }
}

StopMouseLayer() {
    global heldMouseButtons
    SetTimer(MouseLayerTick, 0)
    keys := []
    for key in heldMouseButtons
        keys.Push(key)
    for key in keys
        ReleaseMouseButton(key)
}

MouseLayerTick() {
    static lastWheel := 0
    if !HoldLayerActive("mouse")
        return
    step := GetKeyState("f", "P") ? 24 : 12
    dx := (GetKeyState(";", "P") - GetKeyState("k", "P")) * step
    dy := (GetKeyState("l", "P") - GetKeyState("o", "P")) * step
    if dx || dy
        MouseMove(dx, dy, 0, "R")
    if A_TickCount - lastWheel < 60
        return
    lastWheel := A_TickCount
    for key, wheel in Map("u", "WheelDown", "j", "WheelUp", ",", "WheelLeft", ".", "WheelRight")
        if GetKeyState(key, "P")
            Send("{Blind}{" wheel "}")
}

ChangeBrightness(delta) {
    ; Windows 標準 WMI に対応するパネルのみ。外部モニターの DDC/CI は対象外。
    try {
        service := ComObjGet("winmgmts:\\.\root\WMI")
        changed := false
        for panel in service.ExecQuery("SELECT * FROM WmiMonitorBrightness WHERE Active = TRUE") {
            target := Max(0, Min(100, panel.CurrentBrightness + delta))
            for methods in service.ExecQuery("SELECT * FROM WmiMonitorBrightnessMethods WHERE Active = TRUE") {
                if methods.InstanceName = panel.InstanceName {
                    if methods.WmiSetBrightness(0, target) != 0
                        throw Error("WmiSetBrightness failed")
                    changed := true
                }
            }
        }
        if !changed
            throw Error("No WMI brightness device")
    } catch {
        ToolTip("このディスプレイでは WMI による輝度変更が利用できません。")
        SetTimer(() => ToolTip(), -2000)
    }
}
