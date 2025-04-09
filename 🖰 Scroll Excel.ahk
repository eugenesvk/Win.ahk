#Requires AutoHotKey 2.1-alpha.4
; Launch via a Non UIA enabled client otherwise Excel is inaccessible
dbg                          	:= 0	; Level of debug verbosity (0-none)
dbgT                         	:= 2	; Timer for dbg messages (seconds)
USERPROFILE                  	:= EnvGet('userProfile')
shell                        	:= ComObject("Shell.Application")
A_HotkeyInterval             	:= 1000	; [2000]
A_MaxHotkeysPerInterval      	:= 200 	; [70]
CoordMode "ToolTip", "Screen"	; Place ToolTips at absolute screen coordinates
CoordMode "Mouse",   "Screen"	; Mouse cursor: get absolute scren coordinates
SetMouseDelay -1             	; [10]ms Delay after each mouse movement/click, -1=none

TraySetIcon("./img/🖰Scroll Excel.ico",0) ; Scroll icons created by Swifticons - Flaticon (flaticon.com/free-icons/scroll)

; ^!x:: { ;;; temporary fast reloads
;   Tooltip "🖰Scroll Excel Reloading!"
;   sleep(500)
;   SetTimer () => ToolTip(), -500 ; killed on Reload, but helpful if reload fails
;   Reload
;   }

#Include %A_scriptDir%\gVar\varWinGroup.ahk	; App groups for window matching
#Include %A_scriptDir%\gVar\var.ahk        	; Global variables (diacritic symbols and custom chars)
#Include <libFunc Scroll>                  	; Functions: Scrolling
#Include <libFunc Num>                     	; Functions: Numeric
#Include <libFunc Dbg>                     	; Functions: Debug
#Include <Array>                           	; Array helpers
#include <constKey>                        	; various key constants

; Scroll Left/Right with Shift+MouseWheel Up/Down
#HotIf WinActive("ahk_group ScrollH")
vk05:: SendInput '{LWin Down}'	;🖰G6​	vk05 ⟶ ❖ when down
~LShift & WheelUp::{          	;⌥🖱↑​	Scroll← (on Hover), ["Default"] parameters, |V|alues
  ; Clarification on ~and& autohotkey.com/boards/viewtopic.php?f=82&t=97264
    ; ~ doesn't block (hide from the system) key's native function
    ; & combines two keys/mouse buttons into a custom hotkey
    ; LCtrl & WheelUp requires LCtrl to be "physically" pressed, unless you change #InputLevel, whereas <^WheelUp requires LCtrl to be "logically" pressed.
    ; <^WheelUp requires RCtrl, LWin, RWin, Shift and Alt to not be pressed, whereas LCtrl & WheelUp and *<^WheelUp only require LCtrl to be pressed.
  ; 3 scroll methods: via 1. COM 2. Scrollbar control 3. Mouse Wheel
  ; apps sorted via   1. exe→COM 2. exeScrollH        3. all others
  Direction  	:= "L" 	; [L]  Scroll            |L|eft    / |R|ight
  ScrollHUnit	:= "Pg"	; [Pg] Move scrollbar by |Pg| page / |L|ine 'Rep' # of times
  Rep        	:=  1  	; [1]  Scroll speed multiplier with scrollbar (natural number)
  WheelHMult 	:=  1  	; [1]    ...                   with mouse Wheel
  MSOMult    	:=  1  	; [1]    ...                   for  MS Office (natural number)
  ScrollHCombo(Direction, ScrollHUnit,Rep, WheelHMult, MSOMult)
  }
~LShift & WheelDown::{	;⌥🖱↓​	Scroll→ (on Hover)
  ScrollHCombo("R", "Pg",Rep:=1, WheelHMult:=1, MSOMult:=1)
  }
#HotIf
