#Requires AutoHotKey 2.0

#include <UIA>
#include <Acc2>
#include <libFunc Dbg>	; Functions: Debug
class win {
  static get⎀(&⎀←,&⎀↑,&⎀↔:=0,&⎀↕:=0) {
    static ptcProp	:= ["IsTextPatternAvailable","HasKeyboardFocus"]
     , ptcScope   	:= UIA.TreeScope.Element ; Element or Subtree (very slow on some web pages https://www.autohotkey.com/boards/viewtopic.php?f=82&t=114802&p=545176#p545176)
     , ptcMode    	:= UIA.AutomationElementMode.None
     , pointCache 	:= UIA.CreateCacheRequest(ptcProp,,ptcScope,ptcMode) ; (,patterns?,,,filter?)

    win.get⎀GUI(&⎀←,&⎀↑,&⎀→,&⎀↓,&⎀↔,&⎀↕,&⎀Blink,&⎀isVis) ; 1 get caret via GetGUIThreadInfo

    if ⎀isVis {
          return true
    } else {
      if win.get⎀Acc(&⎀←,&⎀↑, &⎀↔,&⎀↕) {                  ; 2 get caret via UIA
        isUIAEditable := 1
        try {
          pt           	:= UIA.SmallestElementFromPoint(⎀←,⎀↑,,pointCache) ; alt ElementFromPoint
          isUIAEditable	:= pt.CachedIsTextPatternAvailable && pt.CachedHasKeyboardFocus
        }
        if isUIAEditable {
          return true
        } else { ; ⎀ exists, but not editable, reset to 0
          ⎀←:=0 , ⎀↑:=0
          return false
        }
      } else { ; no ⎀ from either GUIthread or Acc, reset to 0
          ⎀←:=0 , ⎀↑:=0
          return false
      }
    }
  }
  static get⎀GUI(&⎀←,&⎀↑,&⎀→:=0,&⎀↓:=0 ; returned in Screen coordinates to match ACC, also avoids an issue where Active top window for some reson isn't the same dimensions as the window that holds the caret, so converting x,y to screen coordinates later results in the wrong outcome
    ,&⎀↔:=0,&⎀↕:=0,&⎀Blink:=0,&⎀isVis:=0) { ; autohotkey.com/boards/viewtopic.php?t=13004
    ; ⎀isVis sets to 1 only if caret Height > 1 (it's 1 in Help app even though there is no text input)
    static win32     	:= win32Constant ; various win32 API constants
     , gui           	:= win32.gui
     , bufSize       	:=24+6*A_PtrSize ; 72
     , winIDCaret_off	:= 8+5*A_PtrSize ; 48
     , rcCaret_off   	:= 8+6*A_PtrSize ; 56
     , flags_off     	:= 4
     , flagsSz       	:= 4 ; dword uint
     , coordClient→Screen := win.coordClient→Screen.Bind(win)
    bufGUIThreadI	:= Buffer(bufSize)
    NumPut("uint",bufSize, bufGUIThreadI, 0)
    ; winID := getWinID()
    ; winID_fg	:= DllCall("GetForegroundWindow") ; Get handle (HWND) to the foreground window docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getforegroundwindow
    ; threadID	:= DllCall("GetWindowThreadProcessId"	,  "Ptr",winID_fg, "Ptr",0) ; DWORD GetWindowThreadProcessId(HWND hWnd, LPDWORD lpdwProcessId) docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getwindowthreadprocessid
    gotGUIThreadI := DllCall("GetGUIThreadInfo" ; bool 0 fail, use GetLastError for error info ; learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getguithreadinfo
      , "uint",0            	;i  DWORD         	idThread, use the GetWindowThreadProcessId function to get it, NULL=foreground thread
      , "ptr",bufGUIThreadI)	;io PGUITHREADINFO	pgui pointer to a GUITHREADINFO structure that receives information describing the thread. Note that you must set the cbSize member to sizeof(GUITHREADINFO) before calling this function
    if not gotGUIThreadI {
      return ; ToolTip
    }
    offset    	:= flags_off
    flags     	:= NumGet(bufGUIThreadI, offset     , "uint")
    ⎀Blink    	:= flags & gui.GUI_CARETBLINKING ; set if caret is visible(?)
    offset    	:= rcCaret_off
    winIDCaret	:= NumGet(bufGUIThreadI, winIDCaret_off, "int")
    , ⎀←      	:= NumGet(bufGUIThreadI, offset     , "int")
    , ⎀↑      	:= NumGet(bufGUIThreadI, offset += 4, "int")
    , ⎀→      	:= NumGet(bufGUIThreadI, offset += 4, "int")
    , ⎀↓      	:= NumGet(bufGUIThreadI, offset += 4, "int")
    , _       	:= coordClient→Screen(⎀←,⎀↑,&⎀←,&⎀↑,winIDCaret)
    , _       	:= coordClient→Screen(⎀→,⎀↓,&⎀→,&⎀↓,winIDCaret)
    , ⎀↔      	:= ⎀→ - ⎀←
    , ⎀↕      	:= ⎀↓ - ⎀↑
    , ⎀isVis  	:= (⎀↕ > 1) ? 1 : 0 ; fix an issue with Help showing a caret of Height=1 even when there is none
    return ⎀← || ⎀↑ ;;; todo: what if 0,0 is a valid caret position?
  }

  static is⎀UIA() { ; check only text pattern style, assuming this means there is a caret inside, no need to get coords
    return win.isget⎀UIA(true)
  }
  static get⎀UIA(&⎀←:=0,&⎀↑:=0,&⎀↔:=0,&⎀↕:=0) { ; get caret coordinates
    return win.isget⎀UIA(false,&⎀←,&⎀↑,&⎀↔,&⎀↕)
  }
  static isget⎀UIA(is⎀only,&⎀←:=0,&⎀↑:=0,&⎀↔:=0,&⎀↕:=0) { ; get caret position using UIA
    static ptcProp	:= ["IsTextPatternAvailable","IsTextPattern2Available",'IsTextEditPatternAvailable',"HasKeyboardFocus"]
     , ptcPattern 	:= ["Text","Text2"]
     , ptcScope   	:= UIA.TreeScope.Element ; Element or Subtree (very slow on some web pages https://www.autohotkey.com/boards/viewtopic.php?f=82&t=114802&p=545176#p545176)
     , ptcMode    	:= UIA.AutomationElementMode.None ; no access to live object for performance, only cached prop/pattern are available
     , ptcMode    	:= UIA.AutomationElementMode.Full ;;;; TODO delete
     , pointCache 	:= UIA.CreateCacheRequest(ptcProp,ptcPattern,ptcScope,ptcMode) ; (,,,,filter?)
     , eIUnsupport	:= 0x80004002
     , _i         	:= 16
     , x          	:= A_ScreenWidth*.9 , y	:= A_ScreenHeight*.85
     , _dt        	:= 1 ; dbg level for tooltips
     , _dl        	:= 1 ; dbg level for log
     , _dl3       	:= 3 ;

    try {
      el := UIA.GetFocusedElement(pointCache) ; IUIAutomationElement
    } catch Error as e {
      dbgtt(0,"✗ GetFocusedElement " err2str(e,'mwe'))
      return false
    }
    if (isText := el.CachedIsTextPatternAvailable) {
      if is⎀only {
        if (isTextEdit := el.CachedIsTextEditPatternAvailable) {
          (dbg<min(_dt,_dl))?'':(dbgtxt := '✓UIA Text+TextEdit pattern isget⎀UIA⎋', dbgtt(_dt,dbgtxt,t:=5,_i,x,y   ), log(_dl3,dbgtxt,,_i  ))
          return true ; only signal that caret is editable
        }
      }
      if not (I_Text := el.CachedTextPattern) {
        (dbg<min(_dt,_dl))?'':(dbgtxt := '✗UIA CachedTextPattern' ' isget⎀UIA⎋', dbgtt(_dt,dbgtxt,t:=5,_i,x,y   ), log(_dl3,dbgtxt,,_i  ))
        return false
      }
    } else {
        (dbg<min(_dt,_dl))?'':(dbgtxt := '✗UIA CachedIsTextPatternAvailable' ' isget⎀UIA⎋', dbgtt(_dt,dbgtxt,t:=5,_i,x,y   ), log(_dl3,dbgtxt,,_i  ))
        return false
    }
    try {
      CaretRange := I_Text.GetCaretRange(&isFocus:=0) ; isFocus=isActive, in some apps false even with a caret editable
        ; TRUE if the text-based control that contains the caret has keyboard focus, otherwise FALSE
        ; FALSE: caret that belongs to the text-based control might not be at the same location as the system caret
        ; dbgtt(0,'supported interface is⎀Focus=' isFocus ' ' type(CaretRange) ' GetText=' CaretRange.GetText(),5,9,0,700)
    } catch OSError as e {
      if e.number = eIUnsupport {
        (dbg<min(_dt,_dl))?'':(dbgtxt := '✗UIA no GetCaretRange unsup Error=¦' err2str(e,'nm') ' isget⎀UIA⎋', dbgtt(_dt,dbgtxt,t:=5,_i,x,y   ), log(_dl3,dbgtxt,,_i  ))
        return false
      } else {
        (dbg<min(_dt,_dl))?'':(dbgtxt := '✗UIA another OSError=¦' err2str(e,'nm') ' isget⎀UIA⎋', dbgtt(_dt,dbgtxt,t:=5,_i,x,y   ), log(_dl3,dbgtxt,,_i  ))
        return false
      }
    } catch Error as e {
      (dbg<min(_dt,_dl))?'':(dbgtxt := '✗UIA another Error=¦' err2str(e,'nm') ' isget⎀UIA⎋', dbgtt(_dt,dbgtxt,t:=5,_i,x,y   ), log(_dl3,dbgtxt,,_i  ))
      return false
    }
    isEdit := !el.ValueIsReadOnly ; todo: is this useful???
    if isSet(CaretRange) {
      if (caretRectArr := CaretRange.GetBoundingRectangles()).Length = 1 {
        if ObjOwnPropCount(CaretRect := caretRectArr[1]) = 4 {
          ⎀←:=CaretRect.x, ⎀↑:=CaretRect.y
          ⎀↔:=CaretRect.w, ⎀↕:=CaretRect.h
          ; if el.ValueIsReadOnly { ; todo: is this useful???
            ; return false
          ; }
          return true
        } else {
          (dbg<min(_dt,_dl))?'':(dbgtxt := '±UIA unknown CaretRect length =' ObjOwnPropCount(CaretRect) ' isget⎀UIA⎋', dbgtt(_dt,dbgtxt,t:=5,_i,x,y   ), log(_dl3,dbgtxt,,_i  ))
          return false
        }
      } else {
        (dbg<min(_dt,_dl))?'':(dbgtxt := '✓Txt ±⎀ isEdit=' isEdit ' is⎀Focus=' isFocus '`n⎀Rect=¦' '¦' ' isget⎀UIA⎋', dbgtt(_dt,dbgtxt,t:=5,_i,x,y   ), log(_dl3,dbgtxt,,_i  ))
        return false
      }
    } else {
        (dbg<min(_dt,_dl))?'':(dbgtxt := '✓Txt ✗⎀API isEdit=' isEdit ' is⎀Focus=' isFocus ' isget⎀UIA⎋', dbgtt(_dt,dbgtxt,t:=5,_i,x,y   ), log(_dl3,dbgtxt,,_i  ))
        return false
    }
  }

  static get⎀Acc(&⎀←?,&⎀↑?,&⎀↔?,&⎀↕?) {
    static OBJID_CARET	:= 0xFFFFFFF8
    static accState := {Invisible:32768}
    ; CoordMode('Caret','Client')
    AccObject	:= Acc_ObjectFromWindow(WinExist('A'), OBJID_CARET)
    Loc      	:= Acc_Location(AccObject)
    try ⎀← := Loc.x, ⎀↑ := Loc.y
      , ⎀↔ := Loc.w, ⎀↕ := Loc.h

    if (Acc_State(AccObject) = accState.Invisible) {
      return false
    }
    return (IsSet(⎀←) || IsSet(⎀↑))
  }

  static coordClient→Screen(cx,cy,&x,&y,winID) { ; convert client coordinates to screen
    bPoint := Buffer(8,0)
      NumPut("int",cx,bPoint,0)
    , NumPut("int",cy,bPoint,4)
    , res := DllCall("User32.dll\ClientToScreen","Ptr",winID,"Ptr",bPoint) ; learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-clienttoscreen
    , x:=NumGet(bPoint,0,"int")
    , y:=NumGet(bPoint,4,"int")
    return res
  }
  static coordScreen→Client(cx,cy,&x,&y,winID) { ; convert screen coordinates to client
    bPoint := Buffer(8,0)
      NumPut("int",cx,bPoint,0)
    , NumPut("int",cy,bPoint,4)
    , res := DllCall("User32.dll\ScreenToClient","Ptr",winID,"Ptr",bPoint) ; learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-clienttoscreen
    , x:=NumGet(bPoint,0,"int")
    , y:=NumGet(bPoint,4,"int")
    return res
  }

  static getMonWork(&🖥️w←,&🖥️w↑,&🖥️w→,&🖥️w↓,&🖥️w↔,&🖥️w↕) { ; get active monitor's working area (excluding bottom taskbar)
    monAct_i	:= getFocusWindowMonitorIndex()
    isMon   	:= MonitorGetWorkArea(monAct_i, &🖥️w←,&🖥️w↑,&🖥️w→,&🖥️w↓)
    🖥️w↔    	:= 🖥️w→ - 🖥️w←
    🖥️w↕    	:= 🖥️w↓ - 🖥️w↑
    return isMon
  }
}

getWinID(winIDarg:='',h:=true) { ; verify that passed id exists, fallback to active window
  ; launching from e.g. Start Menu means there is no active visible Window (taskbar is active? which is hidden)
  ; h=true will match hidden windows as well to avoid errors on startup
  ; could also wait till the first non-hidden window is active: old := A_TitleMatchMode
    ; SetTitleMatchMode('RegEx')
    ; t5 := WinWaitActive('.*',,2)
    ; SetTitleMatchMode(old)
  if (winIDarg = 0) {
    throw ValueError("Can't pass a 0 window ID argument!", -1)
  } else {
    hSwitched := false
    if h and not A_DetectHiddenWindows { ; enable hidden windows matching, helpful when launching script from e.g. Start menu
      hSwitched := true
      DetectHiddenWindows true
    }
    winID := (  (winIDarg = "")
             || (winIDarg = "A"))
            ? WinExist("A")
            : winIDarg + 0
              ? WinExist("ahk_id " winIDarg)
              : WinExist(          winIDarg)
    if h and hSwitched { ; restore if switched
      DetectHiddenWindows false
    }
    if (winID = 0) {
      throw ValueError("Window not found " winIDarg, -1)
    } else {
      return winID
    }
  }
}

getFocusWindowMonitorHandle() {
   static spiGetLogicDPIOverride	:= 0x009E
   , spiSetLogicDPIOverride     	:= 0x009F
   , spifUpdateINIfile          	:= 0x00000001
   , MonDefTopPri               	:= 0x00000001
   , ScaleValues                	:= [100,125,150,175,200,225,250,300,350,400,450,500]
   hMon := DllCall('MonitorFromWindow', 'Ptr',WinExist("A"), 'UInt',MonDefTopPri, 'Ptr')
}

getFocusWindowMonitorIndex(winID_?) { ; converted from stackoverflow.com/a/68547452
  winID := isSet(winID_) ? winID_ : getWinID()
  monCount := MonitorGetCount() ;Get number of monitor
  if not winExist(winID) { ; guard against a missing active window
    return 1
  } else {
    WinGetPos(&🗔↖x,&🗔, &🗔↔,&🗔↕, winID) ; Get the position of the focus window
  }
  monSubAreas := []  ; Make an array to hold the sub-areas of the window contained within each monitor
  Loop monCount { ;Iterate through each monitor
    MonitorGetWorkArea(A_Index, &🖥️←,&🖥️↑,&🖥️→,&🖥️↓) ; Get Monitor working area
    xBeg	:= max(🗔↖x     	, 🖥️←) ;Calculate sub-area of the window contained within each monitor
    yBeg	:= max(🗔       	, 🖥️↑)
    xEnd	:= min(🗔↖x + 🗔↔	, 🖥️→)
    yEnd	:= min(🗔   + 🗔↕	, 🖥️↓)
    area	:= (xEnd - xBeg)
             * (yEnd - yBeg)
    monSubAreas.push({area:area, index:A_Index}) ;Remember these areas, and which monitor they were associated with
  }
  if (monSubAreas.Length == 1) { ;If there is only one monitor in the array, then you already have your answer
    return monSubAreas[1].index
  } else { ; Otherwise, loop to figure out which monitor's recorded sub-area was largest
    winningMon 	:= 0
    winningArea	:= 0
    for index, 🖥️ in monSubAreas {
      winningMon 	:= 🖥️.area > winningArea ? 🖥️.index : winningMon
      winningArea	:= 🖥️.area > winningArea ? 🖥️.area  : winningArea
    }
    return winningMon
  }
}
