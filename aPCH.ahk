#Requires AutoHotKey 2.1-alpha.4
; ————————————————————————— Key changes —————————————————————————————
  ; #Include %A_scriptDir%\Char-AltGr.ahk	; TypES layout on AltGr (diacritics built into LayoutDLL via DeadKeys)

  ~NumLock::NumLockReverse()	; Reverse NumLock LED indicator

/*        bugs with NumLock because Shift overrides NumLock state by default in Windows
  ~LShift::{
    KeyboardLED(4,"on")
    KeyWait LShift
    KeyboardLED(4,"off")
  }
  Return
*/

; moved to PC-only from aCommon due to conflict with Bootcamp
  ^Tab:: 	SendInput '{Ctrl Down}{Tab}{Ctrl Up}'                      	;^⭾​ 	vk09 ⟶ Ctrl+Tab Restore
  ^+Tab::	SendInput '{Ctrl Down}{Shift Down}{Tab}{Ctrl Up}{Shift Up}'	;⇧^⭾​	vk09 ⟶ Ctrl+Shift+Tab Restore
  ; ~LShift & WheelLeft::{   ; Scroll left (on Hover)
    ; ScrollHCombo("L", "Pg",Rep:=1, WheelHMult:=1, MSOMult:=1)
    ; }
  ; ~LShift & WheelRight::{ ; Scroll right (on Hover)
    ; ScrollHCombo("R", "Pg",Rep:=1, WheelHMult:=1, MSOMult:=1)
    ; }
