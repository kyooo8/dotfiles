#SingleInstance Force

global symbolLayerHeld := false
global numberLayerHeld := false

#Include ".\getIme.ahk"
#Include ".\keymaps.ahk"
#Include ".\symbol-layer.ahk"
#Include ".\number-layer.ahk"

$Space::
{
    global symbolLayerHeld
    otherKeyPressed := false

    symbolLayerHeld := true

    while GetKeyState("Space", "P") {
        for key, fn in layer1Keys {
            if GetKeyState(key, "P") {
                otherKeyPressed := true
                break
            }
        }
        Sleep(5)
    }

    if !otherKeyPressed {
        SendInput(" ")
    }

    symbolLayerHeld := false
}


SC073::
{
    global numberLayerHeld
    numberLayerHeld := true
    KeyWait("SC073")
    numberLayerHeld := false
}
