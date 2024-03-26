#Requires AutoHotKey 2.1-alpha.4
; remap capslock to hyper if capslock is toggled, remap it to esc
SetCapsLockState "AlwaysOff"  ;[CapsLock] disable

#HotIf !WinActive("ahk_group Games") ; disable in Games
class c⇪ {
  static _ := 0
  , ↑ 	:= 1
  , 🕐↓	:= 0
}
Capslock::{ ; set time of the first down event to track when hold duration
  if c⇪.↑ {
    c⇪.🕐↓ := A_TickCount
    c⇪.↑ := 0
  }
}
Capslock Up::{                   ; ~not fire a hotkey until it's released
  c⇪.↑ := 1
  ; ↓ not needed? DownTemp=Down except for ⇧◆⎇⎈, where it tells subsequent sends that the key is not permanently down, and may be released whenever a keystroke calls for it: Send {Ctrl DownTemp}, Send {Left} ⟶ ←, not ⎈← keystroke
  ; SendInput '{Ctrl DownTemp}{Shift DownTemp}{Alt DownTemp}{LWin DownTemp}'
  ; SendInput '{Ctrl Up}{Shift Up}{Alt Up}{LWin Up}'
  if (A_PriorKey = "Capslock") { ;⇪​	vk14 ⟶ k (vk4B) Run Keypirinha on single ⇪ press
    if (c⇪.🕐Δ := A_TickCount - c⇪.🕐↓) < 500 {
      SendInput '^+!#{vk4B}'
    }
  } ; if '~' is applied to a custom modifier key (prefix key) which is also used as its own hotkey, that hotkey will fire when the key is pressed instead of being delayed until the key is released
  c⇪.🕐↓ := 0
  }
#vk14::{                             ;◆⇪​	vk14 ⟶ Activate CapsLock
  if GetKeyState("vk14","T") = 1 {
    SetCapsLockState "AlwaysOff"
  } else {
    SetCapsLockState "AlwaysOn"
  }
  }
+CapsLock::{                          ;[+⇪] to ^⇧⌥L to launch/activate Listary
  if ProcessExist("Listary.exe") {
    SendInput '{Ctrl Down}{Shift Down}{Alt Down}{l}{Ctrl Up}{Shift Up}{Alt Up}'   ;[l] vk4C SC026
  } else {
    SendInput '{LShift Down}'  ; Replace CapsLock with Shift
  }
  }
;CapsLock Up::SendInput '{LShift Up}'   ;[CapsLock] replace with Shift, second part (if no Launcher running)
;CapsLock::                              ;⇪ to ^⇧⌥K to launch/activate Keypirinha
;  If ProcessExist("keypirinha-x64.exe") {
;    SendInput '{Ctrl Down}{Shift Down}{Alt Down}{vk4B}{Ctrl Up}{Shift Up}{Alt Up}'  ;[k] vk4B SC025
;    ;SendInput '{Alt Down}{Space}{Alt Up}'
;    ;vk14::SendInput '{Alt Down}{Space Down}{Space Up}{Alt Up}'
;    ;vk14::SendInput '{Alt Down}{Space Down}'
;    ;vk14 up::SendInput '{Alt Up}{Space Up}'
;    } Else {
;      SendInput '{LShift Down}'         ; Replace CapsLock with Shift
;      }
;  Return
; ^CapsLock::{                             ;[^⇪] to ^⇧⌥W to launch/activate Wox
;   if ProcessExist("Wox.exe") {
;     SendInput '{Ctrl Down}{Shift Down}{Alt Down}{w}{Ctrl Up}{Shift Up}{Alt Up}' ;vk57
;     } else {
;       SendInput '{LShift Down}'  ; Replace CapsLock with Shift
;       }
;   }


;  On [CapsLock] key press/release --> trigger Wox launcher through [Alt]+[Space]
; "Hyperkey" bindings
  ;CapsLock & l::SendInput(GetKeyState("Shift", "P") ? '{F2}' : '$')  ;[l] vk4C SC026
  ;CapsLock & k::
  ;  if GetKeyState("Shift", "P")
  ;    Send('{F2}')
  ;  else
  ;    Send('$')
  ;  Return
  ~CapsLock & vk57::RunActivMin(AppWire)        	;⇪w​	vk57 ⟶ Run App
  ~CapsLock & vk45::RunActivMin(App.ST*)        	;⇪e​	vk45 ⟶ Run App
  ~CapsLock & vk52::RunActivMin(App.VivaldiX*)  	;⇪r​	vk52 ⟶ Run App
  ~CapsLock & vk54::Run('"' AppWezTerm '"')     	;⇪t​	vk54 ⟶ Run App
  ~CapsLock & vk56::RunActivMin(AppVivaldi)     	;⇪v​	vk56 ⟶ Run App
  ~CapsLock & vk51::RunActivMin(App.DOpus*)     	;⇪q​	vk51 ⟶ Run App
  ~CapsLock & vk44::RunActivMin(App.DOpus*)     	;⇪d​	vk44 ⟶ Run App
  ~CapsLock & vk46::RunActivMin(App.DOpus*)     	;⇪f​	vk46 ⟶ Run App
  ~CapsLock & vk53::RunActivMin(App.Everything*)	;⇪s​	vk53 ⟶ Run App
  ~CapsLock & vk43::RunActivMin(AppWezTerm)     	;⇪c​	vk43 ⟶ Run App
  ~CapsLock & vk58::RunActivMin(AppExcel)       	;⇪x​	vk58 ⟶ Run App
  ; ~CapsLock & vk43::RunActivMin(AppConEmu)    	;⇪c​	vk43 ⟶ Run App
  ; ~CapsLock & vk54::Run('"' AppConEmu '"')    	;⇪t​	vk54 ⟶ Run App

; Toggle Window Title Bar ()
  ~CapsLock & vkBD::WinSetStyle("-" WS_Borderless, "A")  ;⇪-​	vkBD ⟶ Window Title Bar Off
  ~CapsLock & vkBB::WinSetStyle("+" WS_Borderless, "A")  ;⇪=​	vkBB ⟶ Window Title Bar On

; Navigation
  ~CapsLock & Left:: 	SendInput '^+{Tab}'	;⇪←​	vk25 ⟶ ^⇧⭾ Tab Left
  ~CapsLock & Right::	SendInput '^{Tab}' 	;⇪→​	vk27 ⟶ ^⭾ Tab Rigth
  ; Cursor
  ~CapsLock & vk4A:: SendInput '{Blind}{Down}' 	;⇪j​ vk4A ⟶ ← Arrow Down  (with mods)
  ~CapsLock & vk4B:: SendInput '{Blind}{Up}'   	;⇪k​ vk4B ⟶ → Arrow Up    (with mods)
  ~CapsLock & vk4C:: SendInput '{Blind}{Left}' 	;⇪l​ vk4C ⟶ ↑ Arrow Left  (with mods)
  ~CapsLock & vkBA:: SendInput '{Blind}{Right}'	;⇪;​ vkBA ⟶ ↓ Arrow Right (with mods)

  ~CapsLock & vk4D:: SendInput '{Blind}{PgDn}'	;⇪m​ vk4D ⟶ ⇟ Page Down   (with mods)
  ~CapsLock & vkBC:: SendInput '{Blind}{PgUp}'	;⇪,​ vkBC ⟶ ⇞ Arrow Up    (with mods)

  ; ~CapsLock & vk4A:: SendInput '{Blind}{Left}' 	;⇪j​ vk4A ⟶ ← Arrow Left  (with mods)
  ; ~CapsLock & vk4B:: SendInput '{Blind}{Down}' 	;⇪k​ vk4B ⟶ → Arrow Down  (with mods)
  ; ~CapsLock & vk4C:: SendInput '{Blind}{Up}'   	;⇪l​ vk4C ⟶ ↑ Arrow Up    (with mods)
  ; ~CapsLock & vkBA:: SendInput '{Blind}{Right}'	;⇪;​ vkBA ⟶ ↓ Arrow Right (with mods)

  ; not sure why this is needed and how it's different from the much simpler {Blind} mode
  ; ~CapsLock & vk4A::	cursorKey("{Left}") 	;⇪j​ vk4A ⟶ ← Arrow Left  (with mods)
  ; ~CapsLock & vk4B::	cursorKey("{Down}") 	;⇪k​ vk4B ⟶ → Arrow Down  (with mods)
  ; ~CapsLock & vk4C::	cursorKey("{Up}")   	;⇪l​ vk4C ⟶ ↑ Arrow Up    (with mods)
  ; ~CapsLock & vkBA::	cursorKey("{Right}")	;⇪;​ vkBA ⟶ ↓ Arrow Right (with mods)
  cursorKey(Arrow:="{Left}") {
    if        GetKeyState("Shift","P") and GetKeyState("Ctrl","P") and GetKeyState("Alt","P") {
      SendInput '+^!' Arrow
    } else if GetKeyState("Shift","P") and GetKeyState("Ctrl","P") {
      SendInput '+^'  Arrow
    } else if GetKeyState("Shift","P")                             and GetKeyState("Alt","P") {
      SendInput '+!'  Arrow
    } else if                              GetKeyState("Ctrl","P") and GetKeyState("Alt","P") {
      SendInput '^!'  Arrow
    } else if GetKeyState("Shift","P") {
      SendInput '+'   Arrow
    } else if                              GetKeyState("Ctrl","P") {
      SendInput '^'   Arrow
    } else if                                                          GetKeyState("Alt","P") {
      SendInput '!'   Arrow
    } else {
      SendInput       Arrow
    }
    }

; Popular hotkeys
  ; ~CapsLock & c:: SendInput '{Ctrl}{c}'  ;[⇪c] vk43 SC02E
  ; ~CapsLock & v:: SendInput '{Ctrl}{v}'  ;[⇪v] vk56 SC02F
#HotIf

;;; Check this alternative impelementation from KB-Caps-Nav.ahk
; or this autohotkey.com/boards/viewtopic.php?f=76&t=83471
; $Capslock::
;   Gui, 93:+Owner ; prevent display of taskbar button
;   Gui, 93:Show, y-99999 NA, "Enable nav-hotkeys: jikl"
;   SendInput {LCtrl Down}
;   KeyWait "Capslock" ; wait until the Capslock button is released
;   Gui, 93:Cancel
;   Send '{LCtrl Up}'
; Return

; #HotIf WinExist("Enable nav-hotkeys: jikl")
;   *j::SendInput '{Blind}{LCtrl Up}{Left}{LCtrl Down}'
;   *i::SendInput '{Blind}{LCtrl Up}{Up}{LCtrl Down}'
;   *k::SendInput '{Blind}{LCtrl Up}{Down}{LCtrl Down}'
;   *l::SendInput '{Blind}{LCtrl Up}{Right}{LCtrl Down}'
; #HotIf ; end context-sensitive block

/*
  ; Alternatives
  SendInput '{Ctrl Down}{Shift Down}{Alt Down}{vk4B}{Ctrl Up}{Shift Up}{Alt Up}'   ;[k] vk4B SC025
  ; Keypirinha.ini sets `hotkey_run = Ctrl+Shift+Win+Alt+Space`
  SendInput '{Ctrl Down}{Shift Down}{LWin Down}{Alt Down}{vk20}{Ctrl Up}{Shift Up}{LWin Up}{Alt Up}'   ;[ ](space) vk20 SC039
  ; Keypirinha.ini sets `hotkey_run = Ctrl+Shift+Win+Alt+K`
  SendInput '{Ctrl Down}{Shift Down}{LWin Down}{Alt Down}{vk4B}{Ctrl Up}{Shift Up}{LWin Up}{Alt Up}'   ;[k] vk4B SC025
  SendInput '{Ctrl}{Shift}{Alt}{vk20}'
  SendInput '{Ctrl}{Shift}{Alt}{vk4B}'
  SendInput '+^#!{vk20}'
  SendInput '{vk4B}' ;
  SendInput '{Esc}'
*/
