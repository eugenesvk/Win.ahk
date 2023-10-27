#Requires AutoHotKey 2.1-alpha.4

ScrollHCombo(Direction:="L", ScrollHUnit:="Pg",Rep:=1, WheelHMult:=1, MSOMult:=1) {
  ;!!! fails with COM (Word/Excel...) and UIA-enabled AHK due to some weird permissions mismatch (autohotkey.com/boards/viewtopic.php?p=432502#p432452)
  ; 3 scroll←→ methods: via 1. COM 2. Scrollbar control 3. Mouse Wheel
  ; apps sorted via     1. exe→COM 2. exeScrollH        3. all others
  ; Direction  	:= "L" 	; [L]  Scroll            |L|eft    / |R|ight
  ; ScrollHUnit	:= "Pg"	; [Pg] Move scrollbar by |Pg| page / |L|ine 'Rep' # of times
  ; Rep        	:=  1  	; [1]  Scroll speed multiplier with scrollbar (natural number)
  ; WheelHMult 	:=  1  	; [1]    ...                   with mouse Wheel
  ; MSOMult    	:=  1  	; [1]    ...                   for  MS Office (natural number)

  ; alternative (not implemented, need to find a test app where 1–3 fail)
    ; SendInput '{Blind}{WheelRight}' ; reversely +WheelUp, though normally with !WheelUp and other modifiers
    ; SendInput '{Blind}+{WheelDown}'
    ; +WheelUp::WheelLeft

  global kbShift, WheelDelta

  if (dbg >= 3) ; (0x78=120) analyze amount by which the wheel was turned
    TT(Text:=Format("{1:#x}", A_EventInfo), Time:=2,id:=4,x:=-1,y:=-1)

  Rep    	:= Max(1,Round(Rep))
  MSOMult	:= Max(1,Round(MSOMult))
  hDist  	:= Max(1,Integer(WheelHMult*WheelDelta))
  to←    	:= (Direction="L") ? MSOMult : 0 ; Microsoft Office SmallScroll directions
  to→    	:= (Direction="L") ? 0       : MSOMult

  MouseGetPos(&mX, &mY, &mWinID, &mCtrlID, 2) ; or &mCtrlClassNN, 0)

  procName := WinGetProcessName(mWinID)
  if exe→COM.Has(procName) {        ; Scroll in Word/PowerPoint via COM
    try  ; use non-UIA AHK to avoid permissions mismatch error 0x800401e3 MK_E_UNAVAILABLE docs.microsoft.com/en-us/windows/win32/com/com-error-codes-1
      ComObjActive(exe→COM[procName]).ActiveWindow.SmallScroll(0,0,to→,to←)
    return
  }
  if HasValue(exeMDI, procName) {      ; MultipleDocumentInterface method to get control
    MouseGetPos(,,,&mCtrlID,3) ;(2)+1: get active/topmost child window of an MDI app; less accurate for others (inside a GroupBox)
  } else if (WinGetClass(mWinID) = "CabinetWClass") {
    mCtrlID	:= "ScrollBar1"            ; Windows File Explorer's scollbar
  }

  if HasValue(exeScrollH, procName){
    ScrollH(mWinID, mCtrlID, Direction, ScrollHUnit)
  } else {
    keyPass := HasValue(exeBrowser, procName) ? 0 : 1 ; ignore Shift status
    wParam	:= (hDist << 16)|kbShift*keyPass
    lParam	:= (mY    << 16)|mX
    ScrollWheelH(mWinID, mCtrlID, Direction, wParam, lParam)
  }
}
ScrollWheelH(winID, ctrlID, Direction, wParam, lParam) {
  global msgWheelH, WheelDelta

  if not winID                                   ; No Window given
    return
  dbgTxt	:= winID "=winID`n" ctrlID "=ctrlID`n" Direction "=Direction`n" Format("0x{:x}", wParam) "=wParam`n" Format("0x{:x}", lParam) "=lParam"
  errDir	:= "WARNING! Wrong Direction`n" Direction " given, but should be`nL or`nR"
  dbgTT(  dbgMin:=2, Text:=dbgTxt, Time:=2,id:=3,x:=1550,y:=850)
  if (Direction!="L") and (Direction!="R")
    dbgTT(dbgMin:=0, Text:=errDir, Time:=4,id:=2,x:=-1  ,y:=-1)
  if (Direction="L")
    wParam := -wParam
  if not ctrlID {
    PostMessage(msgWheelH, wParam, lParam,       , winID)
  } else {
    PostMessage(msgWheelH, wParam, lParam, ctrlID, winID)
  }
  ; WM_MOUSEHWHEEL, docs.microsoft.com/en-us/windows/win32/inputdev/wm-mousehwheel
    ;       WM_MOUSEHWHEEL, wParam, lParam,Control, WinTitle...
    ; wParam
      ; high-order word: rotation distance X×WheelDelta(120), −Left, +Right
      ;  low-order word: virtual keys' status
    ; lParam: pointer coordinates (relative to screen): Y(high)/X(low-order word)
}
ScrollH(winID, ctrlID, Direction,ScrollHUnit:="Ln", Rep:=1) {
  global msgScrollH, scroll←Ln,scroll←Pg,scroll→Ln,scroll→Pg

  if (winID = 0)                      ; No Window given
    return

  RepMax 	:= 20
  dbgTxt 	:= winID " = winID`n" Direction " = Direction" "`n" ScrollHUnit " = ScrollHUnit`n" Rep " = Rep"
  errDir 	:= "WARNING! Wrong Direction`n"   Direction   " given, but should be`nL or `nR"
  errUnit	:= "WARNING! Wrong ScrollHUnit`n" ScrollHUnit " given, but should be`nLn or`nPg"
  dbgTT(  dbgMin:=2, Text:=dbgTxt , Time:=2,id:=3,X:=1550,Y:=850)
  if (Direction!="L")    and (Direction!="R")
    dbgTT(dbgMin:=0, Text:=errDir , Time:=4,id:=2,x:=-1  ,y:=-1)
  if (ScrollHUnit!="Ln") and (ScrollHUnit!="Pg")
    dbgTT(dbgMin:=0, Text:=errUnit, Time:=4,id:=2,x:=-1  ,y:=-1)

  if not IsInteger(Rep) or (Rep < 1) {
    Rep := 1
  } else if (Rep > RepMax) {
    Rep := RepMax
  }
  dir := Direction  ="L"  ? "←"  : "→"
  by  := ScrollHUnit="Ln" ? "Ln" : "Pg"

  Loop Rep {
    if not ctrlID {
      PostMessage(msgScrollH, scroll%dir%%by%, 0     ,       , winID)
    } else {
      PostMessage(msgScrollH, scroll%dir%%by%, 0     , ctrlID, winID)
    }
      ;          (WM_HSCROLL, wParam         , lParam,Control, WinTitle...
      ; wParam (word is 16 bytes, so HIWORD can be set as 'x << 16')
        ; HIWORD: (only if LOWORD is SB_THUMBPOSITION/SB_THUMBTRACK) current position
        ; LOWORD: user's scrolling request
      ; lParam: scroll bar control's handle (if used); NULL if sent by a standard scroll bar
  }
}
