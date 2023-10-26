#Requires AutoHotKey 2.0.10

#SingleInstance
; Persistent True

; doesn't match the original due to different title/exe
  ; WinWait("Microsoft Windows ahk_class #32770 ahk_exe explorer.exe", "Format disk")
SetTimer ChangeButtonNames, 50
MsgBox("You need to format the disk in drive G: before you can use it. Do you want to format it?","Debug",btn:='YesNo')
ChangeButtonNames() {
  if !WinExist("Debug") {
    return  ; Keep waiting
  }
  SetTimer , 0
  WinActivate
  ControlSetText(newTxt:="&Format disk", ctr:="Button1")
}
