;Auto-Execute Section (AES), continues until Return, Exit, hotkey/hotstring label
;(1) AES code common to ALL macros
  #Include %A_scriptDir%\gVar\var.ahk       	; Global vars (diacritic symbols and custom chars)
  #Include %A_scriptDir%\gVar\varPathMac.ahk	; Global vars (paths and Apps)
  #Include %A_scriptDir%\aCommon.ahk        	; Common settings and hotkeys
  #Include <kbNumLED>                       	; keyboard Numlock indicator functions
  #Include %A_scriptDir%\aMac.ahk           	; Mac-specific settings and hotkeys
