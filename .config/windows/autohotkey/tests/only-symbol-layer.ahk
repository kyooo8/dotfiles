#Requires AutoHotkey v2.0
#SingleInstance Force

; F24 を出すファームウェア用の従来の入口。全レイヤー版とは併用しない。
global symbolLayerHeld := false
#Include ".\symbol-layer.ahk"
RegisterSymbolLayer((*) => symbolLayerHeld)

*F24::
{
    global symbolLayerHeld
    symbolLayerHeld := true
}

*F24 up::
{
    global symbolLayerHeld
    symbolLayerHeld := false
}
