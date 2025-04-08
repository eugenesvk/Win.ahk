#Requires AutoHotKey 2.1-alpha.4
; ————————————————————————— Mouse changes ———————————————————————————
; Navigate
  ; !WheelUp::  	SendInput '{PgUp}'	;⌥🖱↑​	vk9F ⟶ ↑×15 (half PgUp)
  ; !WheelDown::	SendInput '{PgDn}'	;⌥🖱↓​	vk9E ⟶ ↓×15 (half PgDn)
  ^!WheelUp::   	SendInput '{PgUp}'	;⌥🖱↑​	vk9F ⟶ PgUp
  ^!WheelDown:: 	SendInput '{PgDn}'	;⌥🖱↓​	vk9E ⟶ PgDn

*XButton2::	SendInput("{Backspace}"	) ; Set🖰G​4​ XButton2 ⟶␈
*XButton1::	SendInput("{Enter}"    	) ; Set🖰G​5​ XButton1 ⟶⏎
; #HotIf WinActive("ahk_class ApplicationFrameWindow") And WinActive("ahk_exe ApplicationFrameHost.exe") And WinActive("Readiy") ;[App Readiy]
;   XButton1::  SendInput '{Left}' ;[G6/G7] G700s mouse to ←→ (for switching to previous/next article)
;   XButton2::  SendInput '{Right}'
; #HotIf
; #HotIf WinActive("ahk_group WinTerm") ; Windows Terminal
;   XButton1::  SendInput '^+{Tab}' ;🖰G​7​  vk05 ⟶ ^⇧⭾ previous tab
;   XButton2::  SendInput '^{Tab}'  ;🖰G​6   vk06 ⟶ ^⭾ next tab
; #HotIf

; Tab Left/Right with mouse top 2 buttons on the left side
  #HotIf !WinActive("ahk_group Games")
  ; remap G7 mouse key to ❖ on hold (to use for AltDrag window functions)
  ; vk05::    	SendInput '{LWin Down}'	;🖰G6​	vk05 ⟶ ❖ when down
  ; vk05 Up::{	                       	;🖰G6​	vk05 ⟶ 🖰G6​ when up
  ;   if (A_PriorKey="LControl") { ; should be vk9A vk9B (LMB/RMB), not sure why "LControl", maybe AltDrag passes it?
  ;     SendInput '{LWin Up}'
  ;   } else {
  ;     SendInput '{LWin Up}{vk05 Down}{vk05 Up}'
  ;   }
  ;   }
  ; +XButton1::	SendInput '{LCtrl down}{LShift down}{Tab}{LShift up}{LCtrl up}'	;⇧G6​	vk05 ⟶ 000	()
  ; +XButton2::	SendInput '{LCtrl down}{Tab}{LCtrl up}'                        	;⇧G7​	vk06 ⟶ 000	()
  ; ^XButton1::	SendInput '{LCtrl down}{LShift down}{Tab}{LShift up}{LCtrl up}'	;^G6​	vk05 ⟶ 000	()
  ; ^XButton2::	SendInput '{LCtrl down}{Tab}{LCtrl up}'                        	;^G7​	vk06 ⟶ 000	()
  #HotIf

; Scroll Left/Right with Shift+MouseWheel Up/Down
  #HotIf not WinActive("ahk_group ScrollH") ; avoid conflict with non-UIA version
  ~LShift & WheelUp::{   ; Scroll left (on Hover), ["Default"] parameters, |V|alues
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
  ~LShift & WheelDown::{ ; Scroll right (on Hover)
    ScrollHCombo("R", "Pg",Rep:=1, WheelHMult:=1, MSOMult:=1)
    }
  ; ~LShift & WheelLeft ; moved to PC-only @aWin.ahk due to conflict with Bootcamp
  #HotIf
#HotIf WinActive("ahk_class Photoshop") ;[App Photoshop]
  ~LShift & WheelUp::  	^WheelUp
  ~LShift & WheelDown::	^WheelDown
#HotIf

^WheelUp::return
^WheelDown::return
#WheelUp::^WheelUp
#WheelDown::^WheelDown
