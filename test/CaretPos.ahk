; f3::getpos1()
getpos1() {
  static k     	:= keyConstant._map, lbl := keyConstant._labels ; various key name constants, gets vk code to avoid issues with another layout
   , get⎀      	:= win.get⎀.Bind(win), get⎀GUI	:= win.get⎀GUI.Bind(win), get⎀Acc := win.get⎀Acc.Bind(win), coordClient→Screen := win.coordClient→Screen.Bind(win)
   , s         	:= helperString
   , ptcProp   	:= ["IsTextPatternAvailable","HasKeyboardFocus"]
   , ptcScope  	:= UIA.TreeScope.Element ; Element or Subtree (very slow on some web pages https://www.autohotkey.com/boards/viewtopic.php?f=82&t=114802&p=545176#p545176)
   , ptcMode   	:= UIA.AutomationElementMode.None
   , pointCache	:= UIA.CreateCacheRequest(ptcProp,,ptcScope,ptcMode) ; (,patterns?,,,filter?)

  get⎀(&⎀←a:=0,&⎀↑a:=0,&⎀↔:=0,&⎀↕:=0)
  get⎀GUI(&⎀←c:=0, &⎀↑c:=0)
  get⎀Acc(&⎀←d:=0, &⎀↑d:=0)
  isUIAEditableSm := 0, isUIAEditableEl := 0
  perfT()
  try {
    pt	:= UIA.ElementFromPoint(        ⎀←d,⎀↑d,,pointCache) ; alt ElementFromPoint
    ; dbgMsg(0,type(pt))
    ; pt.Highlight()
    ; dbgMsg(0,type(pt))
    isUIAEditableEl	:= pt.CachedIsTextPatternAvailable && pt.CachedHasKeyboardFocus
    ; dbgTT(0,isUIAEditableEl ' isUIAEditableEl')
  }
  t2 := perfT()
  try {
    pt             	:= UIA.SmallestElementFromPoint(⎀←d,⎀↑d,,pointCache) ; alt ElementFromPoint
    isUIAEditableSm	:= pt.CachedIsTextPatternAvailable && pt.CachedHasKeyboardFocus
    ; dbgMsg(0,isUIAEditableSm ' isUIAEditableEl')
  }
  t1 := perfT()

  CoordMode("Caret", "Screen")
  CaretGetPos(&⎀←b1:=0, &⎀↑b1:=0)
  CoordMode("Caret", "Window")
  CaretGetPos(&⎀←b2:=0, &⎀↑b2:=0)
  CoordMode("Caret", "Client")
  CaretGetPos(&⎀←b3:=0, &⎀↑b3:=0)
  ⎀←b1:=⎀←b1=''?0:⎀←b1,⎀↑b1:=⎀↑b1=''?0:⎀↑b1,⎀←b2:=⎀←b2=''?0:⎀←b2,⎀↑b2:=⎀↑b2=''?0:⎀↑b2,⎀←b3:=⎀←b3=''?0:⎀←b3,⎀↑b3:=⎀↑b3=''?0:⎀↑b3,
  ⎀←e := 0, ⎀↑e := 0
  xa := '', ya := ''
  xb1:= '', yb1:= ''
  xb2:= '', yb2:= ''
  xb3:= '', yb3:= ''
  xc := '', yc := ''
  xd := '', yd := ''
  xe := '', ye := ''
  xf := '', yf := ''
  GetCaretPos1(&x, &y) {
    static Size:=8+(A_PtrSize*6)+16, hwndCaret:=8+A_PtrSize*5
    Static CaretX:=8+(A_PtrSize*6), CaretY:=CaretX+4
    Info	:= Buffer(Size,0)
    NumPut('int',Size,Info,0)
    DllCall("GetGUIThreadInfo", "UInt", 0, "Ptr",Info), x:=y:=""
    if !(HWND:=NumGet(Info, hwndCaret, "Ptr")) {
      return 0
    }
    x:=NumGet(Info, CaretX, "Int"), y:=NumGet(Info, CaretY, "Int")
    pt := Buffer(8,0), NumPut('int',y,NumPut('int',x,pt,0))
      ⎀←f:=NumGet(pt,0,'int')
    , ⎀↑f:=NumGet(pt,4,'int')
    DllCall("ClientToScreen", "Ptr",HWND, "Ptr",pt)
    msgbox('winID_caret ' WinGetTitle(HWND) '`n' 'winID_active ' WinGetTitle(WinGetID('A')))
      ⎀←fs:=NumGet(pt,0,'int')
    , ⎀↑fs:=NumGet(pt,4,'int')
     x:=⎀←fs
    ,y:=⎀↑fs
    return 1
  }
  ; GetCaretPos1(&⎀←f:=0,&⎀↑f:=0)

  if (winID := WinGetID('A')) {
    coordClient→Screen(⎀←a  	,⎀↑a 	,&xa 	,&ya 	,winID)
    coordClient→Screen(⎀←b1 	,⎀↑b1	,&xb1	,&yb1	,winID)
    coordClient→Screen(⎀←b2 	,⎀↑b2	,&xb2	,&yb2	,winID)
    coordClient→Screen(⎀←b3 	,⎀↑b3	,&xb3	,&yb3	,winID)
    coordClient→Screen(⎀←c  	,⎀↑c 	,&xc 	,&yc 	,winID)
    coordClient→Screen(⎀←d  	,⎀↑d 	,&xd 	,&yd 	,winID)
    coordClient→Screen(⎀←e  	,⎀↑e 	,&xe 	,&ye 	,winID)
    ; coordClient→Screen(⎀←f	,⎀↑f 	,&xf 	,&yf 	,winID)
  }
  Picker := Gui(, 'test picker')
  Picker.Opt(" +ToolWindow")   ;e +AlwaysOnTop +ToolWindow avoids a taskbar button and an alt-tab menu
  GuiOptX := " -E0x200 H" ;0x200 WS_EX_CLIENTEDGE remove vertical internal border ; lexikos.github.io/v2/docs/misc/Styles.htm#ListBox
    Picker.SetFont(CharGUIFontColV " s" CharGUIFontSize " w400", CharGUIFontName)
  LocLB := " x" xb3 ' y' yb3
  ; Picker.Show(LocLB "AutoSize")	;GuiTitle a, xCenter yCenter, GuiTitle

   ⎀←b3	:= ⎀←b3	= 0 ? ''	:⎀←b3	,⎀↑b3	:= ⎀↑b3	= 0 ? ''	:⎀↑b3
  ,⎀←a 	:= ⎀←a 	= 0 ? ''	:⎀←a 	,⎀↑a 	:= ⎀↑a 	= 0 ? ''	:⎀↑a
  ,⎀←c 	:= ⎀←c 	= 0 ? ''	:⎀←c 	,⎀↑c 	:= ⎀↑c 	= 0 ? ''	:⎀↑c
  ,⎀←d 	:= ⎀←d 	= 0 ? ''	:⎀←d 	,⎀↑d 	:= ⎀↑d 	= 0 ? ''	:⎀↑d
  ,⎀←b1	:= ⎀←b1	= 0 ? ''	:⎀←b1	,⎀↑b1	:= ⎀↑b1	= 0 ? ''	:⎀↑b1
  ,⎀←b2	:= ⎀←b2	= 0 ? ''	:⎀←b2	,⎀↑b2	:= ⎀↑b2	= 0 ? ''	:⎀↑b2
  ,⎀←e 	:= ⎀←e 	= 0 ? ''	:⎀←e 	,⎀↑e 	:= ⎀↑e 	= 0 ? ''	:⎀↑e
  ,xa  	:= xa  	= 0 ? ''	: xa 	, ya 	:= ya  	= 0 ? ''	: ya
  ,xb1 	:= xb1 	= 0 ? ''	: xb1	, yb1	:= yb1 	= 0 ? ''	: yb1
  ,xb2 	:= xb2 	= 0 ? ''	: xb2	, yb2	:= yb2 	= 0 ? ''	: yb2
  ,xb3 	:= xb3 	= 0 ? ''	: xb3	, yb3	:= yb3 	= 0 ? ''	: yb3
  ,xc  	:= xc  	= 0 ? ''	: xc 	, yc 	:= yc  	= 0 ? ''	: yc
  ,xd  	:= xd  	= 0 ? ''	: xd 	, yd 	:= yd  	= 0 ? ''	: yd
  ,xe  	:= xe  	= 0 ? ''	: xe 	, ye 	:= ye  	= 0 ? ''	: ye
  ,xf  	:= xf  	= 0 ? ''	: xf 	, yf 	:= yf  	= 0 ? ''	: yf
  dbgtxt := ''
  dbgtxt .= WinGetTitle(winID) '`n'
  dbgtxt .= 'Original' '`t'	'`t' 'Client→S' '`t'	'`tComment`n'
  dbgtxt .= 'x' '`t' 'y'   	'`t' 'x' '`t' 'y'   	'`t`n'
  dbgtxt .= ⎀←b3 '`t' ⎀↑b3 	'`t' xb3  '`t' yb3  	'`tb CGP@Client' '`n'
  dbgtxt .= ⎀←a '`t' ⎀↑a   	'`t' xa  '`t' ya    	'`ta get⎀`n'
  dbgtxt .= ⎀←c '`t' ⎀↑c   	'`t' xc  '`t' yc    	'`tc get⎀GUI`n'
  dbgtxt .= ⎀←d '`t' ⎀↑d   	'`t' xd  '`t' yd    	'`td get⎀Acc`n'
  dbgtxt .= ⎀←b1 '`t' ⎀↑b1 	'`t' xb1  '`t' yb1  	'`tb CGP@Scr' '`n'
  dbgtxt .= ⎀←b2 '`t' ⎀↑b2 	'`t' xb2  '`t' yb2  	'`tb CGP@Win' '`n'
  dbgtxt .= ⎀←e '`t' ⎀↑e   	'`t' xe  '`t' ye    	'`te manual 0×0`n'
  dbgtxt .= isUIAEditableSm ' editableSmallestEl? in t=' round(t1,0) '`n'
  dbgtxt .= isUIAEditableEl ' editable        El? in t=' round(t2,0)
  ; dbgtxt .= ⎀←f '`t' ⎀↑f	'`t' xf  '`t' yf	'`te myCGP`n'
  dbgMsg(0,dbgtxt)
}
