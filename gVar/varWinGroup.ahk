#Requires AutoHotKey 2.0.10
; Add groups of windows,	refer with `ahk_group MyGroup`
; Win/Exclude Title/Text are case-sensitive except for RegEx mode "i)".
;GroupAdd GroupName [	, WinTitle, WinText, ExcludeTitle, ExcludeText]
GroupAdd "PressnHold"	, "ahk_exe notepad++.exe"       	; Char-Hold works ONLY here
GroupAdd "PressnHold"	, "ahk_exe sublime_text.exe"    	; SublimeText
GroupAdd "PressnHold"	, "ahk_class PX_WINDOW_CLASS"   	; SublimeText
GroupAdd "PressnHold"	, "ahk_class Chrome_WidgetWin_1"	; Chrome
GroupAdd "PressnHold"	, "ahk_class XLMAIN"            	; Excel
GroupAdd "PressnHold"	, "ahk_exe EXCEL.EXE"           	; Excel
GroupAdd "PressnHold"	, "ahk_class OpusApp"           	; Word
GroupAdd "PressnHold"	, "ahk_class Notepad++"         	; Notepad++
GroupAdd "PressnHold"	, "ahk_class WordPadClass"      	; WordPad
GroupAdd "PressnHold"	, "ahk_exe firefox.exe"         	; Firefox

; Window group arrays/dictionaries for faster/easier match without loops
  global exe→COM := Map()    ; need COM to scroll (map ahk_exe to COM object)
    exe→COM["WINWORD.EXE"] 	:= "Word.Application"      	;
  , exe→COM["POWERPNT.EXE"]	:= "PowerPoint.Application"	;
  , exe→COM["EXCEL.EXE"]   	:= "Excel.Application"     	;

  global exeScrollH := Array()  ; need WM_HSCROLL to scroll
    exeScrollH.Push("wordpad.exe")
  , exeScrollH.Push("explorer.exe")
  , exeScrollH.Push("MusicBee.exe")

  global exeBrowser := Array() ; Web browsers
    exeBrowser.Push("chrome.exe")
  , exeBrowser.Push("vivaldi.exe")

  global exeMDI := Array()     ; Multiple Document Interface (MDI) method to find controls
    exeMDI.Push("vivaldi.exe")
  , exeMDI.Push("sysedit.exe")
  , exeMDI.Push("textpad.exe")

