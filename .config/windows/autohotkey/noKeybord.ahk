#SingleInstance Force

global symbolLayerHeld := false
global numberLayerHeld := false

#Include ".\keymaps.ahk"
#Include ".\getIme.ahk"
#Include ".\symbol-layer.ahk"
#Include ".\number-layer.ahk"

; keymap.yaml の Symbol キー（P の右）。押している間だけ Symbol レイヤー
*[::
{
    global symbolLayerHeld
    symbolLayerHeld := true
    KeyWait "["
    symbolLayerHeld := false
}

*Ralt::
{
    global numberLayerHeld
    numberLayerHeld := true
    KeyWait "Ralt"
    numberLayerHeld := false
}
