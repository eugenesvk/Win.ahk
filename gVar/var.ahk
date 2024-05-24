#Requires AutoHotKey 2.0
;Window management
  global Monitor_DefaultToNearest	:= 0x00000002
  ;bitflags                      	;
    , f∗                         	:=    1	;                1 any modifiers allowed
    , f˜                         	:=    2	;             10 passthru native key
    , f＄                         	:=    4	;            100 keyboard hook on
  ;bitflags           	modifier
    , f‹⇧             	:=    1   	;              1 left shift
    , f‹⎇             	:=    2   	;             10 left alt
    , f‹⎈             	:=    4   	;            100 left ctrl
    , f‹◆             	:=    8   	;           1000 left super ❖◆ (win ⊞)
    , f⇧›             	:=   16   	;          10000 right shift
    , f⎇›             	:=   32   	;         100000 right alt
    , f⎈›             	:=   64   	;        1000000 right ctrl
    , f◆›             	:=  128   	;       10000000 right super ❖◆ (win ⊞)
    , f‹👍             	:=  256   	;      100000000 left Oyayubi 親指
    , f👍›             	:=  512   	;     1000000000 right Oyayubi 親指
    , fkana           	:= 1024   	;    10000000000 kana fかな
    , f⇧              	:= f‹⇧|f⇧›	;          1   1 any  shift
    , f⎇              	:= f‹⎇|f⎇›	;         10  10 any  alt
    , f⎈              	:= f‹⎈|f⎈›	;        100 100 any  ctrl
    , f◆              	:= f‹◆|f◆›	;       10001000 any  super
    , f👍              	:= f‹👍|f👍›	;   1100000000 any  Oyayubi
    ; , fzz›          	:= 2048   	;   100000000000 z
    ; , f⇪            	:= 4096   	;  1000000000000 caps lock
    ; , f🔢            	:= 8192   	; 10000000000000 num  lock
    ; fかな kana
    ,  bit‹ := f‹⇧ | f‹⎇ | f‹⎈ | f‹◆
    ,  bit› := f⇧› | f⎇› | f⎈› | f◆›

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

