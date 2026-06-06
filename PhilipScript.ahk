#Requires AutoHotkey v2.0
#SingleInstance Force


SendMode("Input")  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir(A_ScriptDir)  ; Ensures a consistent starting directory.


; --- VirtualDesktopAccessor Setup ---
; Make sure VirtualDesktopAccessor.dll is in the same folder as this script.
VDADLL := A_ScriptDir '\VirtualDesktopAccessor.dll'



; This script is written for AutoHotkey v2.0+
; It maps the hotkey Ctrl+Q to send Alt+F4, which typically closes the active window.

; The caret (^) represents the Control key.
; The exclamation mark (!) represents the Alt key.
; {F4} is the F4 key.

^q::
{
    ; Send the Alt+F4 combination
    Send "!{F4}"
}


; =================================================================
; --- HOTKEYS ---
; =================================================================

; --- 1. Switch to a specific desktop (Win + Numpad/Number) ---
#1::
#Numpad1:: {
GoToDesktop(1)
}

#2::
#Numpad2:: {
GoToDesktop(2)
}
#3::
#Numpad3:: {
GoToDesktop(3)
}

#4::
#Numpad4:: {
GoToDesktop(4)
}

#5::
#Numpad5:: {
GoToDesktop(5)
}

#6::
#Numpad6:: {
GoToDesktop(6)
}

#7::
#Numpad7:: {
GoToDesktop(7)
}
#8::
#Numpad8:: {
GoToDesktop(8)
}
#9::
#Numpad9:: {
GoToDesktop(9)
}
  

; --- 2. Move active window to a specific desktop (Win + Ctrl + Number/Numpad) ---
#^1::
#^Numpad1:: {
    MoveWindowToDesktop(1)
}
#^2::
#^Numpad2:: {
    MoveWindowToDesktop(2)
}
#^3::
#^Numpad3:: {
    MoveWindowToDesktop(3)
}
#^4::
#^Numpad4:: {
    MoveWindowToDesktop(4)
}
#^5::
#^Numpad5:: {
    MoveWindowToDesktop(5)
}
#^6::
#^Numpad6:: {
    MoveWindowToDesktop(6)
}
#^7::
#^Numpad7:: {
    MoveWindowToDesktop(7)
}
#^8::
#^Numpad8:: {
    MoveWindowToDesktop(8)
}
#^9:: 
#^Numpad9:: {
    MoveWindowToDesktop(9)
}

; --- 3. Switch to the next/previous desktop (Win+Ctrl+Shift + Arrow) --- (currently disabled)
;#^+Right::GoToRelativeDesktop(1)   ; Win+Ctrl+Shift+Right -> next desktop
;#^+Left::GoToRelativeDesktop(-1)   ; Win+Ctrl+Shift+Left  -> previous desktop

; =================================================================
; --- FUNCTIONS ---
; =================================================================

/**
 * Switches the view to a specific desktop number.
 * Creates the desktop (and any in between) if it doesn't exist.
 * @param DesktopNumber The 1-based index of the desktop to switch to.
 */
GoToDesktop(DesktopNumber) {
    Global VDADLL
    
    ; Get the current total number of desktops.
    desktopCount := DllCall(VDADLL '\GetDesktopCount', 'Int')

    ; If the requested desktop is beyond the current count, create new ones.
    If (DesktopNumber > desktopCount) {
        Loop (DesktopNumber - desktopCount) {
            DllCall(VDADLL '\CreateDesktop', 'Int')
        }
    }
    
    DllCall("User32\AllowSetForegroundWindow", "Int",-1) ;ASFW_ANY is -1 ;https://www.reddit.com/r/AutoHotkey/comments/qvkjhh/comment/hkx42s7/?utm_source=share&utm_medium=web2x&context=3
        
    ; Now that the desktop is guaranteed to exist, switch to it.
    DllCall(VDADLL '\GoToDesktopNumber', 'Int', DesktopNumber - 1)


    ;Send("!{Esc}") ; ALT+Esc activates last window
}

/**
 * Moves the currently active window to a specific desktop number.
 * Creates the desktop (and any in between) if it doesn't exist.
 * @param DesktopNumber The 1-based index of the destination desktop.
 */
MoveWindowToDesktop(DesktopNumber) {
    Global VDADLL
    
    hwnd := WinExist("A")
    If (hwnd = 0)
        Return

    ; Get the current total number of desktops.
    desktopCount := DllCall(VDADLL '\GetDesktopCount', 'Int')

    ; If the requested desktop is beyond the current count, create new ones.
    If (DesktopNumber > desktopCount) {
        Loop (DesktopNumber - desktopCount) {
            DllCall(VDADLL '\CreateDesktop', 'Int')
        }
    }

    ; Now that the desktop is guaranteed to exist, move the window to it.
    DllCall(VDADLL '\MoveWindowToDesktopNumber', 'Ptr', hwnd, 'Int', DesktopNumber - 1)
}


/**
 * Switches the view to the next or previous desktop.
 * @param offset +1 to go to the next desktop, -1 to go to the previous.
 */
GoToRelativeDesktop(offset) {
    Global VDADLL
    
    ; Get the current desktop number (0-based) and the total number of desktops.
    currentDesktop := DllCall(VDADLL '\GetCurrentDesktopNumber', 'Int')
    desktopCount := DllCall(VDADLL '\GetDesktopCount', 'Int')

    ; Do nothing if there's only one desktop.
    If (desktopCount <= 1)
        Return

    ; Calculate the target desktop number with wrap-around logic.
    targetDesktop := Mod(currentDesktop + offset + desktopCount, desktopCount)

    ; Call the DLL function to switch to the target desktop.
    DllCall(VDADLL '\GoToDesktopNumber', 'Int', targetDesktop)
}


; Win + PageUp, toggle maximize/restore of the active window
#PgUp:: {
    if WinActive("A") { ; Checks if there is an active window
        if (WinGetMinMax("A") = 1) {
            WinRestore("A") ; Restore if maximized
        } else {
            WinMaximize("A") ; Maximize if not maximized
        }
    }
}

; Win + PageDown, minimize the active window
#PgDn:: {
    WinMinimize("A") ; Minimizes the active window ("A")
}



; Control + Windows + \, open the GTD Kanban board in Obsidian
^#\::
{
  Run("obsidian://open?vault=SecondBrain&file=_GTD%2F_Board")
}

; Control + Windows + [, open GTD add new tasks
^#[::
{
  Run("gt gtd")
}

; Control + Windows + ], open GTD add new tasks with AI
^#]::
{
  Run("gt gtd --ai")
}

; Windows + Shift + B, open the default browser
#+b::
{
  ; Look up the default browser from the registry and launch its executable
  progId := RegRead("HKCU\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice", "ProgId")
  cmd := RegRead("HKCR\" progId "\shell\open\command")

  ; Extract just the exe path (strip arguments like --single-argument %1)
  if (SubStr(cmd, 1, 1) = '"')
    exe := SubStr(cmd, 2, InStr(cmd, '"', , 2) - 2)  ; quoted path
  else
    exe := (p := InStr(cmd, " ")) ? SubStr(cmd, 1, p - 1) : cmd  ; first token

  Run(exe)
}

; Windows + Enter or Ctrl + Alt + T, open Windows Terminal
#Enter::
^!t::
{
  Run("wt.exe", , "Max")
}


; ; Control + Shift + Enter is pressed, run the python goodchat.py program
; ^+Enter::
; {
;   ;before := A_Clipboard ;Save the clipboard
;   Send("^a")
;   A_Clipboard := "" ; Empty the clipboard
;   Send("^c")

;   if !ClipWait(5)
;   {
;       MsgBox "The attempt to copy text onto the clipboard failed."
;       return
;   }

;   text := A_Clipboard

;   path := "c:\tmp\goodchat.txt"
;   command := "python `"G:\My Drive\Roaming\goodchat.py`" `"" text "`" --output " . path

;   Send("{End}")
;   Send("{Shift}+{Enter 2}")
;   SendText("Processing...")
;   Send("{Shift}+{Enter}")

;   RunWait command, ,"Hide"
;   result := FileRead(path)
;   A_Clipboard := ""
;   A_Clipboard := result
;   Send("^a")
;   ClipWait(5)
;   Send("^v")

;   ;A_Clipboard := before ; Restore the clipboard
;   Return
; }

; F7 in Windows Explorer creates a New Folder
F7::
{
  If WinActive("ahk_class CabinetWClass")
    Send("^+n")
  return
}

; =================================================================
; --- HOTSTRINGS (type the trigger to expand) ---
; =================================================================

; ]pf -> email sign-off "Kind regards," + newline + "Philip"
:*:]pf::Kind regards,`nPhilip

; ]ty -> "Thank you"
:*:]ty::Thank you

; ]d -> current date as yyyy-MM-dd
::]d::
{
  CurrentDate := FormatTime(, "yyyy-MM-dd")
  SendInput(CurrentDate)
  return
}

; ]dt -> current date and time as yyyy-MM-dd HH:mm:ss
:*:]dt::
{
  CurrentDateTime := FormatTime(, "yyyy-MM-dd HH:mm:ss")
  SendInput(CurrentDateTime)
  return
}

; ]tt -> current time as HH:mm:ss
:*:]tt::
{
  CurrentDateTime := FormatTime(, "HH:mm:ss")
  SendInput(CurrentDateTime)
  return
}


; Control + Windows + O, copy the selected text (a file path) and open it in Neovim
^#o::
{
  Send("^c")
  A_Clipboard := "" ; Empty the clipboard
  Send("^c")
  Errorlevel := !ClipWait(2)
  if ErrorLevel
  {
    MsgBox("The attempt to copy text onto the A_Clipboard failed.")
    return
  }
  ;MsgBox, clipboard = %clipboard%

  Run("nvim `"" A_Clipboard "`"", , "")
  Return
}

; Clear console log with Ctrl+L and exit it with Ctrl+D
; -----------------------------------------------------------------------------
<^l::
{
  SetTitleMatchMode(2)
  if WinActive("ahk_class ConsoleWindowClass")
  {
    SendInput("^c")
    SendInput("cls{ENTER}")
    Return
  }
  Else SendInput("^l")
  Return
}

<^d::
{
  SetTitleMatchMode(2)
  if WinActive("ahk_class ConsoleWindowClass")
  {
    SendInput("^c")
    SendInput("exit{ENTER}")
    Return
  }
  Else SendInput("^d")
  Return
}

; ToggleTrack Edit
F6::
{
  Run("C:\Program Files\LINQPad8\LPRun8.exe `"G:\My Drive\Roaming\LinqPad\LinqPadQueries\Personal\Productivity\Toggl\EditDescription.linq`"")
  return
}

; Control + Windows + F7, activate Toggl Track and stop the running timer (sends Ctrl+S)
^#F7::
{
  SetTitleMatchMode("Regex")
  WinActivate("ahk_class HwndWrapper\[TogglDesktop.exe;;[\da-f\-]+\]")
  ErrorLevel := WinWaitActive("ahk_class HwndWrapper\[TogglDesktop.exe;;[\da-f\-]+\]"), ErrorLevel := ErrorLevel = 0 ? 1 : 0
  if WinActive("ahk_class HwndWrapper\[TogglDesktop.exe;;[\da-f\-]+\]")
  {
    Send("^s")
  }
  return
}

; Control + Windows + F8, activate Toggl Track and continue the last timer (sends Ctrl+O)
^#F8::
{
  SetTitleMatchMode("Regex")
  WinActivate("ahk_class HwndWrapper\[TogglDesktop.exe;;[\da-f\-]+\]")
  ErrorLevel := WinWaitActive("ahk_class HwndWrapper\[TogglDesktop.exe;;[\da-f\-]+\]"), ErrorLevel := ErrorLevel = 0 ? 1 : 0
  if WinActive("ahk_class HwndWrapper\[TogglDesktop.exe;;[\da-f\-]+\]")
  {
    Send("^o")
  }
  return
}
; --- Corral all Teams windows to Desktop 2 (Win+Shift+T) ---
#+t:: {
    Global VDADLL

    DetectHiddenWindows(true)

    movedCount := 0
    for hwnd in WinGetList("ahk_exe ms-teams.exe") {
        currentDesktop := DllCall(VDADLL '\GetWindowDesktopNumber', 'Ptr', hwnd, 'Int')
        if (currentDesktop != -1 && currentDesktop != 1) {  ; 1 = Desktop 2 (0-based)
            DllCall(VDADLL '\MoveWindowToDesktopNumber', 'Ptr', hwnd, 'Int', 1)
            movedCount++
        }
    }

    DetectHiddenWindows(false)

    GoToDesktop(2)

    if movedCount > 0
        TrayTip("Teams Corraller", "Moved " movedCount " Teams window(s) to Desktop 2", 2)
    else
        TrayTip("Teams Corraller", "All Teams windows already on Desktop 2", 2)
}

; ^#Left::
; {
;   Title := WinGetTitle("A")
;   WinSetExStyle("^0x80", Title)
;   Send("{LWin down}{Ctrl down}{Left}{Ctrl up}{LWin up}")
;   Sleep(50)
;   WinSetExStyle("^0x80", Title)
;   WinActivate(Title)
;   Return
; }

; ^#Right::
; {
;   Title := WinGetTitle("A")
;   WinSetExStyle("^0x80", Title)
;   Send("{LWin down}{Ctrl down}{Right}{Ctrl up}{LWin up}")
;   Sleep(50)
 
;   WinSetExStyle("^0x80", Title)
;   WinActivate(Title)
;   Return
; }