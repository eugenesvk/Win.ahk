#Requires AutoHotKey 2.0
;Window management
  global Monitor_DefaultToNearest	:= 0x00000002

  global TTx          	:= 2100	; Alt ToolTip X coordinates
    , TTy             	:= 1275	;             Y coordinates
    , TTyOff          	:= -70 	;             Y offset for subsequent ToolTip
    , ListenTimerShort	:= 2   	; Remove short tooltip after 2 seconds (SpecialChars-Alt)
    , ListenTimerLong 	:= 4   	; Remove long  tooltip after 4 seconds (SpecialChars-Alt)

  global tDTap	:= 200	;  ms time to wait till a second duplicate key is considered a double tap vs two separate key presses

;WinAPI functions and constants
  ;Faster performance by looking up the function's address beforehand (lexikos.github.io/v2/docs/commands/DllCall.htm)
global getDefIMEWnd := DllCall("GetProcAddress", "Ptr",DllCall("GetModuleHandle", "Str","Imm32", "Ptr"), "AStr","ImmGetDefaultIMEWnd", "Ptr") ; HWND ImmGetDefaultIMEWnd(HWND Arg1) docs.microsoft.com/en-us/windows/win32/api/imm/nf-imm-immgetdefaultimewnd. Invoke: DllCall(getDefIMEWnd, "Ptr",fgWin)
  , CreateProcessW_proc := DllCall("GetProcAddress", "Ptr",DllCall("GetModuleHandle", "Str","kernel32", "Ptr"), "AStr","CreateProcessW", "Ptr") ; docs.microsoft.com/en-us/windows/win32/api/processthreadsapi/nf-processthreadsapi-createprocessw
  , QPerfC_proc := DllCall("GetProcAddress", "Ptr",DllCall("GetModuleHandle", "Str","kernel32", "Ptr"), "AStr","QueryPerformanceCounter", "Ptr") ; docs.microsoft.com/en-us/windows/win32/api/profileapi/nf-profileapi-queryperformancecounter
  , bytes⁄char	:= 2
  , ←              	:= -1    	, → 	:= 1
  , ↓              	:= -2    	, ↑ 	:= 2
  , s←             	:= "Left"	, s→	:= "Right"
  , s↓             	:= "Down"	, s↑	:= "Up"

