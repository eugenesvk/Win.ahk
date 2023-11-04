#Requires AutoHotKey 2.1-alpha.4
; Add groups of windows,	refer with `ahk_group MyGroup`
; Win/Exclude Title/Text are case-sensitive except for RegEx mode "i)".
;GroupAdd GroupName [   	, WinTitle, WinText, ExcludeTitle, ExcludeText]
GroupAdd "WinTabSwitch" 	, "ahk_exe OneCommanderV2.exe"
GroupAdd "WinTabSwitch" 	, "ahk_exe chrome.exe"
GroupAdd "WinTabSwitch" 	, "ahk_exe sublime_text.exe"
GroupAdd "Browser"      	, "ahk_exe chrome.exe"
GroupAdd "Browser"      	, "ahk_exe vivaldi.exe"
GroupAdd "Browser"      	, "ahk_exe firefox.exe"
GroupAdd "ScrollH"      	, "ahk_class WordPadClass"
GroupAdd "Explorer"     	, "ahk_class dopus.lister"
GroupAdd "Explorer"     	, "ahk_exe TOTALCMD64.EXE"
GroupAdd "Explorer"     	, "ahk_class CabinetWClass"
GroupAdd "TextEditor"   	, "ahk_exe sublime_text.exe"
GroupAdd "TextEditor"   	, "ahk_exe notepad++.exe"
GroupAdd "MSOffice"     	, "ahk_class OpusApp"              	; Word
GroupAdd "MSOffice"     	, "ahk_exe EXCEL.EXE"              	; Excel
GroupAdd "PressnHold"   	, "ahk_exe notepad++.exe"          	; Char-Hold works ONLY here
GroupAdd "PressnHold"   	, "ahk_exe sublime_text.exe"       	; SublimeText
GroupAdd "PressnHold"   	, "ahk_class PX_WINDOW_CLASS"      	; SublimeText
GroupAdd "PressnHold"   	, "ahk_class Chrome_WidgetWin_1"   	; Chrome
GroupAdd "PressnHold"   	, "ahk_class XLMAIN"               	; Excel
GroupAdd "PressnHold"   	, "ahk_exe EXCEL.EXE"              	; Excel
GroupAdd "PressnHold"   	, "ahk_class OpusApp"              	; Word
GroupAdd "PressnHold"   	, "ahk_class Notepad++"            	; Notepad++
GroupAdd "PressnHold"   	, "ahk_class WordPadClass"         	; WordPad
GroupAdd "PressnHold"   	, "ahk_group Browser"              	;
; GroupAdd "PressnHold" 	, "ahk_class keypirinha_wndcls_run"	; keypirinha
GroupAdd "ScrollH"      	, "ahk_group MSOffice"             	;
GroupAdd "ScrollH"      	, "ahk_class WindowsForms10.Window"	;
GroupAdd "ScrollH"      	, "ahk_exe paintdotnet.exe"        	;
GroupAdd "Games"        	, "ahk_exe EoCApp.exe"
GroupAdd "Games"        	, "ahk_exe BloodstainedRotN-Win64-Shipping.exe"
GroupAdd "Games"        	, "ahk_exe SpaceChem.exe"
GroupAdd "Games"        	, "ahk_exe C:\Games\Steam\SteamApps\common\Duskers\Duskers.exe"
GroupAdd "WinTerm"      	, "ahk_exe WindowsTerminal.exe"
; Apps that auto double 	  brackets                                              	;
GroupAdd "BracketDouble"	, "ahk_exe sublime_text.exe"                            	; SublimeText
; Alt-Tab               	                                                        	;
GroupAdd "⌥⭾AppSwitcher"	, "ahk_exe explorer.exe ahk_class MultitaskingViewFrame"	; Windows 10
GroupAdd "⌥⭾AppSwitcher"	, "ahk_exe explorer.exe ahk_class TaskSwitcherWnd"      	; Windows Vista, 7, 8.1
GroupAdd "⌥⭾AppSwitcher"	, "ahk_exe explorer.exe ahk_class #32771"               	; Older, or with classic alt-tab enabled


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

