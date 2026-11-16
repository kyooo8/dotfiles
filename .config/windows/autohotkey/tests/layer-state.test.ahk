#Requires AutoHotkey v2.0
#Include "..\layer-state.ahk"
#Include "..\keymap-input.ahk"

Assert(value, message) {
    if !value
        throw Error(message)
}

try {
    ; InputHook が抑制された入力を通知しない経路を再現する。
    ; Observe は呼ばず、実際のホットキーと同じ処理入口を通す。
    global layerState := HoldLayerState()
    global hyperState := HoldLayerState()
    global actionCount := 0
    for trigger, layer in Map(";", "number", "/", "symbol") {
        layerState.Press(layer, trigger, 100)
        RunMappedKey("q", CountAction)
        Assert(!layerState.Release(trigger, 150), "Mapped key must cancel " trigger " tap")
    }
    hyperState.Press("hyper", "F18", 100)
    RunMappedKey("'", CountAction)
    Assert(!hyperState.Release("F18", 150), "Mapped Enter must cancel F18 tap")
    Assert(actionCount = 3, "Mapped actions must still run exactly once")

    for trigger, layer in Map(";", "number", "/", "symbol", "F18", "hyper") {
        held := HoldLayerState()
        held.Press(layer, trigger, 100)
        Assert(held.Release(trigger, 299), "Short isolated press still types " trigger)
        held.Press(layer, trigger, 100)
        Assert(!held.Release(trigger, 300), "200ms hold must not type " trigger)
        held.Press(layer, trigger, 100)
        held.Press(layer, trigger, 550)
        Assert(!held.Release(trigger, 600), "Repeat must not turn hold into tap")
    }

    state := HoldLayerState()
    Assert(state.Press("number", ";", 100), "First press activates Number")
    Assert(state.Active = "number", "Number is active immediately")
    Assert(!state.Press("number", ";", 200), "Auto-repeat must not restart tap timer")
    Assert(state.Release(";", 299), "Short isolated press permits semicolon tap")
    Assert(state.Active = "", "Release returns to Base")
    Assert(!state.Release(";", 301), "Duplicate release must not type twice")

    state.Press("symbol", "/", 100)
    state.Observe("q")
    state.Observe("/")
    Assert(!state.Release("/", 150), "Chord followed by repeat must not type slash")

    state.Press("number", ";", 100)
    Assert(!state.Press("symbol", "/", 150), "Second layer cannot replace first")
    Assert(!state.Release("/", 200), "Unrelated release cannot deactivate layer")
    Assert(state.Active = "number", "Original layer remains active")
    Assert(!state.Release(";", 250), "Second trigger cancels tap")

    state.Press("hyper", "F18", 100)
    Assert(!state.Release("F18", 1101), "Long hold must not emit F18")
    state.Press("hyper", "F18", 2000)
    state.Observe("LButton")
    Assert(!state.Release("F18", 2050), "Mouse chord cancels F18 tap")
    state.Press("symbol", "/", 3000)
    Assert(state.Release("/", 3100), "State resets for the next isolated tap")
    FileAppend("Layer state tests passed`n", "*")
    ExitApp(0)
} catch as err {
    FileAppend(err.Message "`n", "**")
    ExitApp(1)
}

CountAction(*) {
    global actionCount
    actionCount += 1
    Assert(layerState.Used || hyperState.Used, "Tap must be cancelled before running action")
}
