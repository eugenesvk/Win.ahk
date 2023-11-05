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
  static get⎀Acc(&⎀←,&⎀↑,&⎀↔:=0,&⎀↕:=0) {
    static OBJID_CARET := 0xFFFFFFF8
    ; CoordMode('Caret','Client')
    AccObject	:= Acc_ObjectFromWindow(WinExist('A'), OBJID_CARET)
    Pos      	:= Acc_Location(AccObject)
    try ⎀← := Pos.x, ⎀↑ := Pos.y
      , ⎀↔ := Pos.w, ⎀↕ := Pos.h
    return ⎀← || ⎀↑ ;;; todo: what if 0,0 is a valid caret position?
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
    🖥️w↔    	:= 🖥️w→-🖥️w←
    🖥️w↕    	:= 🖥️w↓-🖥️w↑
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
    winID := (winIDarg = "")
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

getFocusWindowMonitorIndex() { ; converted from stackoverflow.com/a/68547452
  monCount := MonitorGetCount() ;Get number of monitor
  WinGetPos(&🗔↖x,&🗔, &🗔Width,&🗔Height, "A") ; Get the position of the focus window
  monSubAreas := []  ; Make an array to hold the sub-areas of the window contained within each monitor
  Loop monCount { ;Iterate through each monitor
    MonitorGetWorkArea(A_Index, &🖥️←,&🖥️↑,&🖥️→,&🖥️↓) ; Get Monitor working area

    ;Calculate sub-area of the window contained within each monitor
    xStart	:= max(🗔↖x           , 🖥️←)
    yStart	:= max(🗔              , 🖥️↑)
    xEnd  	:= min(🗔↖x + 🗔Width , 🖥️→)
    yEnd  	:= min(🗔    + 🗔Height, 🖥️↓)
    area  	:= (xEnd - xStart)
             * (yEnd - yStart)
    monSubAreas.push({area:area, index:A_Index}) ;Remember these areas, and which monitor they were associated with
  }
  if(monSubAreas.Length == 1) { ;If there is only one monitor in the array, then you already have your answer
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
