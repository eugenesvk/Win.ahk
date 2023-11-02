#Requires AutoHotKey 2.0.10

#Warn All            	; Enable all warnings to assist with detecting common errors ; #Warn All, Off
#SingleInstance force	; Reloads script without dialog box

#Include %A_scriptDir%\gVar\var.ahk	; Global vars

#Include <PressH>
#Include <Array>
#Include <constKey>
#Include <Locale>
#Include <str>
#Include <libFunc Dbg>

#Include %A_scriptDir%\gVar\symbol.ahk     	; Global vars (diacritic symbols and custom chars)
#Include %A_scriptDir%\gVar\varWinGroup.ahk	; App groups for window matching

dbg 	:= 0	; Level of debug verbosity (0-none)
dbgT	:= 2	; Timer for dbg messages (seconds)

#Include %A_scriptDir%\char🠿.ahk	; Diacritics+chars on key hold
; ^+r::Reload ;[^⇧r] VK52
if (isStandAlone := (A_ScriptFullPath = A_LineFile)) {
  TraySetIcon("./img/char🠿.ico",0)
}
