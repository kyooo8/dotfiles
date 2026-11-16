#Requires AutoHotkey v2.0
#SingleInstance Force

#Include ".\layer-state.ahk"
#Include ".\symbol-layer.ahk"
#Include ".\number-layer.ahk"
#Include ".\mouse-layer.ahk"

global layerState := HoldLayerState()
global hyperState := HoldLayerState()
global layerTap := ""
global hyperTap := ""

; 常時監視するのはキーイベントのみ。入力文字列は収集しない。
; 自分で送った記号や Hyper の修飾キーを単独押し判定に混ぜない。
global keyObserver := InputHook("V L0 I101")
keyObserver.KeyOpt("{All}", "N")
keyObserver.OnKeyDown := ObservePhysicalKey
keyObserver.Start()

RegisterSymbolLayer(HoldLayerActive.Bind("symbol"))
RegisterNumberLayer(HoldLayerActive.Bind("number"))
RegisterMouseLayer(HoldLayerActive.Bind("mouse"))
RegisterHoldKey(";", "number")
RegisterHoldKey("/", "symbol")
RegisterHoldKey("RShift", "mouse")
OnExit(ReleaseHeldInputs)

HoldLayerActive(name, *) {
    global layerState
    return layerState.Active = name
}

HoldCanStart(key, *) {
    global layerState
    return layerState.Active = "" || layerState.Trigger = key
}

HoldOwnsKey(key, *) {
    global layerState
    return layerState.Active != "" && layerState.Trigger = key
}

RegisterHoldKey(key, layer) {
    HotIf(HoldCanStart.Bind(key))
    Hotkey("*" key, StartHoldLayer.Bind(key, layer), "On")
    HotIf(HoldOwnsKey.Bind(key))
    Hotkey("*" key " up", EndHoldLayer.Bind(key), "On")
    HotIf()
}

TapSequence(key) {
    ; Shift を先に離しても、Shift+; / Shift+/ の : / ? を失わない。
    modifiers := ""
    for name, prefix in Map("Ctrl", "^", "Alt", "!", "Shift", "+", "LWin", "#", "RWin", "#")
        if GetKeyState(name)
            modifiers .= prefix
    return modifiers "{" key "}"
}

StartHoldLayer(key, layer, *) {
    global layerState, hyperState, layerTap
    hyperState.Observe(key)
    if !layerState.Press(layer, key, A_TickCount)
        return
    layerTap := TapSequence(key)
    if layer = "mouse"
        SetTimer(MouseLayerTick, 16)
}

EndHoldLayer(key, *) {
    global layerState, layerTap
    wasMouse := layerState.Active = "mouse"
    tap := layerState.Release(key, A_TickCount)
    if wasMouse
        StopMouseLayer()
    else if tap
        Send(layerTap)
}

ObservePhysicalKey(ih, vk, sc) {
    global layerState, hyperState
    for state in [layerState, hyperState] {
        if state.Active != "" && sc != GetKeySC(state.Trigger)
            state.Observe("other key")
    }
}

ObserveMouse(*) {
    global layerState, hyperState
    layerState.Observe("mouse")
    hyperState.Observe("mouse")
}

StartHyper(*) {
    global hyperState, layerState, hyperTap
    layerState.Observe("Esc")
    if !hyperState.Press("hyper", "Esc", A_TickCount)
        return
    hyperTap := TapSequence("Esc")
    Send("{Blind}{LCtrl downR}{LAlt downR}{LShift downR}{LWin downR}")
}

ReleaseHyperModifiers() {
    ; メニューやスタートを開かず、物理的に押している修飾キーは残す。
    Send("{Blind}{vkE8}")
    for key in ["LWin", "LShift", "LAlt", "LCtrl"]
        if !GetKeyState(key, "P")
            Send("{Blind}{" key " up}")
}

EndHyper(*) {
    global hyperState, hyperTap
    if hyperState.Active = ""
        return
    tap := hyperState.Release("Esc", A_TickCount)
    ReleaseHyperModifiers()
    if tap
        Send(hyperTap)
}

ReleaseHeldInputs(*) {
    global hyperState
    StopMouseLayer()
    if hyperState.Active != ""
        ReleaseHyperModifiers()
}

; Base の既存の ' → Enter は残す。Mouse では ' → 戻る/進むの進む側。
#HotIf !HoldLayerActive("mouse")
*'::Send("{Blind}{Enter}")
#HotIf

*Esc::StartHyper()
*Esc up::EndHyper()

#HotIf hyperState.Active != ""
; 物理 up を通してから down を再送すると、その間に次の文字が届き得る。
; Hyper 中は up 自体を止め、Esc 解放時に ReleaseHyperModifiers が解放する。
; down 側も定義し、up-only ホットキーが down まで奪うのを防ぐ。
~*LCtrl::return
~*LAlt::return
~*LShift::return
~*LWin::return
*LCtrl up::return
*LAlt up::return
*LShift up::return
*LWin up::return
#HotIf

; Karabiner の to_if_alone と同様、マウス操作も単独押しを取り消す。
~*LButton::ObserveMouse()
~*RButton::ObserveMouse()
~*MButton::ObserveMouse()
~*XButton1::ObserveMouse()
~*XButton2::ObserveMouse()
~*WheelUp::ObserveMouse()
~*WheelDown::ObserveMouse()
~*WheelLeft::ObserveMouse()
~*WheelRight::ObserveMouse()
