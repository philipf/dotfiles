; Makes the mouse cursor follow window focus, but ONLY when the focus change
; was caused by the keyboard (Alt-Tab, Win+Number, hotkeys, launchers, etc.).
;
; Detection strategy: with Windows' focus-follows-mouse ("activate window on
; hover") enabled, every mouse-caused activation is immediately preceded by
; cursor movement, while every keyboard-caused activation happens with the
; cursor sitting still. So we continuously track when the cursor last moved,
; and on activation we warp only if the cursor has been idle.

#Requires AutoHotkey v2.0

; --- Tuning -----------------------------------------------------------------
MOVE_RECENT_MS := 250   ; cursor movement this recent => treat as mouse-caused
POLL_MS        := 50     ; how often we sample the cursor position
; ---------------------------------------------------------------------------

lastMoveTime := 0
lastX := 0
lastY := 0
MouseGetPos(&lastX, &lastY)

; Continuously track cursor movement.
SetTimer(TrackMouse, POLL_MS)

TrackMouse() {
    global lastMoveTime, lastX, lastY
    MouseGetPos(&x, &y)
    if (x != lastX or y != lastY) {
        lastX := x
        lastY := y
        lastMoveTime := A_TickCount
    }
}

; Listen for shell activation events.
myGui := Gui()
myGui.Show("Hide")
hWnd := myGui.Hwnd

DllCall("RegisterShellHookWindow", "UInt", hWnd)
msgNum := DllCall("RegisterWindowMessage", "Str", "SHELLHOOK", "UInt")
OnMessage(msgNum, OnShellMessage)

OnShellMessage(wParam, lParam, msg, hwnd) {
    global lastMoveTime, lastX, lastY, MOVE_RECENT_MS
    ; HSHELL_WINDOWACTIVATED | HSHELL_RUDEAPPACTIVATED
    if (wParam != 4 and wParam != 32772)
        return

    ; If the cursor moved recently, the activation was mouse-driven
    ; (focus-follows-mouse hover or a click) - leave the cursor alone.
    if (A_TickCount - lastMoveTime <= MOVE_RECENT_MS)
        return

    ; lParam is the handle of the window being activated.
    win := "ahk_id " lParam
    try {
        WinGetPos(&wx, &wy, &width, &height, win)
        if (!width or !height)
            return
        mx := Round(wx + width * 0.5)
        my := Round(wy + height * 0.5)
        DllCall("SetCursorPos", "Int", mx, "Int", my)
        ; Record our own warp so the tracker doesn't read it as user movement.
        lastX := mx
        lastY := my
    }
}
