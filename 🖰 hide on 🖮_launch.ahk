#Requires AutoHotKey 2.1-alpha.4

#Warn All            	; Enable all warnings to assist with detecting common errors ; #Warn All, Off
; #UseHook True      	;|True| Any keyboard hotkeys use hook (required to check for Physical state in GetKeyState)
#SingleInstance force	; Reloads script without dialog box
A_KeyHistory :=  125 	; Limit history to last X (need >10 for Hyper)
if (isStandAlone := (A_ScriptFullPath = A_LineFile)) {
  TraySetIcon("./img/🖰hide on 🖮.ico",0)
}

#Include %A_scriptDir%\gVar\var.ahk	; Global vars

#Include <Array>

dbg 	:= 0	; Level of debug verbosity (0-none)
dbgT	:= 2	; Timer for dbg messages (seconds)

#Include %A_scriptDir%\🖰 hide on 🖮.ahk	; Hide mouse pointer while typing

#SuspendExempt  ; Exempt the following hotkey from Suspend.
#F2::{
  Suspend(-1)
}
; <^<!<+r::{	;‹⎈‹⎇‹⇧r​	vk52 ⟶ Reload this AutoHotKey script
!F2::{      	;‹⎇F2    	vk71
  Tooltip "🖰hide on 🖮 Reloading! Hooks# " A_KeybdHookInstalled
  sleep(500)
  SetTimer () => ToolTip(), -500 ; killed on Reload, but helpful if reload fails
  Reload
  }
#SuspendExempt False  ; Disable exemption for any hotkeys/hotstrings below this.

