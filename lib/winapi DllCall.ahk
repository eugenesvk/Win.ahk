#Requires AutoHotKey 2.1-alpha.4

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
  static ws      	:= winapi_Struct
  ; static Point1	:= this.ws.Point1() ; get dynamically created class

  static fnGetCursorPos	:= DllCall.Bind("GetCursorPos" ; learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getcursorpos
    ,"ptr",unset) ; use "ptr" to pass by reference
    ; ,"Int64*",&pos🖰 ;o LPPOINT lpPoint	pointer to a POINT structure that receives the screen coordinates of the cursor
  static GetCursorPos(pt) {
    static fn := this.fnGetCursorPos
    return fn(pt)
  }

  static  fnWindowFromPoint 	:= DllCall.Bind("WindowFromPoint" ; HWND WindowFromPoint( Retrieves a handle to the window that contains the specified point.
      , this.ws.Point,unset	;[in] POINT Point
      , "uptr")             	; Use the class itself to pass by value
      ; learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-windowfrompoint
  static WindowFromPoint(pt) {
    static fn := this.fnWindowFromPoint ;DllCall.Bind("WindowFromPoint" ; HWND WindowFromPoint( Retrieves a handle to the window that contains the specified point.
    return fn(pt)
  }

  static winT           	:= winTypes.m ; winT types and their ahk types for DllCalls and structs
  ; static __new() { ; get all vars and store their values in this .Varname as well ‘m’ map, and add aliases
  ;   static GetCursorPos := DllCall.Bind("GetCursorPos" ; learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getcursorpos
  ;     ;,"Int64*",&pos🖰 ;o LPPOINT lpPoint	pointer to a POINT structure that receives the screen coordinates of the cursor
  ;     ,"ptr",unset) ; use "ptr" to pass by reference
  ;   this.GetCursorPos := GetCursorPos
  ; }
}
