#Requires AutoHotKey 2.0.10

/*
test_winapi_DllCall1()
test_winapi_DllCall() {
  ws   	:= winapi_Struct, wdll := winapi_DllCall
  Point	:= ws.Point ; get statically defined class
  pt   	:= Point() ; insantiate a new object
  dbgTT(0,wdll.GetCursorPos(pt),t:=5)
  locfn := wdll.WindowFromPoint(pt)
  MsgBox(WinGetClass(locfn))
  locfn := wdll.fnWindowFromPoint
  MsgBox(WinGetClass(locfn(pt)))
}
*/

class winapi_DllCall { ; Various win32 API DllCall functions bound to AHK funcs with the help of AHK structs
  static fnGetCursorPos	:= DllCall.Bind("GetCursorPos" ; learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getcursorpos
    ,"ptr",unset) ; use "ptr" to pass by reference
    ; ,"Int64*",&pos🖰 ;o LPPOINT lpPoint	pointer to a POINT structure that receives the screen coordinates of the cursor
  static GetCursorPos(pt) {
    static fn := this.fnGetCursorPos
    return fn(pt)
  }
}
