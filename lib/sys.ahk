#Requires AutoHotKey 2.0.10

#include <winapi DllCall>
; —————————— Various system functions ——————————
class helperSystem {
  static getDPI🖰Pointer(dpi🖥️) {
    static C := win32Constant.Misc ; various win32 API constants
    width 	:= DllCall('GetSystemMetricsForDpi', 'Int',C.curW ,'uint',dpi🖥️) ; int  nIndex	system metric or configuration setting to be retrieved
    height	:= DllCall('GetSystemMetricsForDpi', 'Int',C.curH ,'uint',dpi🖥️) ; uint dpi   	DPI to use for scaling the metric
    return [width, height]
  }
  static getDPI🖥️() {
    static C := win32Constant.Misc ; various win32 API constants
     , wdll := winapi_DllCall

    DllCall("SetThreadDpiAwarenessContext", "ptr",C.dpiAwareMon, "ptr") ;learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setthreaddpiawarenesscontext
    if not got🖰pos := DllCall("GetCursorPos"  ; learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getcursorpos?redirectedfrom=MSDN
      ,  "Int64*",&pos🖰:=0 ;o LPPOINT lpPoint	pointer to a POINT structure that receives the screen coordinates of the cursor
      ) {
      return [96,96] ; break silently
    }
    hMon := DllCall("MonitorFromPoint"  ;learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-monitorfrompoint?redirectedfrom=MSDN
      ,  "Int64",pos🖰 ; POINT pt   	point on monitor
      , "uint"  ,1) ; DWORD dwFlags	flag to return primary monitor on failure
      ; MONITOR_DEFAULTTONULL      	0x00000000 Returns NULL
      ; MONITOR_DEFAULTTOPRIMARY   	0x00000001 Returns a handle to the primary display monitor
      ; MONITOR_DEFAULTTONEAREST   	0x00000002 Returns a handle to the display monitor that is nearest to the point
    dpi🖥️x:=0,dpi🖥️y:=0
    is🖥️DPI := DllCall('Shcore\GetDpiForMonitor' ; HRESULT
      , 'Ptr' ,hMon    	; HMONITOR        	hmonitor	Handle of the monitor being queried
      , 'Ptr' ,C.dpiEff	; MONITOR_DPI_TYPE	dpiType 	type of DPI being queried. Possible values are from the MONITOR_DPI_TYPE enumeration
      ,'uint*',&dpi🖥️x 	;o uint           	*dpiX   	DPI value along the X axis (refers to horizontal edge even when the screen is rotated)
      ,'uint*',&dpi🖥️y 	;o uint           	*dpiY   	DPI value along the Y axis (refers to vertical   edge even when the screen is rotated)
      , 'Int') ; learn.microsoft.com/en-us/windows/win32/api/shellscalingapi/nf-shellscalingapi-getdpiformonitor
    if is🖥️DPI = 0 {
      return [dpi🖥️x, dpi🖥️y]
    } else {
      return [96,96] ; break silently
    }
  }
  }
