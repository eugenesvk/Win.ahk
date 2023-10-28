#Requires AutoHotKey 2.0.10
;PressH_ChPick function located in /lib
#MaxThreadsPerHotkey 2 ; 2 Allows A₁BA₂ fast typing, otherwise A₂ doesn't register
#InputLevel 1          ; Set the level for the following hotkeys so that they can activate lower-level hotstrings (autohotkey.com/docs/commands/SendLevel.htm)

#Hotif WinActive("ahk_group PressnHold")
;Use SendEvent for SpecialChars-Alt to recognize keys
; TimerHold defined in AES section of aCommon.ahk
;Diacritic
$a::                           ;[a] VK41
$+a::{
  SendEvent('{blind}{VK41 down}{VK41 up}')
  ShiftState := GetKeyState("Shift")  ; {blind} to retain Shift position
  if (KeyWait("VK41", TimerHold) = 0) {
    if ShiftState = 1 {
      PressH_ChPick(Dia["A"])
    } else {
      PressH_ChPick(Dia["a"])
    }
    Return
  } ; Else SendEvent('{VK41 up}')
  }

$b::                           ;[b] VK42
$+b::{
  SendEvent('{blind}{VK42 down}{VK42 up}')
  ShiftState := GetKeyState("Shift")  ; {blind} to retain Shift position
  if (KeyWait("VK42", TimerHold) = 0) {
    if ShiftState = 1 {
      PressH_ChPick(Ch["Misc"],,"b")
    } else {
      PressH_ChPick(Ch["Bullet"],,"b")
    }
    Return
  } ; Else SendEvent('{VK42 up}')
  }

$c::                          ;[c] VK43
$+c::{
  SendEvent('{blind}{VK43 down}{VK43 up}')
  ShiftState := GetKeyState("Shift")
  if (KeyWait("VK43", TimerHold) = 0) {
    if ShiftState = 1 {
      PressH_ChPick(Dia["C"])
    } else {
      PressH_ChPick(Dia["c"])
    }
    Return
  } ; Else SendEvent('{VK43 up}')
  }
$/::                          ;[/] vkBF
$+/::{
  SendEvent('{blind}{vkBF down}{vkBF up}')
  ShiftState := GetKeyState("Shift")
  if (KeyWait("vkBF", TimerHold) = 0) {
    if ShiftState = 1 {
      PressH_ChPick(Ch["WinFile"],Ch["WinFileLab"],"/")
    } else {
      PressH_ChPick(Ch["WinFile"],Ch["WinFileLab"],"/")
    }
    Return
  } ; else SendEvent('{vkBF up}')
  }
; $d::                          ;[d] VK44
; $+d::{
;   SendEvent('{blind}{VK44 down}{VK44 up}')
;   ShiftState := GetKeyState("Shift")
;   if (KeyWait("VK44", TimerHold) = 0) {
;     if ShiftState = 1 {
;       PressH_ChPick(Ch["WinFile"],Ch["WinFileLab"],"d")
;     } else {
;       PressH_ChPick(Ch["WinFile"],Ch["WinFileLab"],"d")
;     }
;     Return
;   } ; else SendEvent('{VK44 up}')
;   Return
; $e::                          ;[e] VK45
$+e::{
  SendEvent('{blind}{VK45 down}{VK45 up}')
  ShiftState := GetKeyState("Shift")
  if (KeyWait("VK45", TimerHold) = 0) {
    if ShiftState = 1 {
      PressH_ChPick(Dia["E"])
    } else {
      PressH_ChPick(Dia["e"])
    }
    Return
  } ; Else SendEvent('{VK45 up}')
  }
#HotIf

#Hotif WinActive("ahk_group PressnHold") and !WinActive("ahk_group Browser") ; exclude Vivaldi to allow using vimium jkl;
$i::                          ;[i] VK49
$+i::{
  SendEvent('{blind}{VK49 down}{VK49 up}')
  ShiftState := GetKeyState("Shift")
  if (KeyWait("VK49", TimerHold) = 0) {
    if ShiftState = 1 {
      PressH_ChPick(Dia["I"])
    } else {
      PressH_ChPick(Dia["i"])
    }
    Return
  } ; Else SendEvent('{VK49 up}')
  }
#HotIf

#Hotif WinActive("ahk_group PressnHold") and !WinActive("ahk_group Browser") ; exclude Vivaldi to allow using vimium jkl;
$l::                          ;[l] VK4C
$+l::{
  SendEvent('{blind}{VK4C down}{VK4C up}')
  ShiftState := GetKeyState("Shift")
  if (KeyWait("VK4C", TimerHold) = 0) {
    if ShiftState = 1 {
      PressH_ChPick(Dia["L"])
    } else {
      PressH_ChPick(Dia["l"])
    }
    Return
  } ; Else SendEvent('{VK4C up}')
  }
#HotIf

#Hotif WinActive("ahk_group PressnHold")
$n::                          ;[n] VK4E
$+n::{
  SendEvent('{blind}{VK4E down}{VK4E up}')
  ShiftState := GetKeyState("Shift")
  if (KeyWait("VK4E", TimerHold) = 0) {
    if ShiftState = 1 {
      PressH_ChPick(Dia["N"])
    } else {
      PressH_ChPick(Dia["n"])
    }
    Return
  } ; Else SendEvent('{VK4E up}')
  }
$o::                          ;[o] VK4F
$+o::{
  SendEvent('{blind}{VK4F down}{VK4F up}')
  ShiftState := GetKeyState("Shift")
  if (KeyWait("VK4F", TimerHold) = 0) {
    if ShiftState = 1 {
      PressH_ChPick(Dia["O"])
    } else {
      PressH_ChPick(Dia["o"])
    }
    Return
  } ; Else SendEvent('{VK4F up}')
  }
$s::                          ;[s] VK53
$+s::{
  SendEvent('{blind}{VK53 down}{VK53 up}')
  ShiftState := GetKeyState("Shift")
  if (KeyWait("VK53", TimerHold) = 0) {
    if ShiftState = 1 {
      PressH_ChPick(Dia["S"])
    } else {
      PressH_ChPick(Dia["s"])
    }
    Return
  } ; Else SendEvent('{VK53 up}')
  }
$u::                          ;[u] VK55
$+u::{
  SendEvent('{blind}{VK55 down}{VK55 up}')
  ShiftState := GetKeyState("Shift")
  if (KeyWait("VK55", TimerHold) = 0) {
    if ShiftState = 1 {
      PressH_ChPick(Dia["U"])
    } else {
      PressH_ChPick(Dia["u"])
    }
    Return
  } ; Else SendEvent('{VK55 up}')
  }
$y::                          ;[y] VK59
$+y::{
  SendEvent('{blind}{VK59 down}{VK59 up}')
  ShiftState := GetKeyState("Shift")
  if (KeyWait("VK59", TimerHold) = 0) {
    if ShiftState = 1 {
      PressH_ChPick(Dia["Y"])
    } else {
      PressH_ChPick(Dia["y"])
    }
    Return
  } ; Else SendEvent('{VK59 up}')
  }
/*;;;temporary disabled while testing a function
$z::                          ;[z] VK5A
$+z::{
  SendEvent('{blind}{VK5A down}{VK5A up}')
  ShiftState := GetKeyState("Shift")
  if (KeyWait("VK5A", TimerHold) = 0) {
    if ShiftState = 1 {
      PressH_ChPick(Dia["Z"])
    } else {
      PressH_ChPick(Dia["z"])
    }
    Return
  } ; Else SendEvent('{VK5A up}')
  }
*/
;Alternative characters (math, currency etc.)
;—————————————————————————————————————————————
$q::{                        ;[q] VK51
  SendEvent('{VK51 down}{VK51 up}')   ; or use {blind} to retain Alt/Shift/Ctrl positions)
  if (KeyWait("VK51", TimerHold) = 0) {            ; Wait for the user to release
    PressH_ChPick(Ch["XSymbols"],Ch["XSymbolsLab"],"q")
  }
  }
$+VK34::{                      ;[$] VK34
  SendEvent('{blind}{VK34 down}{VK34 up}')
  if (KeyWait("VK34", TimerHold) = 0) {
    PressH_ChPick(Ch["Currency"],Ch["CurrLab"],"$")
  }
  }
$h::{                       ;[h] VK48, was d VK44
  SendEvent('{VK48 down}{VK48 up}')
  if (KeyWait("VK48", TimerHold) = 0) {
    PressH_ChPick(Ch["Currency"])
  }
  }
; $w::{                       ;[w] VK57
;   SendEvent('{VK57 down}{VK57 up}')
;   if (KeyWait("VK57", TimerHold) = 0) {
;     PressH_ChPick(Ch["Arrows"],Ch["ArrowsLab"],"w")
;   }
;   }
$x::{                       ;[x] VK58
  SendEvent('{VK58 down}{VK58 up}')
  if (KeyWait("VK58", TimerHold) = 0) {
    PressH_ChPick(Ch["Tech"],Ch["TechLab"],"x")
  }
  }
$t::{                       ;[t] VK54
  SendEvent('{VK54 down}{VK54 up}')
  if (KeyWait("VK54", TimerHold) = 0) {
    PressH_ChPick(Ch["Math"],Ch["MathLab"],"t")
  }
  }
$f::{                       ;[f] VK46
  SendEvent('{VK46 down}{VK46 up}')
  if (KeyWait("VK46", TimerHold) = 0) {
    PressH_ChPick(Ch["Fractions"],,"ff")
  }
  }
$v::{                       ;[v] VK56
  SendEvent('{VK56 down}{VK56 up}')
  if (KeyWait("VK56", TimerHold) = 0) {
    PressH_ChPick(Ch["Subscript"],Ch["SubLab"],"v")
  }
  }
$g::{                       ;[g] VK47
  SendEvent('{VK47 down}{VK47 up}')
  if (KeyWait("VK47", TimerHold) = 0) {
    PressH_ChPick(Ch["Superscript"],Ch["SupLab"],"g")
  }
  }
; $m::{                       ;[m] VK4D
;   SendEvent('{VK4D down}{VK4D up}')
;   if (KeyWait("VK4D", TimerHold) = 0) {
;     PressH_ChPick(Ch["Dash"],Ch["DashLab"],"-")
;   }
;   Return
$VKBD::{                       ;[-] VKBD
  SendEvent('{VKBD down}{VKBD up}')
  if (KeyWait("VKBD", TimerHold) = 0) {
    PressH_ChPick(Ch["Dash"],Ch["DashLab"],"-")
  }
  }
$p::{                       ;[p] VK50
  SendEvent('{VK50 down}{VK50 up}')
  if (KeyWait("VK50", TimerHold) = 0) {
    PressH_ChPick(Ch["Space"],Ch["SpaceLab"],"p")
  }
  }
$r::{                       ;[r] VK52
  SendEvent('{VK52 down}{VK52 up}')
  if (KeyWait("VK52", TimerHold) = 0) {
    PressH_ChPick(Ch["Checks"],Ch["ChecksLab"],"r")
  }
  }
$VKDE::{                       ;['} single quoteVKDE
  SendEvent('{VKDE down}{VKDE up}')
  if (KeyWait("VKDE", TimerHold) = 0) {
    PressH_ChPick(Ch["QuotesS"])
  }
  }
$+VKDE::{                      ;["} double quote VKDE
  SendEvent('{blind}{VKDE down}{VKDE up}')
  if (KeyWait("VKDE", TimerHold) = 0) {
    PressH_ChPick(Ch["QuotesD"])
  }
  }
$+VKC0::{                      ;[~] VKC0 (SC029)
  SendEvent('{blind}{VKC0 down}{VKC0 up}')
  if (KeyWait("VKC0", TimerHold) = 0) {
    PressH_ChPick(Ch["Para"])
  }
  }
$+VK35::{                      ;[%] VK35
  SendEvent('{blind}{VK35 down}{VK35 up}')
  if (KeyWait("VK35", TimerHold) = 0) {
    PressH_ChPick(Ch["Percent"])
  }
  }

; reset to defaults
#MaxThreadsPerHotkey 1
#HotIf
#InputLevel 0
