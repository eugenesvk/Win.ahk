#Requires AutoHotkey v2.0
; Change global variable based on external message to use conditional keybind that can be switched from another app
global nv_mode := 0 ; Sublime Text's plugin NeoVintageous' mode

listen_to_NeoVintageous()
listen_to_NeoVintageous() {
  static msgIDtxt := "nv_a61171a06fc94216a3433cf83cd16e35" ; must be set to the same value in NeoVintageous
  static msgID := DllCall("RegisterWindowMessage", "Str",msgIDtxt), MSGFLT_ALLOW := 1
  ; dbgtt(0,"msgID=" msgID, t:=5)
  if winID_self:=WinExist(A_ScriptHwnd) { ; need to allow some messages through due to AHK running with UIA access https://stackoverflow.com/questions/40122964/cross-process-postmessage-uipi-restrictions-and-uiaccess-true
    isRes := DllCall("ChangeWindowMessageFilterEx" ; learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-changewindowmessagefilterex?redirectedfrom=MSDN
      , "Ptr",winID_self  	;i	HWND 		hwnd   	handle to the window whose UIPI message filter is to be modified
      ,"UInt",msgID       	;i	UINT 		message	message that the message filter allows through or blocks
      ,"UInt",MSGFLT_ALLOW	;i	DWORD		action
      , "Ptr",0)          	;io opt PCHANGEFILTERSTRUCT pChangeFilterStruct
    ; dbgTT(0,isRes '`t' 'ChangeWindowMessageFilterEx on self' '`n' msgID '`t' 'msgID', t:=3)
  }
  OnMessage(msgID, setnv_mode, MaxThreads:=1)
  setnv_mode(wParam, lParam, msgID, hwnd) {
    global nv_mode
    nv_mode := lParam
    ; dbgTT(0, wParam " → " lParam " (w,l)", t:=2,,0)
  }
}
; listen_to_Kanata()
listen_to_Kanata() {
  static msgIDtxt := "kanata_4117d2917ccb4678a7a8c71a5ff898ed" ; must be set to the same value in Kanata
  static msgID := DllCall("RegisterWindowMessage", "Str",msgIDtxt), MSGFLT_ALLOW := 1
  if winID_self:=WinExist(A_ScriptHwnd) { ; need to allow some messages through due to AHK running with UIA access https://stackoverflow.com/questions/40122964/cross-process-postmessage-uipi-restrictions-and-uiaccess-true
    isRes := DllCall("ChangeWindowMessageFilterEx" ; learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-changewindowmessagefilterex?redirectedfrom=MSDN
      , "Ptr",winID_self  	;i	HWND 		hwnd   	handle to the window whose UIPI message filter is to be modified
      ,"UInt",msgID       	;i	UINT 		message	message that the message filter allows through or blocks
      ,"UInt",MSGFLT_ALLOW	;i	DWORD		action
      , "Ptr",0)          	;io opt PCHANGEFILTERSTRUCT pChangeFilterStruct
  }
  OnMessage(msgID, setnv_mode, MaxThreads:=1)
  setnv_mode(wParam, lParam, msgID, hwnd) {
    dbgtt(0,"Got a message from kanata with w=" wParam " l=" lParam,2)
    if        wParam == 10 {
      curtime := FormatTime(,"dddd MMMM d, yyyy H:mm:ss")
    } else if wParam == 20 {
      curtime := FormatTime(,"yy")
    }
    SetKeyDelay(-1, 0)
    SendEvent("¦" curtime "¦")
  }
}
