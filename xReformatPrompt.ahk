#Requires AutoHotKey 2.0.10

Loop {
  WinWait("Microsoft Windows ahk_class #32770 ahk_exe explorer.exe", "Format disk")
  ; MsgBox("Match!!!", "Debug", "T3")
  WinClose
}

; Full message is unfortunately hidden from Autohotkey (check Window Spy), only buttons' text is visible
; "You need to format the disk in drive X: before you can use it."
; "Do you want to format it?"
