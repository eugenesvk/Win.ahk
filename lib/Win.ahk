#Requires AutoHotKey 2.0.10

#include <UIA>
#include <Acc2>
#include <libFunc Dbg>	; Functions: Debug
#include <constWin32T>
class win {
  static is⎀(&⎀←,&⎀↑,&⎀↔:=0,&⎀↕:=0) { ; true if caret is visible even if text isn't editable
    return win.isget⎀(true,&⎀←,&⎀↑,&⎀↔,&⎀↕)
  }
  static get⎀(&⎀←,&⎀↑,&⎀↔:=0,&⎀↕:=0) { ; true if caret is visible and text is editable
    return win.isget⎀(false,&⎀←,&⎀↑,&⎀↔,&⎀↕)
  }
  static isget⎀(is⎀only,&⎀←,&⎀↑,&⎀↔:=0,&⎀↕:=0) {
    static ptcProp	:= ["IsTextPatternAvailable","IsTextPattern2Available","HasKeyboardFocus"]
     , ptcScope   	:= UIA.TreeScope.Element ; Element or Subtree (very slow on some web pages https://www.autohotkey.com/boards/viewtopic.php?f=82&t=114802&p=545176#p545176)
     , ptcMode    	:= UIA.AutomationElementMode.None ; no access to live object for performance, only cached prop/pattern are available
     , pointCache 	:= UIA.CreateCacheRequest(ptcProp,,ptcScope,ptcMode) ; (,,,,filter?)
     , _i         	:= 15
     , x          	:= A_ScreenWidth*.9 , y	:= A_ScreenHeight*.75
     , _dt        	:= 1 ; dbg level for tooltips
     , _dl        	:= 1 ; dbg level for log
     , _dl3       	:= 3 ;

    win.get⎀GUI(&⎀←,&⎀↑,&⎀→,&⎀↓,&⎀↔,&⎀↕,&⎀Blink,&⎀isVis) ; 1 get caret via GetGUIThreadInfo
    if IsSet(⎀isVis) and ⎀isVis {
        (dbg<min(_dt,_dl))?'':(dbgtxt := '✓ get⎀GUI ⎀isVis get⎀⎋', dbgtt(_dt,dbgtxt,t:=5,_i,x,y   ), log(_dl3,dbgtxt,,_i  ))
        return true
    } else if (    is⎀only and win.is⎀UIA()) { ; 2 get editable caret via UIA even without coordinates
        (dbg<min(_dt,_dl))?'':(dbgtxt := '✓ is⎀UIA get⎀⎋', dbgtt(_dt,dbgtxt,t:=5,_i,x,y   ), log(_dl3,dbgtxt,,_i  ))
        return true
    } else if (not is⎀only and win.get⎀UIA(&⎀←,&⎀↑, &⎀↔,&⎀↕)) { ; 2 get caret via UIA
        (dbg<min(_dt,_dl))?'':(dbgtxt := '✓ get⎀UIA get⎀⎋', dbgtt(_dt,dbgtxt,t:=5,_i,x,y   ), log(_dl3,dbgtxt,,_i  ))
        return true
    } else if win.get⎀Acc(&⎀←,&⎀↑, &⎀↔,&⎀↕) { ; 3 get caret via Acc and check editable via UIA
      if ⎀↔ = 0 { ; likely an invisible caret
        (dbg<min(_dt,_dl))?'':(dbgtxt := '✗ ⎀↔Acc=0 get⎀⎋', dbgtt(_dt,dbgtxt,t:=5,_i,x,y   ), log(_dl3,dbgtxt,,_i  ))
        return false
      }
      try {
        pt           	:= UIA.SmallestElementFromPoint(⎀←,⎀↑,,pointCache)
        ;pt          	:= UIA.ElementFromPoint        (⎀←,⎀↑,,pointCache)
        isUIAEditable	:= pt.CachedIsTextPatternAvailable && pt.CachedHasKeyboardFocus
        ; pt?dbgtt(0,'smallest pt exists ' type(pt) ' edit? ' isUIAEditable ,2,4,0,75):'' ; UIA.IUIAutomationElement
      }
      if not isSet(isUIAEditable) or not isUIAEditable {
        try {
          pt           	:= UIA.ElementFromPoint(⎀←,⎀↑,pointCache)
          isUIAEditable	:= pt.CachedIsTextPatternAvailable && pt.CachedHasKeyboardFocus
        }
        ; pt?dbgtt(0,'pt exists edit? ' isUIAEditable ,5,5,0,100):''
      }
      if     isSet(isUIAEditable) and    isUIAEditable {
        (dbg<min(_dt,_dl))?'':(dbgtxt := '✓ ⎀Acc UIAEditable ' ⎀← ' ' ⎀↑ ' ' ⎀↔ ' ' ⎀↕ ' get⎀⎋', dbgtt(_dt,dbgtxt,t:=5,_i,x,y   ), log(_dl3,dbgtxt,,_i  ))
        return true
      } else { ; ⎀ exists, but not editable
        if is⎀only {
          (dbg<min(_dt,_dl))?'':(dbgtxt := '✓ ⎀Acc notUIAEditable ' ⎀← ' ' ⎀↑ ' ' ⎀↔ ' ' ⎀↕ ' get⎀⎋', dbgtt(_dt,dbgtxt,t:=5,_i,x,y   ), log(_dl3,dbgtxt,,_i  ))
          return true
        } else {
          (dbg<min(_dt,_dl))?'':(dbgtxt := '✗ ⎀Acc notUIAEditable ' ⎀← ' ' ⎀↑ ' ' ⎀↔ ' ' ⎀↕ ' get⎀⎋', dbgtt(_dt,dbgtxt,t:=5,_i,x,y   ), log(_dl3,dbgtxt,,_i  ))
          return false
        }
      }
    } else { ; no ⎀ from either GUIthread / UIA / Acc
        (dbg<min(_dt,_dl))?'':(dbgtxt := '✗✗✗ ⎀ get⎀⎋', dbgtt(_dt,dbgtxt,t:=5,_i,x,y   ), log(_dl3,dbgtxt,,_i  ))
        return false
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
getWinID_Owner(winIDarg) { ; get a window ID of the owner of the passed winID
  static winT	:= winTypes.ahk ; winT types and their ahk types for DllCalls and structs
   , GW_OWNER := 4 ; An application can use the GetWindow function with the GW_OWNER flag to retrieve a handle to a window's owner.
  if (winIDarg = 0) {
    throw ValueError("Can't pass a 0 window ID argument!", -1)
  } else {
    ownerID := DllCall("user32\GetWindow", winT['HWND'],winIDarg, winT['UINT'],GW_OWNER) ; learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getwindow HWND GetWindow([in] HWND hWnd,[in] UINT uCmd);
    if ownerID {
      return ownerID
    } else {
      return 0
    }
  }
}

; Fullscreen window toggle
Win_FWT(hwnd:="") { ;autohotkey.com/boards/viewtopic.php?p=123166#p123166
  static A  	:= {} ;  object aa a
  if (!hwnd)	; If no window handle is supplied, use the window under the mouse
    MouseGetPos , , &hwnd
  WinT	:= "ahk_id " hwnd   	; Store WinTitle
  S   	:= WinGetStyle(WinT)	; Get window style
  if (!A.HasOwnProp("WinT")) {
    A.WinT := {}	; Create a new object @Property WinT
  }
  if (S & WS_Borderless) { ; If not borderless
    A.WinT.Style := S & WS_Borderless	; Store existing style
    IsMaxed := WinGetMinMax(WinT)    	; Get/store whether the window is maximized
    if (A.WinT.Maxed := IsMaxed = 1 ? true : false)
      WinRestore WinT
    WinGetPos &wX, &wY, &wW, &wH, WinT ; Store window size/location
    A.WinT.wX := wX, A.WinT.wY := wY, A.WinT.wW := wW, A.WinT.wH := wH
    WinSetStyle("-" WS_Borderless, WinT)           ; Remove borders
    hMon := DllCall("User32\MonitorFromWindow", "Ptr", hwnd, "UInt", Monitor_DefaultToNearest)
    VarSetStrCapacity(&monInfo, 40), NumPut("UInt",40, StrPtr(monInfo), 0)
    DllCall("User32\GetMonitorInfo", "Ptr",hMon, "Ptr",StrPtr(monInfo))
    WinMove monLeft   := NumGet(StrPtr(monInfo),  4, "Int")  ; Move and resize window
          , monTop    := NumGet(StrPtr(monInfo),  8, "Int")
          ,(monRight  := NumGet(StrPtr(monInfo), 12, "Int")) - monLeft
          ,(monBottom := NumGet(StrPtr(monInfo), 16, "Int")) - monTop
          , WinT
  } else if (A.WinT.HasOwnProp("Style")) {	; If borderless
    WinSetStyle("+" A.WinT.Style, WinT)   	; Reapply borders
    WinMove A.WinT.wX, A.WinT.wY          	; Return to original position
          , A.WinT.wW, A.WinT.wH, WinT    	;
    if (A.WinT.Maxed)                     	; Maximize if required
      WinMaximize WinT
    A.DeleteProp("WinT")
  }
}

Win_TitleToggle(PosFix:=0, id?, Sign:="^", PosFixOverflow:=1) { ; Borderless window is larger than regular, Fix=1 to make Window position/size match border/-less
  ; PosFix          maintain identical "outer" window size, so removing a titlebar increases the client area to compensate
  ; PosFixOverflow  limit to monitor's working area, so adding a titlebar won't make the window hide the bottom taskbar
  static winDemax_id	:= Map()
    , dp            	:= 1 ; debug tooltip levels
    , winSzFrame_Xpx	:= SysGet(smSzFrame_Xpx) ; sizing border around the perimeter of a window
    , winSzFrame_Ypx	:= SysGet(smSzFrame_Ypx)
    , OffT          	:= {x: winSzFrame_Xpx*2,y:0, w:-winSzFrame_Xpx*4 ,h:-winSzFrame_Ypx*2}	; has Title , move → by 1×, + Width by 2× and Height by 1× BorderOffset
    , OffB          	:= {x:-winSzFrame_Xpx*2,y:0, w: winSzFrame_Xpx*4 ,h: winSzFrame_Ypx*2}	; Borderless, move ← by 1×, − Width by 2× and Height by 1× BorderOffset
    , bOffset       	:= 10                                                                 	; Border width needed to adjust WinPos
  ; dbgGetSysMonVars()

  if !IsSet(id) { ; if no id passed, use Active window
    id	:= WinGetID("A")
  }
  MinMax	:= WinGetMinMax(id) ; Min -1, Max 1, Neither 0
  winIDs	:= WinGetList(  id) ;;; already have an id, why do this?
  if ( not         (winID := winIDs[1])
    or not WinExist(winID)) { ; guard against a "not found" error
    return
  }

  Style         	:= WinGetStyle(winID)
  StyleHex      	:= Format("{1:#x}", Style)

  if ( ((sign = '+') and     (Style & WS_Borderless))    ; style already     set, no need to add    it
    or ((sign = '-') and not (Style & WS_Borderless))) { ; style already not set, no need to remove it
    return
  }
  WinGetPos(&wXp:=0,&wYp:=0, &wWp:=0,&wHp:=0    , winID)
  WinSetStyle(Sign WS_Borderless, winID)
  WinGetPos(&wX,&wY, &wW,&wH    , winID)

  if not win.getMonWork(&🖥️w←,&🖥️w↑,&🖥️w→,&🖥️w↓,&🖥️w↔,&🖥️w↕) {
    return
  }
  if (MinMax = 1) { ;     Maximized: Restore and Maximize back
    winDemax_id[id] := winID ; store demaxed winID so that we can max it back later
    WinRestore(wTitle:=winID)
    ; WinMaximize winID ; BUGs, covers taskbar, so replace maximizing back with manually setting max area without the taskbar
    ; if (PosFix = 0) { ; avoid artifacts from adding/removing borders, no pos/size change
      WinMove(x:=0,y:=0,🖥️w↔,🖥️w↕,wTitle:=winID)
    ; } else {
      ; WinMove 0,0,A_ScreenWidth,H-25, id ; X+13,Y+13,W-26,H-26 ;Still acts like maximized e.g. after Alt+Tab
    ; }
  } else          { ; NOT Maximized: adjust size
    if (winDemax_id.get(id,0) = winID) { ; maximize previously demaxed window
      winDemax_id[id] := ""
      WinMaximize(winID)
      return
    }
    if (PosFix = 0) { ; avoid artifacts from adding/removing borders, no pos/size change
      if PosFixOverflow { ; unless windows overflows screen and this is set
        if (wW   > 🖥️w↔) and (wX <= bOffset) {
          wW_to	:= 🖥️w↔
          wX_to	:= 0
        }
        if (wH   > 🖥️w↕) and (wY <= bOffset) {
          wH_to	:= 🖥️w↕
          wY_to	:= 0
        }
        if       (isSet(wW_to)
          and     isSet(wH_to)) {
          WinMove(wX_to,wY_to, wW_to-1,wH_to-1,winID)
          WinMove(wX_to,wY_to, wW_to  ,wH_to  ,winID)
          (dbg>dp)?'':dbgtxt:= 'overflows ↔ (' wW ' > ' 🖥️w↔ ') ↕ (' wH '>' 🖥️w↕ ')'
        } else if isSet(wW_to) {
          WinMove(wX_to,     , wW_to-1,       ,winID)
          WinMove(wX_to,     , wW_to  ,       ,winID)
          (dbg>dp)?'':dbgtxt:= 'overflows ↔ (' wW ' > ' 🖥️w↔ ')'
        } else if isSet(wH_to) {
          WinMove(     ,wY_to,        ,wH_to-1,winID)
          WinMove(     ,wY_to,        ,wH_to  ,winID)
          (dbg>dp)?'':dbgtxt:= 'overflows ↕ (' wH '>' 🖥️w↕ ')'
        } else {
          (dbg>dp)?'':dbgtxt:= 'no overflows'
          WinMove(     ,     , wW-1   ,       ,winID)
          WinMove(     ,     , wW     ,       ,winID)
        }
      } else {
        WinMove(       ,     , wW-1   ,       ,winID)
        WinMove(       ,     , wW     ,       ,winID)
        (dbg>dp)?'':dbgtxt:= 'no overflow / no fix'
        ; WinMaximize(winID), WinRestore (winID),  WinActivate(winID) ; Alternative (more noticeablele)
        ; WinRestore(winID) ; NOT reliable, sometimes restores in the background
        ; Doesn't work: WinRedraw/WinHide/WinShow "A"
      }
      (dbg>dp)?'':dbgtxt.= '' .
        '`n' '(pre) x' wXp ' y' wXp ' w' wWp ' h' wHp ' style=' StyleHex ' Frame x' winSzFrame_Xpx ' y' winSzFrame_Ypx
      (dbg<dp)?'':dbgTL(dp,dbgtxt,{🕐:5,id:5,x:1550,y:750,fn:A_ThisFunc})
    } else {  ; change position/size to make border/-less windows the same (clamp at working area height)
      if (Style & WS_Caption) { ; has Title
        xOff	:= OffT.x, xLim :=       -1*bOffset
        wOff	:= OffT.w, wLim := 🖥️w↔ + 1*bOffset
        hOff	:= OffT.h, hLim := 🖥️w↕ + 1*bOffset
        ; if (wW_to > 🖥️w↔) and (wX_to <= bOffset) { ; fix some apps with mistaken window border offsets
        ;   wW_to	:= 🖥️w↔
        ;   wX_to	:= 0
        ; }
        ; if (wH_to > 🖥️w↕) and (wY_to <= bOffset) { ; fix some apps with mistaken window border offsets
        ;   wH_to	:= 🖥️w↕
        ;   wY_to	:= 0
        ; }
        (dbg>dp)?'':dbgtxt:="Has title WS_CAPTION 0x00C00000, var.StyleHex={" StyleHex "}"

      } else { ; Borderless
        xOff	:= OffB.x, xLim :=       -1*bOffset
        wOff	:= OffB.w, wLim := 🖥️w↔ + 2*bOffset
        hOff	:= OffB.h, hLim := 🖥️w↕ + 2*bOffset
        (dbg>dp)?'':dbgtxt:="Else, var.StyleHex={"                            StyleHex "}"
      }
      wX_to	:= max(wX + xOff, xLim) ; don't move ← outside of screen
      wY_to	:= wY
      wW_to	:= min(wW + wOff,wLim) ; don't increase ↔ beyond monitor's working area
      wH_to	:= min(wH + hOff,hLim) ;                ↕
      WinMove(wX_to,wY_to, wW_to,wH_to, winID)
      (dbg>dp)?'':dbgtxt.= '' .
        '`n' ' x `t: ' format('{:4}',wX) ' to ' format('{:4}',wX_to) '`tmax(' (wX + xOff) '=(' wX '+' xOff ')' '¦' xLim ')' .
        ; '`n' ' x `t: ' format('{:4}',wY) ' to ' format('{:4}',wY_to) .
        '`n' ' w↔`t: ' format('{:4}',wW) ' to ' format('{:4}',wW_to) '`tmin(' (wW + wOff) '=(' wW '+' wOff ')' '¦' wLim ')' .
        '`n' ' w↕`t: ' format('{:4}',wH) ' to ' format('{:4}',wH_to) '`tmin(' (wH + hOff) '=(' wH '+' hOff ')' '¦' hLim ')' .
        '`n' '(pre) x' wXp ' y' wXp ' w' wWp ' h' wHp ' style=' StyleHex ' Frame x' winSzFrame_Xpx ' y' winSzFrame_Ypx
      (dbg<dp)?'':dbgTL(dp,dbgtxt,{🕐:3,id:4,x:1550,y:850,fn:A_ThisFunc})
    }
  }
  }
; Apply Win_TitleToggle() to all windows of an App without switching
Win_TitleToggleAll(App, PosFix:=0, Sign:="^") {
  procWinIDs := WinGetList("ahk_exe " App)
  Loop procWinIDs.Length {
    this_id := procWinIDs[A_Index]
    Win_TitleToggle(PosFix, this_id, Sign)
  }
  }

Win_MenuToggle(hWin) { ; Hide/Show Window's menu bar
  ;autohotkey.com/board/topic/11976-menubar-hiding/page-2
  static MenuMap := Map() ; static associative array to keep track of all windows with  hidden menus
  if MenuMap.Has(hWin) { ; the menu was previously hidden, restore it
    hMenu := MenuMap[hWin] ; retrieve the Menu
    DllCall("SetMenu", "uint",hWin, "uint",hMenu)
    MenuMap.Delete(hWin)
  } else { ; menu wasn't previously hidden, hide it and store the the App
    hMenu        	:= (DllCall("GetMenu", "uint", hWin)) ; get a ref to Win's menu
    MenuMap[hWin]	:= hMenu ; ...store it
    DllCall("SetMenu", "uint",hWin, "uint",0) ; hide the menu by uncoupling it from the parent window
  }
}

; Hide all windows except for the focused one
Win_HideOthers() {  ; hides all windows except for the focused one
  SetWinDelay 0
  active_id   	:= WinGetID("A")
  active_style	:= WinGetStyle("ahk_id" active_id)
  if !WinExist("ahk_id" active_id)                          ; restore if no windows
    WinRestore "A"                                          ; A=The Active Window
  ; MsgBox "The active window's ID is " active_id
  if (active_style & 0x20000){                              ; ? WS_MINIMIZEBOX
    WinIDx := WinGetList(,, "Program Manager")
    Loop WinIDx.Length() {
      WinID := WinIDx[A_Index]
      If active_id = WinID
        Continue
      wstyle := WinGetStyle("ahk_id" WinID)
      if (wstyle & 0x20000) {
        wstate := WinGetMinMax("ahk_id" WinID)
        If wstate=-1                                         ; ignore minimized windows
          Continue
        wclass := WinGetClass("ahk_id" WinID)
        If wclass="Shell_TrayWnd"
          Continue
        If WinExist("ahk_id" WinID)
          WinMinimize("ahk_id" WinID)
      }
    }
  }
  Return
}

Win_ToggleMenu(HWND) { ;autohotkey.com/board/topic/11976-menubar-hiding/page-2
  static MenuMap := Map() ;static associative array to keep track of all windows that've had their menus hidden
  hWin	:= HWND ; get active window handle
  if MenuMap.Has(hWin) { ; the menu was previously hidden, restore it
    hMenu := MenuMap[hWin] ; retrieve the Menu
    DllCall("SetMenu", "uint",hWin, "uint",hMenu)
    MenuMap.Delete(hWin)
  } else { ; menu wasn't previously hidden, hide it
    hMenu        	:= (DllCall("GetMenu", "uint", hWin)) ; get a ref to Win's menu
    MenuMap[hWin]	:= hMenu ; ...store it
    DllCall("SetMenu", "uint",hWin, "uint",0) ; hide the menu by uncoupling it from the parent window
  }
}

; Get winID of the last minimized window
Win_GetLastMinWin() { ; autohotkey.com/board/topic/39133-how-to-restore-the-last-minimized-window-solved/
  winIDs := WinGetList()
  Loop winIDs.Length {
    WinState := WinGetMinMax("ahk_id " winIDs[A_Index])
    if (WinState = -1) {
      return winIDs[A_Index]
    }
  }
}
Win_RestoreLastMinWin() { ; Restore the last minimized window
  LastMinWin := Win_GetLastMinWin()
  if (LastMinWin != "") {
    WinRestore("ahk_id " Win_GetLastMinWin())
  }
}

aTabSameApp(order:="+", wMin:="", modK:="Alt", key:="vkC0") { ; Alt-Tab-like switching between windows of the same app
  ; order: + ascending (most recently viewed window first), - descending (... last)
  ; wMin: ShowMin to switch to minimized windows
  ActiveProcess	:= WinGetProcessName("A")              	; name of the process for the active window
  procWinIDs   	:= WinGetList("ahk_exe " ActiveProcess)	; unique IDs of all existing windows
  procVisWinIDs	:= []                                  	; array for visible windows
  Loop procWinIDs.Length {
    this_id   	:= procWinIDs[A_Index]
    this_style	:= WinGetStyle("ahk_id " this_id)
    if (wMin = "ShowMin") {
      winCondition := (this_style & WS_Visible) && (this_style & WS_MaxBox)
    } else {
      winCondition := (this_style & WS_Visible) && (this_style & WS_MaxBox) && !(this_style & WS_Min)
    }
    if (winCondition) {
      procVisWinIDs.Push(this_id)
    }
  }
  ; Loop procWinIDs.Length {
  ;   this_id := procWinIDs[A_Index]
  ;   ; WinActivate("ahk_id " this_id)
  ;   this_class := WinGetClass("ahk_id " this_id)
  ;   this_title := WinGetTitle("ahk_id " this_id)
  ;   Result := MsgBox( "Visiting All Windows`n"
  ;     A_Index " of " procWinIDs.Length "`n"
  ;     "id " this_id "`n"
  ;     "class " this_class "`n"
  ;     "title " this_title "`nContinue?",,4)
  ;   if (Result = "No")
  ;     break
  ; }
  OpenWins	:= procVisWinIDs.Length	; number of open windows
  if (order = "+") {
    active_index	:= 2
  } else {
    active_index	:= OpenWins
  }
  if (OpenWins = 1)  {	; If only one Window exist...
    return            	; ...do nothing
  } else {
    Loop { ; repeat until Tab is released: wait for ` to be pressed and switch to the next window
      if (KeyWait(key, "D T0.5") = 1) {
        this_window := procVisWinIDs[active_index]
        WinActivate("ahk_id " this_window)
        if (order = "+") {
          active_index++
          if(active_index > OpenWins) {
            active_index := 1
          }
        } else {
          active_index--
          if(active_index < 1) {
            active_index := OpenWins
          }
        }
      }
    } until (!GetKeyState(modK, "P"))
  }
  return
}

SwapTwoWindows() { ; Instantly swap between last two windows without showing any icons/thumnails (like Alt-Tab does)
  static isNext  	:= true ; switch to the next window
  static AppID_To	:= 0

  active_id	:= WinGetID("A")	; unique ID of the active window

  if (isNext = true) { ; no switch or it's been reset (1. when this macro switched back OR 2. when a switch happened via other means)
    SendInput '!{Escape}'
    sleep 50
    AppID_To := WinGetID("A") ; get the ID of the switched-to window
    isNext := false
  } else if ((isNext = false) && (active_id = AppID_To)) { ; this macro made a switch and the window ID matches the one it switched to
    SendInput '!+{Escape}'
    isNext := true ; reset
  } else {
    SendInput '!{Escape}'
    sleep 50
    AppID_To := WinGetID("A") ; get the ID of the switched-to window
    isNext := false
  }
}
WinCycle(direction) {
  global wCycling
  if direction {
    send '!{Escape}'
  } else {
    send '!+{Escape}'
  }
  wCycling := true
  Return
}

dbgGetSysMonVars() {
  ; 1680×1050 window dimensions
  ; 1702×1012 smWinMax
  ; 1680× 956 smFullscreen
  ; 1706×1076 smMaxTrack
  ;        60 taskbar_H
  winMax_Xpx       	:= SysGet(smWinMax_Xpx)
  winMax_Ypx       	:= SysGet(smWinMax_Ypx)
  winFullscreen_Xpx	:= SysGet(smFullscreen_Xpx)
  winFullscreen_Ypx	:= SysGet(smFullscreen_Ypx)
  winMaxTrack_Xpx  	:= SysGet(smMaxTrack_Xpx)
  winMaxTrack_Ypx  	:= SysGet(smMaxTrack_Ypx)
  winFrameFixed_Xpx	:= SysGet(smFrameFixed_Xpx)
  winFrameFixed_Ypx	:= SysGet(smFrameFixed_Ypx)
  winBorder_Xpx    	:= SysGet(smBorder_Xpx)
  winBorder_Ypx    	:= SysGet(smBorder_Ypx)
  winEdge_Xpx      	:= SysGet(smEdge_Xpx)
  winEdge_Ypx      	:= SysGet(smEdge_Ypx)
  winSzFrame_Xpx   	:= SysGet(smSzFrame_Xpx)
  winSzFrame_Ypx   	:= SysGet(smSzFrame_Ypx)
  taskbar_Title    	:= "ahk_exe explorer.exe ahk_class Shell_TrayWnd"
  monAct_i         	:= getFocusWindowMonitorIndex()
  isMon            	:= MonitorGetWorkArea(monAct_i, &🖥️w←,&🖥️w↑,&🖥️w→,&🖥️w↓)
  🖥️w↔             	:= 🖥️w→ - 🖥️w←
  🖥️w↕             	:= 🖥️w↓ - 🖥️w↑
  🖥️↔              	:= A_ScreenWidth
  🖥️↕              	:= A_ScreenHeight
  WinGetPos(&taskbar_X,&taskbar_Y,&taskbar_W,&taskbar_H,taskbar_Title)

  dbgTT(0,monAct_i "=monAct_i"
    '`n' 🖥️↔              	"🖥️ ↔"              	"`t" 🖥️↕              	"=🖥️ ↕"
    '`n' 🖥️w↔             	"🖥️w↔"              	"`t" 🖥️w↕             	"=🖥️w↕"
    '`n' winMax_Xpx       	"=winMax_Xpx"       	'`t' winMax_Ypx       	"=winMax_Ypx="
    '`n' winFullscreen_Xpx	"=smFullscreen_Xpx="	'`t' winFullscreen_Ypx	"=smFullscreen_Ypx"
    '`n' winMaxTrack_Xpx  	"=winMaxTrack_Xpx"  	'`t' winMaxTrack_Ypx  	"=winMaxTrack_Ypx" '`n`t' taskbar_H "=taskbar_H"
    '`n' winFrameFixed_Xpx	"=winFrameFixed_Xpx"	'`t' winFrameFixed_Ypx	"=winFrameFixed_Ypx"
    '`n' winBorder_Xpx    	"=winBorder_Xpx"    	'`t' winBorder_Ypx    	"=winBorder_Ypx"
    '`n' winSzFrame_Xpx   	"=winSzFrame_Xpx"   	'`t' winSzFrame_Ypx   	"=winSzFrame_Ypx"
    ,🕐:=5,id:=3,x:=1550,y:=850)
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

/*
Win_FWT2(hwnd:="") { ;alternative via Maps instead of object properties
  static A	:= Map()

  if (!hwnd)	; If no window handle is supplied, use the window under the mouse
    MouseGetPos , , &hwnd
  WinT	:= "ahk_id " hwnd   	; Store WinTitle
  S   	:= WinGetStyle(WinT)	; Get window style
  if (S & WS_Borderless) { ; If not borderless
    A[WinT "Style"] := S & WS_Borderless	; Store existing style
    IsMaxed := WinGetMinMax(WinT)       	; Get/store whether the window is maximized
    if (A[WinT "Maxed"] := IsMaxed = 1 ? true : false)
      WinRestore WinT
    WinGetPos &wX, &wY, &wW, &wH, WinT ; Store window size/location
    A[WinT "wX"] := wX, A[WinT "wY"] := wY, A[WinT "wW"] := wW, A[WinT "wH"] := wH
    WinSetStyle("-" WS_Borderless, WinT)           ; Remove borders
    hMon := DllCall("User32\MonitorFromWindow", "Ptr", hwnd, "UInt", Monitor_DefaultToNearest)
    VarSetStrCapacity(&monInfo, 40), NumPut(40, monInfo, 0, "UInt")
    DllCall("User32\GetMonitorInfo", "Ptr", hMon, "Ptr", &monInfo)
    ;;;;/es update to only add offsets
    ; WinMove monLeft   := NumGet(monInfo,  4, "Int")  ; Move and resize window Fullscreen
    ;       , monTop    := NumGet(monInfo,  8, "Int")
    ;       ,(monRight  := NumGet(monInfo, 12, "Int")) - monLeft
    ;       ,(monBottom := NumGet(monInfo, 16, "Int")) - monTop
    ;       ,WinT
  } else if (A.Has(WinT "Style")) {         	; If borderless
    WinSetStyle("+" A[WinT "Style"], WinT)  	; Reapply borders
    WinMove A[WinT "wX"], A[WinT "wY"]      	; Return to original position
          , A[WinT "wW"], A[WinT "wH"], WinT	;
    ; if (A[WinT "Maxed"])                  	; Maximize if required
      ; WinMaximize WinT
    A.Delete(WinT "Style")
    A.Delete(WinT "wX"), A.Delete(WinT "wY")
    A.Delete(WinT "wW"), A.Delete(WinT "wH")
  }
}
*/
