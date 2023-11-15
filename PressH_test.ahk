#Requires AutoHotKey 2.0.10

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

^+r::Reload ;[^⇧r] VK52
F5::PressH_ChPick(Ch['Currency']) ;
 F6::PressH_ChPick(Ch['Currency'],Ch['CurrLabN'],,"H",caret:=1,bs:=0)
+F6::PressH_ChPick(Ch['Currency'],Ch['CurrLabN'],,"H",caret:=0,bs:=0)
 F7::PressH_ChPick(Ch['Math'],,,"V",caret:=1,bs:=0)
+F7::PressH_ChPick(Ch['Maths'],,,  ,caret:=1,bs:=0) ; uses Global position
