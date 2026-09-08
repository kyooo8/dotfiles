#Requires AutoHotkey v2.0
HyperDownTimes := Map()
HyperHeld := Map()
HyperUsed := Map()
HyperTimers := Map()
TapThreshold := 300

IsHyperHeld()
{
    global HyperHeld
    return (HyperHeld.Has("Tab") && HyperHeld["Tab"])
}

HyperDown(keyName)
{
    global HyperDownTimes, HyperHeld, HyperUsed, HyperTimers, TapThreshold
    if HyperDownTimes.Has(keyName)
        return

    HyperDownTimes[keyName] := A_TickCount
    HyperUsed[keyName] := false
    HyperHeld[keyName] := false
    HyperTimers[keyName] := ActivateHyper.Bind(keyName)
    SetTimer(HyperTimers[keyName], -TapThreshold)
}

ActivateHyper(keyName)
{
    global HyperDownTimes, HyperHeld
    if !HyperDownTimes.Has(keyName)
        return

    HyperHeld[keyName] := true
    Send "{Ctrl Down}{Alt Down}{Shift Down}"
}

HyperUp(keyName)
{
    global HyperDownTimes, HyperHeld, HyperUsed, HyperTimers, TapThreshold
    downTime := HyperDownTimes.Has(keyName) ? HyperDownTimes[keyName] : A_TickCount
    wasHeld := HyperHeld.Has(keyName) ? HyperHeld[keyName] : false
    wasUsed := HyperUsed.Has(keyName) ? HyperUsed[keyName] : true
    if (!wasUsed && A_PriorKey != keyName && !IsInjectedHyperModifier(A_PriorKey))
        wasUsed := true
    if HyperTimers.Has(keyName) {
        SetTimer(HyperTimers[keyName], 0)
        HyperTimers.Delete(keyName)
    }
    HyperHeld[keyName] := false
    if HyperDownTimes.Has(keyName)
        HyperDownTimes.Delete(keyName)
    if HyperUsed.Has(keyName)
        HyperUsed.Delete(keyName)

    if wasHeld && !IsHyperHeld()
        Send "{Ctrl Up}{Alt Up}{Shift Up}"

    if (!wasHeld && !IsHyperHeld() && !wasUsed && A_TickCount - downTime < TapThreshold)
        Send "{Tab}"
}

IsInjectedHyperModifier(keyName)
{
    return (keyName == "Ctrl" || keyName == "Control"
        || keyName == "LCtrl" || keyName == "RCtrl"
        || keyName == "LControl" || keyName == "RControl"
        || keyName == "Alt" || keyName == "LAlt" || keyName == "RAlt"
        || keyName == "Shift" || keyName == "LShift" || keyName == "RShift")
}

MarkHyperUsed()
{
    global HyperUsed
    for keyName in ["Tab"] {
        if HyperUsed.Has(keyName)
            HyperUsed[keyName] := true
    }
}

SendHyperArrow(direction)
{
    MarkHyperUsed()
    Send "{Ctrl Up}{Alt Up}{Shift Up}"
    Send direction
    if IsHyperHeld()
        Send "{Ctrl Down}{Alt Down}{Shift Down}"
}

$*Tab::HyperDown("Tab")

$*Tab Up::HyperUp("Tab")

#HotIf IsHyperHeld()
*h::SendHyperArrow("{Left}")
*j::SendHyperArrow("{Down}")
*k::SendHyperArrow("{Up}")
*l::SendHyperArrow("{Right}")
*p::SendHyperArrow("{Up}")
*n::SendHyperArrow("{Down}")
*a::SendHyperArrow("{Home}")
*e::SendHyperArrow("{End}")
*c::{
    MarkHyperUsed()
    if WinActive("ahk_exe claude.exe")
        WinMinimize "ahk_exe claude.exe"
    else if WinExist("ahk_exe claude.exe")
        WinActivate "ahk_exe claude.exe"
    else
        Run EnvGet("LOCALAPPDATA") "\AnthropicClaude\claude.exe"
}
#HotIf
