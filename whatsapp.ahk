; TODO:
;       . Learn the custom hotkey code and implement it
;       . Maybe also add un "un-hide" custom hotkey
;       . Wire up the GUIHandler to actuallys set preferences
;       . Write the .INI read and write bits
;       . Get someone on #ahkscripts to review the code
;       . Fix menu bug after double-clicking tray icon, another delayed left click is issued???


#Persistent
#NoTrayIcon

; Set mouse co-ordinates relative to active window 
CoordMode, Mouse, Window

OnExit("Quit")

; Global Variables
global _hwnd := ""
global _tray := False
global _gui  := False

global _esc     := True
global _close   := False
global _min     := True
global _custom  := False

; Const Variables
global MAX_CLOSE_BTN_WIDTH  := 42
global NML_CLOSE_BTN_WIDTH  := 44
global MAX_CLOSE_BTN_HEIGHT := 30
global NML_CLOSE_BTN_HEIGHT := 32

global MAX_MAX_BTN_WIDTH    := 44
global NML_MAX_BTN_WIDTH    := 44
global MAX_MAX_BTN_HEIGHT   := 30
global NML_MAX_BTN_HEIGHT   := 32

global MAX_MIN_BTN_WIDTH    := 44
global NML_MIN_BTN_WIDTH    := 44
global MAX_MIN_BTN_HEIGHT   := 30
global NML_MIN_BTN_HEIGHT   := 32

IfNotExist, %A_AppAata%\AppsWhat\prefs.ini
    msgbox, This is your first time running AppsWhat! `nPlease setup your preferences in the following screen.
    GUIHandler()
    return

; Contextual Hotkeys =================================================================

#IfWinActive ahk_exe WhatsApp.exe
Esc::
{
    if _esc {
        AssignHWND()
        BuildMenu()
        WinHide ahk_id %_hwnd%
    }
}
return

LButton::
{
    if _close or _min {
        if IsOverNonActiveWin() {
            Click
            return
        }
        Click Down
    }
}
return

LButton Up::
{
    if _close {
        if IsOverCloseButton() {
            AssignHWND()
            BuildMenu()
            WinHide ahk_id %_hwnd%
            MouseMove -100, 0, 0, R
            Click up
            MouseMove 100, 0, 0, R
            return
        } 
    }
    if _min {
        if IsOverMinButton() {
            AssignHWND()
            BuildMenu()
            WinHide ahk_id %_hwnd%
            MouseMove -100, 0, 0, R
            Click up
            MouseMove 100, 0, 0, R
            return
        }
    }
    Click Up
}
return
#IfWinActive

IsOverNonActiveWin() {
    MouseGetPos, , , mouse_id
    WinGet, active_id, ID, A
    return mouse_id != active_id
}

AssignHWND() {
    WinGet, active_id, ID, A
    _hwnd := active_id
    return
}

; Menu ==================================================================

BuildMenu() {
    if !_tray {
        Menu, Tray, Icon
        Menu, Tray, NoStandard
        
        Menu, PrefSub, Add, Open Gui Selector, GUIHandler
        Menu, PrefSub, Add
        Menu, PrefSub, Add, Esc to tray, EscHandler
        Menu, PrefSub, Add, Close to tray, CloseHandler
        Menu, PrefSub, Add, Minimize to tray, MinHandler
        Menu, PrefSub, Add
        Menu, PrefSub, Add, Custom Hotkey, CustomHotkey
        Menu, PrefSub, Default, Open Gui Selector
        
        Menu, Tray, Add, Open WhatsApp, Open
        Menu, Tray, Add 
        Menu, Tray, Add, Preferences, :PrefSub
        Menu, Tray, Add 
        Menu, Tray, Add, Exit, Quit

        Menu, Tray, Default, Open WhatsApp
        Menu, Tray, Tip, WhatsApp
        
        SetPreferences()
        
        _tray := True
        return
    }
    Menu, Tray, Icon
    return
}

; Menu Handler Functions ==========================================================

Open() {
    Menu, Tray, NoIcon
    WinShow ahk_id %_hwnd%
    WinActivate ahk_id %_hwnd%
    return
}

GUIHandler() {
    if !_gui {
        Gui, Add, Text, , Enable / Disable Tray Options:
        Gui, Add, Checkbox, , Esc to tray
        Gui, Add, Checkbox, , Close to tray
        Gui, Add, Checkbox, , Minimize to tray
        Gui, Add, Text, , Enter Custom Hotkey:
        Gui, Add, Hotkey, xm
        Gui, Add, CheckBox, x+5, WinKey
        Gui, Add, Button, default, OK
        Gui, Show, AutoSize Center, Setup
    }
    _gui := True
    return
}

EscHandler() {
    Menu, PrefSub, ToggleCheck, Esc to tray
    _esc := !_esc
    return
}

CloseHandler() {
    Menu, PrefSub, ToggleCheck, Close to tray
    _close := !_close
    return
}

MinHandler() {
    Menu, PrefSub, ToggleCheck, Minimize to tray
    _min := !_min
    return
}

CustomHotkey() {
    msgbox, yet to be implemented
    _custom := !_custom
    return
}

; Utility Functions ====================================================================

SetPreferences() {
    if _esc
        Menu, PrefSub, Check, Esc to tray
    if _close
        Menu, PrefSub, Check, Close to tray
    if _min
        Menu, PrefSub, Check, Minimize to tray
    return
}

IsOverCloseButton() {
    MouseGetPos, x, y
    WinGetPos, , , windowWidth, , A
    closeButtonWidth  := MAX_CLOSE_BTN_WIDTH
    closeButtonHeight := MAX_CLOSE_BTN_HEIGHT
    if IsWinMax() {
        x -= 8
        y -= 8
        windowWidth -= 17
    } else {
        closeButtonWidth  := NML_CLOSE_BTN_WIDTH
        closeButtonHeight := NML_CLOSE_BTN_HEIGHT
    }
    if (y >= 0) 
    and (y <= closeButtonHeight)
    and (x <= windowWidth)
    and (x >= windowWidth - closeButtonWidth)
        return True
    return False
}

IsOverMinButton() {
    MouseGetPos, x, y
    WinGetPos, , , windowWidth, , A
    closeButtonWidth    := MAX_CLOSE_BTN_WIDTH
    closeButtonHeight   := MAX_CLOSE_BTN_HEIGHT
    maxButtonWidth      := MAX_MAX_BTN_WIDTH
    maxButtonHeight     := MAX_MAX_BTN_HEIGHT
    minButtonWidth      := MAX_MIN_BTN_WIDTH
    minButtonHeight     := MAX_MIN_BTN_HEIGHT
    if IsWinMax() {
        x -= 8
        y -= 8
        windowWidth -= 17
    } else {
        closeButtonWidth    := NML_CLOSE_BTN_WIDTH
        closeButtonHeight   := NML_CLOSE_BTN_HEIGHT
        maxButtonWidth      := NML_MAX_BTN_WIDTH
        maxButtonHeight     := NML_MAX_BTN_HEIGHT
        minButtonWidth      := NML_MIN_BTN_WIDTH
        minButtonHeight     := NML_MIN_BTN_HEIGHT
    }
    if (y >= 0) 
    and (y <= minButtonHeight)
    and (x < windowWidth - (closeButtonWidth + 1 + maxButtonWidth))
    and (x >= windowWidth - (closeButtonWidth + 1 + maxButtonWidth + 1 + minButtonWidth))
        return True
    return False
}

IsWinMax() {
    WinGet, result, MinMax, A
    return (result = 1) ? True : False 
}

Quit() {
    WinShow ahk_id %_hwnd%
    WinActivate ahk_id %_hwnd%
    ExitApp
    ; Edit this to close WhatsApp in the final release
}

f12::listvars