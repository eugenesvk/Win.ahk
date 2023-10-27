#Requires AutoHotKey 2.0.10

ToggleExtension() { ; Toggle file extension
  static reg_path := "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
  HiddenFiles_Status := RegRead(reg_path, 'HideFileExt')
  if (HiddenFiles_Status = 1) {
    RegWrite('0', 'REG_DWORD', reg_path, 'HideFileExt')
  } else {
    RegWrite('1', 'REG_DWORD', reg_path, 'HideFileExt')
  }
  ; eh_Class := WinGetClass("A")
  ;if (eh_Class = "#32770" OR A_OSVersion = "WIN_VISTA")
  if WinActive("ahk_class CabinetWClass") {
    SendInput '{F5}'
  } else {
    static msgNum:=0x111
    , wParam := 28931
    PostMessage(msgNum,wParam,,,"A")
  }
  Return
}

ToggleHidden() {                            ; Toggle hidden files
  reg_path := "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
  HiddenFilesStatus := RegRead(reg_path, 'Hidden')
  if (HiddenFilesStatus = 2) {
    RegWrite('1', 'REG_DWORD', reg_path, 'Hidden')
  } else {
    RegWrite('2', 'REG_DWORD', reg_path, 'Hidden')
  }
  ; eh_Class := WinGetClass("A")
  ;if (eh_Class = "CabinetWClass" OR A_OSVersion = "WIN_VISTA")
  If WinActive("ahk_class CabinetWClass") {
    Send('{F5}')
  } else {
    static msgNum:=0x111
    , wParam := 28931
    PostMessage(msgNum,wParam,,,"A")
  }
  Return
}
