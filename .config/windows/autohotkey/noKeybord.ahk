#SingleInstance Force

global symbolLayerHeld := false
global numberLayerHeld := false

#Include ".\keymaps.ahk"
#Include ".\getIme.ahk"
#Include ".\symbol-layer.ahk"
#Include ".\number-layer.ahk"

; keymap.yaml の Symbol キー（F24 を送出）。押している間だけ Symbol レイヤー
*F24::
{
    global symbolLayerHeld
    symbolLayerHeld := true
    KeyWait "F24"
    symbolLayerHeld := false
}

*Ralt::
{
    global numberLayerHeld
    numberLayerHeld := true
    KeyWait "Ralt"
    numberLayerHeld := false
}
