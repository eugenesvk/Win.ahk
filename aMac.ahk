#Requires AutoHotKey 2.1-alpha.4
; Ex| +VK33::	SendInput '{Raw}#'	;⇧3​	VK33 ⟶ # US number-sign	(U+0023)

; ————————————————————————— Key changes —————————————————————————————
#Include %A_scriptDir%\Char-AltGr.ahk	; TypES layout on AltGr (diacritics built into LayoutDLL via DeadKeys)

~NumLock::NumLockReverse()	; Reverse NumLock LED indicator

VK5C:: sendInput '{Appskey}'	;Substitute right Win with mouse right-click menu

;Adjust some hotkeys to make familiar Win combos^
  ^!VK08:: sendInput '{Delete}'  ;Control-Alt-BackSpace to Ctrl-Alt-Delete, works without {Control}{Alt}{Delete}'

;Adjust some hotkeys to make similar to Mac
  ^+VK4D:: 	WinMinimizeAll    	;[^+m] 	VK4D SC032 VK ⟶ [~❖m] Minimize all windows
  ^!+VK4D::	WinMinimizeAllUndo	;[^!+m]	VK4D SC032 VK ⟶ [~❖m] Restore minimized windows

;;;https://lexikos.github.io/v2/docs/Hotkeys.htm#AltTabDetail says alttab functions aren't affected by #HotIF
#HotIf !GetKeyState("Shift", "P")
  LCtrl & Tab::AltTab
#HotIf
; #HotIf GetKeyState("Shift", "P")
  ; LCtrl & Tab:: ShiftAltTab
; #HotIf

/*
;;;;#2 doesn't allow repeat https://www.autohotkey.com/boards/viewtopic.php?t=70379
; Remap Ctrl-Tab to Alt-Tab
^Tab::{
  Send '{Alt down}{Tab}'
  Keywait "Control"
  Send '{Alt up}'
  return
}

; Remap Ctrl-Shift-Tab to Alt-Shift-Tab
^+Tab::{
  Send '{Alt down}{Shift down}{Tab}'
  Keywait "Control"
  Send '{Alt up}'
  Send '{Shift up}'
  return
}
*/

/*
;;;#3 doesn't allow repeat https://www.autohotkey.com/boards/viewtopic.php?t=74958
; Remap Ctrl-Tab to Alt-Tab
^Tab::{
  Send '{Alt down}{Tab}'
  Keywait "Control"
  Send '{Alt up}'
  return
}
; Remap Ctrl-Shift-Tab to Alt-Shift-Tab
^+Tab::{
  Send '{Alt down}{Shift down}{Tab}'
  Keywait "Control"
  Send '{Alt up}'
  Send '{Shift up}'
}

LCtrl::{
  Send '{AltDown}'
  KeyWait A_ThisHotkey
  Send '{AltUp}'
  Return
}
LAlt::{
  Send '{CtrlDown}'
  KeyWait A_ThisHotkey
  Send '{CtrlUp}'
  Return
}
*/

  ; ^Tab:: SendInput '{Blind}{Alt Down}{Tab}{Alt Up}'

  ; Remap Ctrl-Tab to Alt-Tab (LCtrl & LAlt & Tab:: ShiftAltTab doesn't work as there is a 2-key limit)
  ; Add '{Blind}' at the start to safely release on Alt-Tab without window disappearing
  ;;; ^Tab:: sendInput '{LAlt Down}{Tab}'	;[^⭾]VK09 SC00F ⟶ [⌥⭾] App switcher
  #HotIf WinExist("ahk_class MultitaskingViewFrame")
    Ctrl Up::	sendInput '{LAlt Up}'		;[^↑]	VK26 SC148 ⟶ [⌥] to cancel Alt-Tab
  #HotIf

  ; ~^Tab::
  ;	MsgBox("$*Tab", "Debug commands", "T1")
  ;	Laltstate:=Getkeystate("Lalt", "P")
  ;	If (Laltstate = "D") {
  ;		Send '{Blind}{LAlt Down}{Tab}'
  ;		if (FixB =0) {
  ;			SendInput '{Tab}'
  ;		}
  ;		FixB := 1
  ;	}
  ;	Else {
  ;	  SendInput '{Blind}{Tab}'
  ;	}
  ; return

  ; ~$*LAlt up::
  ;	SendInput '{Blind}{LAlt Up}'
  ;	FixB := 0
  ; return

  ; $*Tab::
  ;	MsgBox("$*Tab", "Debug commands", "T1")
  ;	Laltstate:=Getkeystate("Lalt", "P")
  ;	If (Laltstate = "D") {
  ;		Send '{Blind}{LAlt up}{LWin down}{Tab}'
  ;		if (FixB =0) {
  ;			SendInput '{Tab}'
  ;		}
  ;		FixB := 1
  ;	}
  ;	Else {
  ;	  SendInput '{Blind}{Tab}'
  ;	}
  ; return

  ; ~$*LAlt up::
  ;	SendInput '{Blind}{Lwin up}'
  ;	FixB := 0
  ; return

  +VK08::{   ;Shift-BackSpace to Shift-Delete in Explorer and Delete outside of Explorer
    waclass:=WinGetClass("A")
    watitle:=WinGetTitle("A")
    If (waclass = "CabinetWClass") {
      SendInput '+{Delete}'
    }
    Else {
      SendInput '{Delete}'
    }
  Return
   }

;Text Navigation
  ; ^VK08::  	SendInput '{Delete}'                    	;Ctrl-BackSpace to Delete
  ; *+^VK08::	SendInput '{Ctrl Down}{Delete}{Ctrl Up}'	;Shift-Ctrl-BackSpace to Delete
  ^Up::      	SendInput '{Pgup}'                      	;[^↑]  VK26 SC148 ⟶ [⇞] VK21 SC149
  ^Down::    	SendInput '{Pgdn}'                      	;[^↓]  VK28 SC150 ⟶ [⇟] VK22 SC151
  ^+Up::     	SendInput '{Shift Down}{Pgup}{Shift Up}'	;Ctrl-Shift-ArrowUp to Shift-PageUp
  ^+Down::   	SendInput '{Shift Down}{Pgdn}{Shift Up}'	;Ctrl-Shift-ArrowDown to Shift-PageDown
  ^VK31::    	SendInput '^+{Tab}'                     	;[^1]	VK31	⟶ ^+⭾ (switch to left Tab)
  ^VK32::    	SendInput '^{Tab}'                      	;[^2]	VK32	⟶ ^⭾ (switch to right Tab)

  ; ^Right::    ;Ctrl-Right to Ctrl-Tab in Chrome and IE
  ;	wat:=WinGetClass("A")
  ;	watitle:=WinGetTitle("A")
  ;	If (wat = "Chrome_WidgetWin_1" or wat = "IEFrame") {
  ;		;If (wat = "ApplicationFrameWindow") too broad a class of window classes to use  ;or wat = "CabinetWClass"
  ;		SendInput '{Ctrl Down}{Tab}{Ctrl Up}'
  ;	}
  ;	Else {
  ;		; SendInput '{Ctrl Down}{Right}{Ctrl Up}'
  ;	}
  ;	FoundPos := InStr(watitle, "Microsoft Edge")
  ;	If(FoundPos > 0 ) {
  ;		SendInput '{Ctrl Down}{Tab}{Ctrl Up}'
  ;	}
  ;	Else {
  ;		SendInput '{Ctrl Down}{Right}{Ctrl Up}'
  ;	}
  ; Return
  ; ^Left::  ;Ctrl-Shift-Right to Ctrl-Tab in Chrome and IE
  ;	wat:=WinGetClass("A")
  ;	watitle:=WinGetTitle("A")
  ;	If (wat = "Chrome_WidgetWin_1" or wat = "IEFrame") {  ;or wat = "CabinetWClass")
  ;		SendInput '{Ctrl Down}{Shift Down}{Tab}{Shift Up}{Ctrl Up}'
  ;	}
  ;	Else {
  ;		; SendInput '{Ctrl Down}{Left}{Ctrl Up}'
  ;	}
  ;	FoundPos := InStr(watitle, "Microsoft Edge")
  ;	If(FoundPos > 0 ) {
  ;			SendInput '{Ctrl Down}{Shift Down}{Tab}{Shift Up}{Ctrl Up}'
  ;	}
  ;	Else {
  ;			SendInput '{Ctrl Down}{Left}{Ctrl Up}'
  ;	}
  ; Return

  ; !Right::  ;Alt-Right to Ctrl-Tab in Chrome and IE
  ;	wat:=WinGetClass("A")
  ;	If (wat = "Chrome_WidgetWin_1" or wat = "IEFrame") {
  ;		SendInput '{Ctrl Down}{Tab}{Ctrl Up}'
  ;	}
  ;	Else {
  ;		SendInput '{Ctrl Down}{Right}{Ctrl Up}'
  ;	}
  ;	Return

  ^!Left:: 	SendInput '^+{Tab}'	;[^⌥←] ⟶ Tab Left
  ^!Right::	SendInput '^{Tab}' 	;[^⌥→] ⟶ Tab Right
  ; !Left::                       ;Alt-Left to Ctrl-Shift-Tab in Chrome and IE
  ;	wat:=WinGetClass("A")
  ;	If (wat = "Chrome_WidgetWin_1" or wat = "IEFrame") {
  ;		SendInput '{Ctrl Down}{Shift Down}{Tab}{Shift Up}{Ctrl Up}'
  ;	}
  ;	Else {
  ;		SendInput '{Ctrl Down}{Left}{Ctrl Up}'
  ;	}
  ; Return
  ; !+Right:: ;Alt-Shift-Right to Alt-Right in Chrome and IE
  ;	wat:=WinGetClass("A")
  ;	If (wat = "Chrome_WidgetWin_1" or wat = "IEFrame") {
  ;	SendInput '{Alt Down}{Right}{Alt Up}'
  ;	}
  ;	Else {
  ;	SendInput '{Alt Down}{Shift Down}{Right}{Shift Up}{Alt Up}'
  ;	}
  ; Return
  ; !+Left::  ;Alt-Shift-Left to Alt-Left in Chrome and IE
  ;	wat:=WinGetClass("A")
  ;	If (wat = "Chrome_WidgetWin_1" or wat = "IEFrame") {
  ;		SendInput '{Alt Down}{Left}{Alt Up}'
  ;	}
  ;	Else {
  ;		SendInput '{Alt Down}{Shift Down}{Left}{Shift Up}{Alt Up}'
  ;	}
  ; Return

;Internet

;Multimedia
  $F10::  	sendInput '{Volume_Mute}'	; Mute/unmute the master volume.
  $^F10:: 	sendInput '{F10}'
  $F11::  	sendInput '{Volume_Down}'                  	; Raise the master volume by 1 interval (typically 5%).
  $^F11:: 	sendInput '{F11}'                          	; Ctrl-F11 to F11
  $F12::  	sendInput '{Volume_Up}'                    	; Lower the master volume by 1 intervals.
  $!+F12::	sendInput '{PrintScreen}'                  	; Alt-Shitf-F12 to PrintScreen
  $!F12:: 	sendInput '{Alt Down}{PrintScreen}{Alt Up}'	; Alt-F12 to Alt-PrintScreen
  $F7::   	sendInput '{Media_Prev}'
  $^F7::  	sendInput '{F7}'
  $F8::   	sendInput '{Media_Play_Pause}'
  $^F8::  	sendInput '{F8}'
  $F9::   	sendInput '{Media_Next}'
  $^F9::  	sendInput '{F9}'

;System


; ————————————————————————— App-specific hotkeys —————————————————————————
#HotIf WinActive("ahk_exe sublime_text.exe") ; ⇧+⇪ opens Command Palette
#HotIf
#HotIf WinActive("ahk_group TextEditor")     ;Text Navigation
  ; { "description"	: "    LCtrl+1/2 (^1/2) ⟶ Home/End (⇱/⇲)",
  ; ^VK31::        	SendInput '{Home}'                      	;[^1]	VK31	⟶ [⇱]
  ; ^VK32::        	SendInput '{End}'                       	;[^2]	VK32	⟶ [⇲]
  ^VK33::          	SendInput '{Home}'                      	;[^3]	VK34	⟶ [⇱]
  ^VK34::          	SendInput '{End}'                       	;[^4]	VK35	⟶ [⇲]
  ; ^VK08::        	SendInput '{Delete}'                    	;Ctrl-BackSpace to Delete
  ; *+^VK08::      	SendInput '{Ctrl Down}{Delete}{Ctrl Up}'	;Shift-Ctrl-BackSpace to Delete
  ^Up::            	SendInput '{Pgup}'                      	;Ctrl-ArrowUp to PageUp
  ^Down::          	SendInput '{Pgdn}'                      	;Ctrl-ArrowDown to PageDown
  ^+Up::           	SendInput '{Shift Down}{Pgup}{Shift Up}'	;Ctrl-Shift-ArrowUp to Shift-PageUp
  ^+Down::         	SendInput '{Shift Down}{Pgdn}{Shift Up}'	;Ctrl-Shift-ArrowDown to Shift-PageDown
#HotIf

#HotIf WinActive("ahk_class #32770") ; ^d to pass 'N' to dialogue windows
  ^VK44::	SendInput 'n'	;[^d]	VK44 SC020 ⟶ [⌥n]
#HotIf

#HotIf WinActive("ahk_exe dopus.exe") ;Ctrl←→/⌘←→ navigate to the left/right tab
  ;#HotIf, ahk_class HwndWrapper[DefaultDomain;;2d58ffd7-2857-405f-9298-df01cb46d314]
  ^VK08:: sendInput '{Delete}'  ;[^⌫] ⟶ ⌦
  ^VK31::SendInput '^+{Tab}'	;[⌥1]	VK31 ⟶ ^+⭾ Previous Tab
  ^VK32::SendInput '^{Tab}' 	;[⌥2]	VK32 ⟶ ^+⭾ Next Tab
#HotIf

; ————————————————————————— Mouse changes ———————————————————————————
  ;;;bugs, check out
  WheelLeft::{                            ; Scroll Left
    if WinActive("ahk_exe EXCEL.EXE") {  ;ahk_class XLMAIN; ahk_exe EXCEL.EXE
      SetScrollLockState(1)
      Send '{Left}'
      SetScrollLockState "AlwaysOff"
      sleep 50
      KeyboardLED("NumLock",0) ; NumLock turns on when ScrollLock state changes
    } else if WinActive("Adobe Acrobat Professional") {
      SendInput '+{Left}'
    } else if WinActive("- Mozilla Firefox") {
      SendInput '{Left 4}'
    } else {
      FocusedControl := ControlGetFocus("A")
      ;;;Loop 4
      ;;;  SendMessage(0x114, 0, 0, FocusedControl, "A")  ; 0x114=WM_HSCROLL, 1/0=SB_LINEDOWN/UP
    }
  }

  WheelRight::{                           ; Scroll Right
    if WinActive("ahk_exe EXCEL.EXE") {  ;ahk_class XLMAIN; ahk_exe EXCEL.EXE
      SetScrollLockState(1)
      Send '{Right}'
      SetScrollLockState "AlwaysOff"
      sleep 50
      KeyboardLED("NumLock",0) ; NumLock turns on when ScrollLock state changes
    } else if WinActive("Adobe Acrobat Professional") {
      SendInput '+{Rigth}'
    } else if WinActive("- Mozilla Firefox") {
      SendInput '{Rigth 4}'
    } else {
      FocusedControl := ControlGetFocus("A")
      ;;;Loop 4
      ;;;  SendMessage(0x114, 1, 0, FocusedControl, "A")  ; 0x114=WM_HSCROLL, 1/0=SB_LINEDOWN/UP
    }
  }
