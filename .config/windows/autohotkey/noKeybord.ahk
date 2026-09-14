#SingleInstance Force

global symbolLayerHeld := false
global numberLayerHeld := false
global SpacePressTime := 0
global OverlapThreshold := 80

#Include ".\keymaps.ahk"
#Include ".\getIme.ahk"
#Include ".\symbol-layer.ahk"
#Include ".\number-layer.ahk"

IsHyperChordActive() {
    return GetKeyState("Ctrl") && GetKeyState("Alt") && GetKeyState("Shift")
}

ShouldUseSpaceLayer() {
    if GetKeyState("Ctrl", "P") && !GetKeyState("Alt", "P") && !GetKeyState("Shift", "P")
        return false
    if IsHyperChordActive()
        return false
    return !GetKeyState("LAlt")
}

#HotIf ShouldUseSpaceLayer()
*$Space::
{
    global symbolLayerHeld, SpacePressTime, OverlapThreshold, layer1Keys

    SpacePressTime := A_TickCount
    symbolLayerHeld := true
    KeyWait "Space"
    holdTime := A_TickCount - SpacePressTime
    symbolLayerHeld := false

    wasLayerKey := layer1Keys.Has(A_PriorKey)
    if !wasLayerKey || holdTime < OverlapThreshold
        SendInput " "
}
#HotIf

Ralt::
{
    global numberLayerHeld
    numberLayerHeld := true
    KeyWait "Ralt"
    numberLayerHeld := false
}
