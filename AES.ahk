#Requires AutoHotKey 2.1-alpha

#Warn All                     	; Enable all warnings to assist with detecting common errors ; #Warn All, Off
SetWorkingDir(A_ScriptDir)    	; Ensures a consistent starting directory
#SingleInstance force         	; Reloads script without dialog box
A_MenuMaskKey := "vkE8"       	; vkE8=unassigned. Stop sending LControl to mask release of Winkey/Alt; vk00sc000 disables automasking; vk07 was undefined, but now it's reserved for opening a game bar; vkFF no mapping
; SetCapsLockState "AlwaysOff"	; [CapsLock] disable
InstallKeybdHook(Install:=true, Force:=false) ; Install hook even if nothing uses it (can view recent keys)
#UseHook True         	; Any keyboard hotkeys use hook
KeyHistory(25)        	; Limit history to last X (need >10 for Hyper) ;;; temp
ListLines 0           	; Potential performance boost
; SendMode("Input")   	; blocks interspersion, useful for sending long test, but requires hook reinstall, which takes time and can bug other things, see autohotkey.com/boards/viewtopic.php?f=96&t=127074&p=562790. Superior speed and reliability. SendPlay for games to emulate keystrokes. Too fast for GUI selection of Diacritics, use SendInput individually
SendMode("Event")     	; avoid rehooking bugs
SetKeyDelay(-1, 0)    	; NoDelay MinPressDuration
SetMouseDelay(-1)     	; ≝10ms Delay after each mouse movement/click, -1=none
; SetTitleMatchMode(2)	; ≝2 win title can contain WinTitle anywhere inside it to be a match

;Auto-Execute Section (AES), continues until Return, Exit, hotkey/hotstring label
;(1) AES code common to ALL macros
  dbg                          	:= 0	; Level of debug verbosity (0-none)
  dbgT                         	:= 2	; Timer for dbg messages (seconds)
  USERPROFILE                  	:= EnvGet('userProfile')
  shell                        	:= ComObject("Shell.Application")
  A_HotkeyInterval             	:= 1000	; ≝2000
  A_MaxHotkeysPerInterval      	:= 200 	; ≝  70
  CoordMode "ToolTip", "Screen"	; Place ToolTips at absolute screen coordinates
  CoordMode "Mouse",   "Screen"	; Mouse cursor: get absolute scren coordinates
;(2) AES code common to particular macros
  ;Gosub is removed!!! https://www.autohotkey.com/v2/v2-changes.htm
  ;Gosub, M01_InitVars
  ;-------------------------------------
  ;MACRO 01
  ;M01_InitVars: ;Initialize vars used in this macro
  ;(some code)
  ;Return
  ; TimerHold := "T0.4"	; Timer for Char-Hold.ahk​
