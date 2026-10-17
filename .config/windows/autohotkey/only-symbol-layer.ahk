#SingleInstance Force

; Symbol レイヤーだけを単体で起動する。noKeybord.ahk と同時に起動すると F24 を取り合うので併用しない
global symbolLayerHeld := false

#Include ".\symbol-layer.ahk"

; keymap.yaml の Symbol キー（F24 を送出）。押している間だけ Symbol レイヤー
*F24::
{
    global symbolLayerHeld
    symbolLayerHeld := true
    KeyWait "F24"
    symbolLayerHeld := false
}
