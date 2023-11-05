#Requires AutoHotKey 2.0.10

#Warn All            	; Enable all warnings to assist with detecting common errors ; #Warn All, Off
#SingleInstance force	; Reloads script without dialog box

#Include %A_scriptDir%\gVar\var.ahk	; Global vars

#Include <Locale>
#Include <str>
#Include <libFunc>
#Include <libFunc Native>

CoordMode "ToolTip", "Screen"	; Place ToolTips at absolute screen coordinates
CoordMode "Mouse",   "Screen"	; Mouse cursor: get absolute scren coordinates

dbg 	:= 0	; Level of debug verbosity (0-none)
dbgT	:= 2	; Timer for dbg messages (seconds)

#Include %A_scriptDir%\⌂mod_modtap.ahk	; home row mods
^+r::Reload ;[^⇧r] VK52
; if (isStandAlone := (A_ScriptFullPath = A_LineFile)) {
;   TraySetIcon("./img/⌂mod_modtap.ico",0)
; }
