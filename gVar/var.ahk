#Requires AutoHotKey 2.0.10
;Window management
  global Monitor_DefaultToNearest	:= 0x00000002
  ;List of styles https://www.autoitscript.com/autoit3/docs/appendix/GUIStyles.htm
    , WS_Border       	:= 0x00800000 ; a thin-line border
    , WS_DlgFrame     	:= 0x00400000 ; border of a style typically used with dialog boxes
    ; , WS_Caption    	:= WS_Border|WS_DlgFrame
    , WS_Caption      	:= 0x00C00000 ; Title bar (WS_BORDER + WS_DLGFRAME)
    , WS_SizeBox      	:= 0x00040000 ; Sizing border (=WS_THICKFRAME)
    , WS_Borderless   	:= WS_Caption|WS_SizeBox ; BitwiseOR (logical inclusive OR)
    , WS_Visible      	:= 0x10000000
    , WS_MaxBox       	:= 0x10000
    , WS_Min          	:= 0x20000000
    , WS_MaxBox       	:= 0x00010000 ; maximize button. Cannot be combined with the WS_EX_CONTEXTHELP style. The WS_SYSMENU style must also be specified.
    , WS_SysMenu      	:= 0x00080000	; a window menu on its title bar. The WS_CAPTION style must also be specified
    ;                 	; system default values
    , smFullscreen_Xpx	:= 16 ; Width and height of the client area for a full-screen window on the primary display monitor, in pixels.
    , smFullscreen_Ypx	:= 17
    , smWinMax_Xpx    	:= 61 ; Default dimensions, in pixels, of a maximized top-level window on the primary display monitor
    , smWinMax_Ypx    	:= 62
    , smMaxTrack_Xpx  	:= 59 ; Default maximum dimensions of a window that has a caption and sizing borders, in pixels. This metric refers to the entire desktop. The user cannot drag the window frame to a size larger than these dimensions
    , smMaxTrack_Ypx  	:= 60
    , smBorder_Xpx    	:= 5 ; Width and height of a window border, in pixels. This is equivalent to the SM_CXEDGE value for windows with the 3-D look
    , smBorder_Ypx    	:= 6 ;
    , smFrameFixed_Xpx	:= 7 ; (synonymous with SM_CXDLGFRAME, SM_CYDLGFRAME): Thickness of the frame around the perimeter of a window that has a caption but is not sizable, in pixels. SM_CXFIXEDFRAME is the height of the horizontal border and SM_CYFIXEDFRAME is the width of the vertical border.
    , smFrameFixed_Ypx	:= 8 ;
    , smSzFrame_Xpx   	:= 32 ; Thickness of the sizing border around the perimeter of a window that can be resized, in pixels. SM_CXSIZEFRAME is the width of the horizontal border, and SM_CYSIZEFRAME is the height of the vertical border. Synonymous with SM_CXFRAME and SM_CYFRAME
    , smSzFrame_Ypx   	:= 33 ;
    , smEdge_Xpx      	:= 45 ; Dimensions of a 3-D border, in pixels. These are the 3-D counterparts of SM_CXBORDER and SM_CYBORDER
    , smEdge_Ypx      	:= 46 ;
  ;bitflags           	;
    , f∗              	:=    1	;                1 any modifiers allowed
    , f˜              	:=    2	;             10 passthru native key
    , f＄              	:=    4	;            100 keyboard hook on

  global tDTap	:= 200	;  ms time to wait till a second duplicate key is considered a double tap vs two separate key presses


;WinAPI functions and constants
  ;Faster performance by looking up the function's address beforehand (lexikos.github.io/v2/docs/commands/DllCall.htm)
global getDefIMEWnd := DllCall("GetProcAddress", "Ptr",DllCall("GetModuleHandle", "Str","Imm32", "Ptr"), "AStr","ImmGetDefaultIMEWnd", "Ptr") ; HWND ImmGetDefaultIMEWnd(HWND Arg1) docs.microsoft.com/en-us/windows/win32/api/imm/nf-imm-immgetdefaultimewnd. Invoke: DllCall(getDefIMEWnd, "Ptr",fgWin)
  , CreateProcessW_proc := DllCall("GetProcAddress", "Ptr",DllCall("GetModuleHandle", "Str","kernel32", "Ptr"), "AStr","CreateProcessW", "Ptr") ; docs.microsoft.com/en-us/windows/win32/api/processthreadsapi/nf-processthreadsapi-createprocessw
  , QPerfC_proc := DllCall("GetProcAddress", "Ptr",DllCall("GetModuleHandle", "Str","kernel32", "Ptr"), "AStr","QueryPerformanceCounter", "Ptr") ; docs.microsoft.com/en-us/windows/win32/api/profileapi/nf-profileapi-queryperformancecounter
  , bytes⁄char	:= 2
