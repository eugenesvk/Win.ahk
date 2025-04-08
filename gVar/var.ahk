#Requires AutoHotKey 2.1-alpha.4
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

  global TTx          	:= 2100	; Alt ToolTip X coordinates
    , TTy             	:= 1275	;             Y coordinates
    , TTyOff          	:= -70 	;             Y offset for subsequent ToolTip
    , ListenTimerShort	:= 2   	; Remove short tooltip after 2 seconds (SpecialChars-Alt)
    , ListenTimerLong 	:= 4   	; Remove long  tooltip after 4 seconds (SpecialChars-Alt)

  global wForward	:= true 	; Needed for WinCycle function
    , wCycling   	:= false	; Needed for WinCycle function

  global ctrlEditClass := Array()  ; edit box class names
      ctrlEditClass.Push("Edit1") ; standard
    , ctrlEditClass.Push("Edit2") ; MSO creates this instead of 1 after Toolbar ops
  ; , exeScrollH.Push("Edit3") ; just in case

  global ctrlPathClassNN  := Array() ; class names for path toolbar in Save/Open dialoge
      ctrlPathClassNN.Push("ToolbarWindow323")
    , ctrlPathClassNN.Push("ToolbarWindow324")
    , ctrlPathClassNN.Push("ToolbarWindow325")
  global ctrlPathClassNNA := Array() ; active ...
      ctrlPathClassNNA.Push("Edit2")
    , ctrlPathClassNNA.Push("Edit3")
  ; Sublime, Wordpad:
    ;          Inactive         Act   ahk_class
    ; Open [L] ToolbarWindow323 Edit2 #32770	[L]eft-most breadcrumb control
    ;      [R] ToolbarWindow324             	[R]ight-most dropdown menu
    ; Save [L] ToolbarWindow324 Edit2 #32770
    ;      [R] ToolbarWindow325
  ; Excel, Word:
    ; Open [L] ToolbarWindow324 Edit2 #32770
    ;      [R] ToolbarWindow325
    ; Save [L] ToolbarWindow325 Edit3 #32770
    ;      [R] ToolbarWindow326

  global tDTap	:= 200	;  ms time to wait till a second duplicate key is considered a double tap vs two separate key presses

;Windows 10 Shell Commands
  global shellFd := Map()
      shellFd['TaskView']     	:= "explorer.exe Shell:::{0DF44EAA-FF21-4412-828E-260A8728E7F1}" ;❖Tab
    , shellFd['ActionCenter'] 	:= "ms-actioncenter:" ;❖A
    , shellFd['CortanaSpeech']	:= "?" ;❖C
    , shellFd['Desktop']      	:= "explorer.exe Shell:::{00021400-0000-0000-C000-000000000046}" ;❖D
    , shellFd['Explorer']     	:= "explorer.exe Shell:::{20D04FE0-3AEA-1069-A2D8-08002B30309D}" ;❖E thisPC
    , shellFd['GameBar']      	:= "?" ;❖G
    , shellFd['Share']        	:= "?" ;❖H
    , shellFd['Settings']     	:= "ms-settings:" ;❖I
    , shellFd['Connect']      	:= "ms-settings-connectabledevices:devicediscovery" ;❖K
    ;, shellFd['Lock']        	:= "LockWorkStation" ;❖L
    , shellFd['Project']      	:= "ms-settings-displays-topology:projection" ;❖P
    , shellFd['Run']          	:= "explorer.exe Shell:::{2559a1f3-21d7-11d4-bdaf-00c04f60b9f0}" ;❖r
    , shellFd['Cortana']      	:= "ms-cortana:" ;❖S
    , shellFd['PowerUser']    	:= "explorer.exe " ;❖X
    ;, ms-projection:
    , shellFd['QuickAccess']	:= "explorer.exe shell:::{679F85CB-0220-4080-B29B-5540CC05AAB6}" ; File Explorer Folder: Quick access

; shellFd['Run'] := "explorer.exe " ;❖
; https://g-ek.com/clsid-guid-spisok-shell-v-windows-10
; http://ipmnet.ru/~sadilina/Windows/227.html
; security
; Explorer.exe Shell:::{2559a1f2-21d7-11d4-bdaf-00c04f60b9f0}
; system
; Explorer.exe Shell:::{BB06C0E4-D293-4f75-8A90-CB05B6477EEE}
; Start Menu
; Explorer.exe Shell:::{48e7caab-b918-4e58-a94d-505519c795dc}
; Explorer.exe Shell:::{04731B67-D933-450a-90E6-4ACD2E9408FE}
; https://www.askvg.com/tip-how-to-disable-all-win-keyboard-shortcuts-hotkeys-in-windows/

;WinAPI functions and constants
  ;Faster performance by looking up the function's address beforehand (lexikos.github.io/v2/docs/commands/DllCall.htm)
global getDefIMEWnd := DllCall("GetProcAddress", "Ptr",DllCall("GetModuleHandle", "Str","Imm32", "Ptr"), "AStr","ImmGetDefaultIMEWnd", "Ptr") ; HWND ImmGetDefaultIMEWnd(HWND Arg1) docs.microsoft.com/en-us/windows/win32/api/imm/nf-imm-immgetdefaultimewnd. Invoke: DllCall(getDefIMEWnd, "Ptr",fgWin)
  , CreateProcessW_proc := DllCall("GetProcAddress", "Ptr",DllCall("GetModuleHandle", "Str","kernel32", "Ptr"), "AStr","CreateProcessW", "Ptr") ; docs.microsoft.com/en-us/windows/win32/api/processthreadsapi/nf-processthreadsapi-createprocessw
  , QPerfC_proc := DllCall("GetProcAddress", "Ptr",DllCall("GetModuleHandle", "Str","kernel32", "Ptr"), "AStr","QueryPerformanceCounter", "Ptr") ; docs.microsoft.com/en-us/windows/win32/api/profileapi/nf-profileapi-queryperformancecounter
  , changeInputLang	:= 0x0050	; WM_INPUTLANGCHANGEREQUEST
  , inLangChange   	:= 0x0051 ; WM_INPUTLANGCHANGE
  , msgWheelH      	:= 0x20E 	; WM_MOUSEHWHEEL, docs.microsoft.com/en-us/windows/win32/inputdev/wm-mousehwheel
  , msgScrollH     	:= 0x0114	; WM_HSCROLL (=scrollbar button press, by line very slow, by page fast, might need to be sent to the control, not just the window), docs.microsoft.com/en-us/windows/win32/controls/wm-hscroll
  , msgScrollV     	:= 0x0115	; WM_VSCROLL, docs.microsoft.com/en-us/windows/win32/controls/wm-vscroll
  , WheelDelta     	:= 120   	; WHEEL_DELTA threshold for action to be taken, and one such action (for example, scrolling one increment) should occur for each delta
  , scroll←Ln      	:= 0     	; SB_LINELEFT ; by one unit = click ←
  , scroll←Pg      	:= 2     	; SB_PAGELEFT ; by window's width = click on the scroll bar
  , scroll→Ln      	:= 1     	; SB_LINERIGHT
  , scroll→Pg      	:= 3     	; SB_PAGERIGHT
  , scroll↑Ln      	:= 0     	; SB_LINEUP
  , scroll↑Pg      	:= 2     	; SB_PAGEUP
  , scroll↓Ln      	:= 1     	; SB_LINEDOWN
  , scroll↓Pg      	:= 3     	; SB_PAGEDOWN
  , scroll↑        	:= 6     	; SB_TOP
  , scroll↓        	:= 7     	; SB_BOTTOM
  , scroll←        	:= 6     	; SB_LEFT; upper left
  , scroll→        	:= 7     	; SB_RIGHT; lower right
  , kbControl      	:= 0x0008	; MK_CONTROL;  CTRL   key          is down
  , kbShift        	:= 0x0004	; MK_SHIFT;    SHIFT  key          is down
  , mbL            	:= 0x0001	; MK_LBUTTON;  left   mouse button is down
  , mbM            	:= 0x0010	; MK_MBUTTON;  middle mouse button is down
  , mbR            	:= 0x0002	; MK_RBUTTON;  right  mouse button is down
  , mbX1           	:= 0x0020	; MK_XBUTTON1; first  X     button is down
  , mbX2           	:= 0x0040	; MK_XBUTTON2; second X     button is down
  , msgSelect      	:= 0x00B1	; EM_SETSEL; set text selection
  , bytes⁄char     	:= 2
  , ←              	:= -1    	, → 	:= 1
  , ↓              	:= -2    	, ↑ 	:= 2
  , s←             	:= "Left"	, s→	:= "Right"
  , s↓             	:= "Down"	, s↑	:= "Up"
  , ␞              	:= "" ; Record Separator Chr(0x001E)

global help_keys := Map() ; List of registered keys
help_keys.CaseSense := 0 ; make key matching case insensitive
