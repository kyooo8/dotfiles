#SingleInstance Force

global symbolLayerHeld := false
global numberLayerHeld := false
global SpacePressTime := 0
global OverlapThreshold := 80

#Include ".\keymaps.ahk"
#Include ".\getIme.ahk"
#Include ".\symbol-layer.ahk"
#Include ".\number-layer.ahk"

#HotIf !(GetKeyState("Ctrl", "P") && !GetKeyState("Alt", "P") && !GetKeyState("Shift", "P")) && (!GetKeyState("LAlt") || (GetKeyState("Ctrl") && GetKeyState("Alt") && GetKeyState("Shift")))
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
