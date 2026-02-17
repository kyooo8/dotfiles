#Requires AutoHotkey v2.0

SetCapsLockState "AlwaysOff"



CapsDownTime := 0

TapThreshold := 300



SendHyperArrow(direction)
{
    Send "{Ctrl Up}{Alt Up}{Shift Up}"
    Send direction
    if GetKeyState("CapsLock", "P")
        Send "{Ctrl Down}{Alt Down}{Shift Down}"
}


*CapsLock::

{

    global CapsDownTime

    CapsDownTime := A_TickCount

    Send "{Ctrl Down}{Alt Down}{Shift Down}"

}



*CapsLock Up::

{

    global CapsDownTime, TapThreshold

    Send "{Ctrl Up}{Alt Up}{Shift Up}"



    if (A_TickCount - CapsDownTime < TapThreshold)

        Send "{Esc}"

}


#HotIf GetKeyState("CapsLock", "P")

*h::

{

    SendHyperArrow("{Left}")

}



*j::

{

    SendHyperArrow("{Down}")

}



*k::

{

    SendHyperArrow("{Up}")

}



*l::

{

    SendHyperArrow("{Right}")

}


*d::

{

    SendHyperArrow("{End}")

}



*c::

{

    SendHyperArrow("{Home}")

}


#HotIf

