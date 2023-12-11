#Requires AutoHotKey 2.1-alpha.4

#include <UIA>
#include <Acc2>
#include <winapi Struct>
#include <libFunc Dbg>	; Functions: Debug
class win {
  static get⎀(&⎀←,&⎀↑,&⎀↔:=0,&⎀↕:=0) {
    static ptcProp	:= ["IsTextPatternAvailable","HasKeyboardFocus"]
     , ptcScope   	:= UIA.TreeScope.Element ; Element or Subtree (very slow on some web pages https://www.autohotkey.com/boards/viewtopic.php?f=82&t=114802&p=545176#p545176)
     , ptcMode    	:= UIA.AutomationElementMode.None
     , pointCache 	:= UIA.CreateCacheRequest(ptcProp,,ptcScope,ptcMode) ; (,patterns?,,,filter?)

    win.get⎀GUI(&⎀←,&⎀↑,&⎀→,&⎀↓,&⎀↔,&⎀↕,&⎀Blink,&⎀isVis) ; 1 get caret via GetGUIThreadInfo

    if IsSet(⎀isVis) and ⎀isVis {
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
    static ws        	:= winapi_Struct ; various win32 API structs
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

; Borderless window is larger than regular, apply Fix=1 to make Window position/size match border/-less
Win_TitleToggle(PosFix:=0, id:=unset, Sign:="^") {
  static winDemax_id	:= Map()
  ; dbgGetSysMonVars()

  if !IsSet(id) { ; if no id passed, use Active window
    id	:= WinGetID("A")
  }
  winTitleMatch	:= "ahk_id " id
  MinMax       	:= WinGetMinMax(winTitleMatch) ; Min -1, Max 1, Neither 0
  winIDs       	:= WinGetList(  winTitleMatch)
  winID        	:= winIDs[1]

  winSzFrame_Xpx	:= SysGet(smSzFrame_Xpx) ; sizing border around the perimeter of a window
  winSzFrame_Ypx	:= SysGet(smSzFrame_Ypx)
  Style         	:= WinGetStyle(winID)
  StyleHex      	:= Format("{1:#x}", Style)
  bOffset       	:= 10                                                                	; Border width needed to adjust WinPos
  OffT          	:= {x: winSzFrame_Xpx*2,y:0, w:-winSzFrame_Xpx*4,h:-winSzFrame_Ypx*2}	; has Title , move → by 1×, + Width by 2× and Height by 1× BorderOffset
  OffB          	:= {x:-winSzFrame_Xpx*2,y:0, w: winSzFrame_Xpx*4,h: winSzFrame_Ypx*2}	; Borderless, move ← by 1×, − Width by 2× and Height by 1× BorderOffset

  WinSetStyle(Sign WS_Borderless, winID)
  WinGetPos(&wX,&wY, &wW,&wH, winID)
  if (MinMax = 1) { ;     Maximized: Restore and Maximize back
    winDemax_id[winTitleMatch] := winID ; store demaxed winID so that we can max it back later
    WinRestore(wTitle:=winID)
    ; WinMaximize winID ; BUGs, covers taskbar, so replace maximizing back with manually setting max area without the taskbar
    monAct_i	:= getFocusWindowMonitorIndex()
    isMon   	:= MonitorGetWorkArea(monAct_i, &monWork←,&monWork↑,&monWork→,&monWork↓)
    if (isMon = "") {
      return
    }
    monWork_W	:= monWork→ - monWork←
    monWork_H	:= monWork↓ - monWork↑
    ; if (PosFix = 0) { ; avoid artifacts from adding/removing borders, no pos/size change
      WinMove(x:=0,y:=0,width:=monWork_W,height:=monWork_H,wTitle:=winID)
    ; } else {
      ; WinMove 0,0,A_ScreenWidth,H-25, winTitleMatch ; X+13,Y+13,W-26,H-26 ;Still acts like maximized e.g. after Alt+Tab
    ; }
  } else          { ; NOT Maximized
    if (winDemax_id.has(winTitleMatch)) and (winDemax_id[winTitleMatch] = winID) { ; maximize previously demaxed window
      winDemax_id[winTitleMatch] := ""
      WinMaximize(winID)
      return
    }
    if (PosFix = 0) { ; avoid artifacts from adding/removing borders, no pos/size change
      if not winID {
        return
      }
      WinMove(,,width:=wW-1,,wTitle:=winID)
      WinMove(,,width:=wW  ,,wTitle:=winID)
      ; Alternative way (but more noticeablele): Maximize and Restore
      ; WinMaximize winID
      ; WinRestore  winID
      ; WinActivate winID
      ; WinRestore winID ; NOT reliable, sometimes restores in the background
      ; Doesn't work: WinRedraw/WinHide/WinShow "A"
    } else {  ; change position/size to make border/-less windows the same
      if (Style & WS_Caption) { ; has Title
        WinMove wX+OffT.x,,wW+OffT.w,wH+OffT.h, winID
        dbgTT(3,Text:="Has title WS_CAPTION 0x00C00000, var.StyleHex={" StyleHex "}",Time:=2,id:=4,X:=1550,Y:=850)
      } else { ; Borderless
        WinMove wX+OffB.x,,wW+OffB.w,wH+OffB.h, winID
        dbgTT(3,Text:="Else, var.StyleHex={" StyleHex "}",Time:=2,id:=4,X:=1550,Y:=850)
      }
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
  🖥️w↔             	:= 🖥️w→-🖥️w←
  🖥️w↕             	:= 🖥️w↓-🖥️w↑
  WinGetPos(&taskbar_X,&taskbar_Y,&taskbar_W,&taskbar_H,taskbar_Title)

  dbgTT(0,Text:=monAct_i "=monAct_i`n" 🖥️w↔ "🖥️w↔" "`t" 🖥️w↕ "=🖥️w↕`n" winMax_Xpx "=winMax_Xpx"  "`t" winMax_Ypx "=winMax_Ypx=" "`n" winFullscreen_Xpx "=smFullscreen_Xpx="  "`t" winFullscreen_Ypx "=smFullscreen_Ypx"  "`n" winMaxTrack_Xpx "=winMaxTrack_Xpx" "`t" winMaxTrack_Ypx "=winMaxTrack_Ypx"  "`n`t" taskbar_H "=taskbar_H" "`n" winFrameFixed_Xpx "=winFrameFixed_Xpx" "`t" winFrameFixed_Ypx "=winFrameFixed_Ypx"
    "`n" winBorder_Xpx "=winBorder_Xpx" "`t" winBorder_Ypx "=winBorder_Ypx"
    "`n" winSzFrame_Xpx "=winSzFrame_Xpx" "`t" winSzFrame_Ypx "=winSzFrame_Ypx"
    , Time:=5,id:=3,X:=1550,Y:=850)
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
