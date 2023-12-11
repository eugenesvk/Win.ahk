#Requires AutoHotKey 2.0.10
; —————————— User configuration ——————————
global ucfg🖰hide := Map(
   'modiHide'         	, true  	; true : modifiers like ‘⇧a’ hide    🖰 pointer just like ‘a’ (register hotkeys with ‘*’, i.e. fire if any modifier is held down)
   ;                  	        	  false: only            ‘a’ hides   🖰 pointer, not ‘⇧a’
 , 'modAllow🖰Pointer' 	, "‹⎈⇧›"	; list of modifiers that do NOT hide 🖰 pointer, can be in AHK format like >! for Right Alt or ⇧◆⎇⎈ for Shift/Win/Alt/Control with ‹Left and Right› side indicators
   ;                  	   ‹⎈   	  for Left  Control
   ;                  	    ⇧›  	  for Right Shift
 ; disable 🖰 buttons  	        	while the pointer is hidden
 , 'cfgDisable🖰Btn'   	, "LMR" 	; clicks          , string of L/M/R for Left/Middle/Right button
 , 'cfgDisable🖱'      	, "UDLR"	; wheel scrolling , string of U/D/L/R for directions Up/Down/Left/Right
 ;                    	        	;
 , 'limit2text'       	, true  	; hide only in text fields (don't hide when using alpha keys to execute commands)
 , 'suppressionMethod'	, "gui" 	;|gui|sys¦both¦ method of hiding the pointer
  ; gui               	        	  create our own gui, attach it to the app's window, and hide the pointer (might break some functionality when hiding, e.g., sending key events via mouse extra buttons)
  ; sys               	        	  hide system scheme pointers (Ibeam, Arrow, etc.), but fails with app-specific ones like a Cross🞧 in Excel
  ; both              	        	  use both sys and gui
 , 'attachGUI_🖰'      	, 0     	;|0|1 attach our gui element to: Active window has keyboard focus and if mouse is hovering over a different window
  ; active window     	  0     	 hides the pointer even if the active window is different, but then keyboard events from the mouse (e.g., ␈ with a side mouse buttons) aren't blocked (they are blocked by the gui element, but the gui element belongs to inactive window while typing happens in the active window)
  ; window @ pointer  	  1     	 doesn't hide the pointer of the active window (if different), but blocks keyboard events from the mouse
 ; restore 🖰 pointer  	        	only if mouse moved by more than ↓ thresholds (in pixels); 0 = show right away
 , 'minΔ🖰x'           	, 0     	;
 , 'minΔ🖰y'           	, 0     	;
  )
; do NOT hide 🖰 pointer in the following apps
GroupAdd("no🖰HideOnType"	, "ahk_exe your_app_1.exe") ; case sensitive!
GroupAdd("no🖰HideOnType"	, "ahk_exe your_app_2.exe") ; or any other match per autohotkey.com/docs/v2/lib/WinActive.htm

; Add non-English layouts:
  ; get the name of the layout to be used in scripts (a two-letter abbreviation like ‘en’)
    ; switch to the layout
    ; uncomment ‘dbgMsg(0,sKbdCurrent,'Current language name')’ line below
    ; relaunch the script and get the result in the popped up message box
  ; add labels in your layout to the ‘regWatchers’ function similar to ‘keys_m["en"] := "’ in the script below, letter positions must match that of the 'en' layout
  ; add your full layout to the ‘keyConstant’ class in ‘constKey’ library similar to ‘labels['en'] := "’
; —————————— Test ——————————
; !1::sys🖰Pointer(Toggle) ;
; !2::app🖰Pointer(Toggle)
; !3::sys🖰Btn(Toggle)
; !4::sys🖰Btn(Off)
; !5::sys🖰Btn(On)
; !6::sys🖰Pointer(Off)
; !7::sys🖰Pointer(On)
; !8::app🖰Pointer(Off)
; !9::app🖰Pointer(On)

; —————————— Script ——————————
#include <OnMouseEvent>
; ↓ standalone
#include %A_scriptDir%\gVar\var.ahk	; Global variables
#include <UIA>                     	; allows limiting script to windows with visible Text caret; assumes the library is at ‘Lib/uia.ahk’
#include <libFunc Dbg>             	; Functions: Debug
#include <Locale>                  	; Various i18n locale functions and win32 constants
#include <constKey>                	; various key constants
#include <str>
#include <sys>

preciseTΔ() ; start timer for debugging
if (isStandAlone := (A_ScriptFullPath = A_LineFile)) {
  dbg := 4         	; Level of debug verbosity (0-none)
  SendMode("Input")	; Recommended for new scripts due to its superior speed and reliability
  Persistent       	; Ensure the cursor is made visible when the script exits.
}

; convert user config into a case-insensitive map
global cfg🖰hide := Map()
cfg🖰hide.CaseSense := 0
for cfg🖰hidek,cfg🖰hidev in ucfg🖰hide {
  cfg🖰hide[cfg🖰hidek] := cfg🖰hidev
}

OnExit(exitShow🖰Pointer, )
global Init	:= -2
 , On      	:=  1
 , Off     	:=  0
 , Toggle  	:= -1
 , isSys🖰PointerHidden := false ; system suppression method replaces pointer icons with transparent ones, but doesn't hide disable the pointer itself, so need to track it separately from the API command used in is🖰PointerVisible()

hk🖰PointerHide(ThisHotkey) {            ; Hide 🖰 pointer
  static K	:= keyConstant, vk:=K._map, vkr:=K._mapr, vkl:=K._maplng, vkrl:=K._maprlng, sc:=K._mapsc  ; various key name constants, gets vk code to avoid issues with another layout
    , s   	:= helperString
    , _d  	:= 3
  dbgTT(_d,'hk🖰P ' ThisHotkey, t:=1)
  🖰PointerHide()
}
🖰PointerHide() {
  static get⎀        	:= win.get⎀.Bind(win)
   , modAllow🖰Pointer	:= cfg🖰hide['modAllow🖰Pointer']
   , limit2text      	:= cfg🖰hide['limit2text']
   , suppress        	:= cfg🖰hide['suppressionMethod']
  dbgtxt := ''
  if isAnyUserModiPressed(modAllow🖰Pointer) {
    ; dbgtxt .= 'modAllow🖰Pointer pressed, skipping hide'
  } else if limit2text {
    if get⎀(&⎀←,&⎀↑) { ; only hide if inside an editable text field
      ; dbgtxt .= 'sys🖰P 0'
      if suppress = 'sys' or suppress = 'both' {
        sys🖰Pointer(Off)
      }
      if suppress = 'gui' or suppress = 'both' {
        app🖰Pointer(Off)
        dbgtt(0,'✗ 🖰PointerHide gui text',t:=3,i:=2,0,0) ;
      }
    } else {
      ; dbgtxt .= 'outside a text field, skipping hide'
    }
  } else {
    ; dbgtxt .= 'sys🖰P 0'
    if suppress = 'sys' or suppress = 'both' {
      sys🖰Pointer(Off)
    }
    if suppress = 'gui' or suppress = 'both' {
      app🖰Pointer(Off)
      ; dbgtt(0,'✗ 🖰PointerHide gui else',t:=3,i:=2,0,0) ;
    }
      ; dbgtt(0,'suppress=' suppress,t:=3,i:=4,0,250) ;1
      dbgtt(0,'suppress=' suppress,t:=3,i:=4,0,250) ;1
  }
  dbgTT(3,dbgtxt,t:=1,i:=1,x:=0,y:=850)
}
exitShow🖰Pointer(A_ExitReason, ExitCode) { ; Show 🖰 pointer
  static suppress		:= cfg🖰hide['suppressionMethod']
  if suppress = 'sys' or suppress = 'both' {
    sys🖰Pointer(On)
  }
  if suppress = 'gui' or suppress = 'both' {
    app🖰Pointer(On)
    ; dbgtt(0,'✓exitShow🖰Pointer gui',t:=3,i:=3,0,50) ;
  }
    ; dbgtt(0,'suppress=' suppress,t:=3,i:=4,0,350) ;
    dbgtt(0,'suppress=' suppress,t:=3,i:=4,0,350) ;
  ExitApp()
}

getKeys🖰hide(&lbl:='') { ; Register the keys you want to listen on
  static locInf	:= localeInfo.m  ; Constants Used in the LCType Parameter of lyt.getLocaleInfo, lyt.getLocaleInfoEx, and SetLocaleInfo
   , s         	:= helperString
   , K         	:= keyConstant , vk := K._map, sc := K._mapsc  ; various key name constants, gets vk code to avoid issues with another layout
   ; , sKbdSys 	:= lyt.getLocaleInfo("SEnLngNm",) ; system layout
   , keys_m    	:= Map()
   , isInit    	:= false
   , keys_def  	:= ""
   , vkKeys    	:= []
   , lblEnKeys 	:= '' ; store english labels of successfully registered hotkeys to match against dupe hotkeys in PressH
   , useSC     	:= Map() ; use Scan Code syntax for keys, not VKs (e.g., Delete)
  ; dbgTT(4, Text:='System language name`n' sKbdSys, Time:=4)

  if not isInit {
    useSC.CaseSense := 0
    keys_m.CaseSense := 0 ; make key matching case insensitive
    keys_m["en"] := "
      ( Join LTrim
       `1234567890-=␈␡
        qwertyuiop[]
        asdfghjkl;'\
        zxcvbnm,./
        ␠
       )"
    keys_m["ru"] := "
      ( Join LTrim
       ё1234567890-=␈␡
        йцукенгшщзхъ
        фывапролджэ\
        ячсмитьбю.
        ␠
       )"
    useSC[vk['␡']] := sc['␡'] ; Delete bugs with VK, use SC
    keys_def   	:= keys_m.Get("en")
    ; keys     	:= keys_m.Get(sKbdSys,keys_def) ; if continues to bug
    curlayout  	:= lyt.GetCurLayout(&hDevice, &idLang)
    sKbdCurrent	:= lyt.getLocaleInfo("en",idLang)
    keys       	:= keys_m.Get(sKbdCurrent,keys_def) ; use ←↑ to register instead (and throw out 0 keys, use ↓ first)
    _dbg := "", _dbg0 := "", _dbgid := 1
    ; _dbg .= 'sKbdSys ' sKbdSys '`n'
    ; _dbg .= 'sKbdCurrent ' sKbdCurrent '`n'
    ; dbgMsg(0,sKbdCurrent,'Current language name')
    loop parse keys {
      ; if (raw_vk := GetKeyVK(A_LoopField)) = 0 { ;
        ; ; _dbg0 .= A_LoopField, _dbgid += 1
        ; ; dbgTT(0,A_Index . " " A_LoopField " ",t:=4,id:=Mod(_dbgid,20),x:=_dbgid*50,y:=_dbgid*50)
        ; continue
      ; } else {
        ; vkKeys.Push(format("vk{1:X}",raw_vk))
      if (vkC := s.key→ahk(A_LoopField)) { ; vkC := Format("vk{:X}",GetKeyVK(c)) bugs with locale
        vk_or_sc := useSC.Get(vkC,vkC) ; replace VK with SC if it was manually added to useSC
        vkKeys.Push(vk_or_sc)
        lblEnKeys .= SubStr(keys_m["en"],A_Index,1)
        ; _dbg .= A_LoopField . "=" . format("{1:X}",GetKeySC(A_LoopField))
          ; . " " . format("{1:X}",GetKeyVK(A_LoopField))
          ; . "`t"
      }
    }
    ; msgbox(StrLen(_dbg0) " skipped keys = " _dbg0 "`n" _dbg   , sKbdCurrent)
    ; dbgTT(0, StrLen(_dbg0)    . " zeroes and " . StrLen(keys) . "∑ in sys " . sKbdCurrent . " = " . _dbg0    . "`n" . _dbg, t:=3)
    isInit	:= true
  }
  lbl := lblEnKeys
  return vkKeys
}


isAnyUserModiPressed(user_modi,i:=1) { ; check if any of the user modifiers currently pressed
  static isInit	:= Map()
   , sys       	:= helperSystem
   , str       	:= helperString
   , ahk_modi  	:= Map()

  ; convert user modifier to a list of ahk modifiers
  if not isInit.Get(i,false) {
    ahk_modi[i] := str.parseModifierList(user_modi)
    isInit[i]	:= true
  }
  for modi in ahk_modi[i] {
    if GetKeyState(modi,"P") {
      return true
    }
  }
  return false
}



cfg2🖰Btn := Map(
  'L','LButton',
  'M','MButton',
  'R','RButton',
  )
cfg2🖱 := Map(
  'U','WheelUp',
  'D','WheelDown',
  'L','WheelLeft',
  'R','WheelRight',
  )
sys🖰Btn(OnOff) {
  static isInit    	:= false
   , disable🖰Btn   	:= []
   , cfgDisable🖰Btn	:= cfg🖰hide['cfgDisable🖰Btn']
   , cfgDisable🖱   	:= cfg🖰hide['cfgDisable🖱']
   , x             	:= A_ScreenWidth*.8
   , y             	:= 500, y1 := 550
   , _d            	:= 3
   , _d4            	:= 4
   , i1            	:= 3 ; tooltip index for on
   , i0            	:= 4 ; ...               off
   , _t            	:= '∞' ; time for tooltip
  if not isInit {
    dbgTT(_d4,"sys🖰Btn Init")
    isInit := true
    for cfg in cfg2🖰Btn { ; L
      if InStr(cfgDisable🖰Btn, cfg) { ; L in "LR"
        disable🖰Btn.Push(cfg2🖰Btn[cfg]) ; register LButton
      }
    }
    for cfg in cfg2🖱 { ; L
      if InStr(cfgDisable🖱, cfg) { ; U in "UD"
        disable🖰Btn.Push(cfg2🖱[cfg]) ; register WheelUp
      }
    }
  }
  if disable🖰Btn.Length = 0 {
    ; dbgTT(_d,"disable🖰Btn.Length=0" preciseTΔ(),_t,i0,x,y)
    return
  }
  HotIfWinNotActive("ahk_group no🖰HideOnType") ; turn on context sensitivity
  static hkModPrefix := cfg🖰hide['hkModPrefix']
  if        OnOff = Init {
    for 🖰Btn in disable🖰Btn {
      Hotkey(hkModPrefix 🖰Btn, doNothing, "Off") ; register in a disabled state
    }
    ; dbgTT(_d,"sys🖰Btn Init" preciseTΔ(),_t,i0,x,y)
  } else if OnOff = Off  {
    for 🖰Btn in disable🖰Btn {
      Hotkey(hkModPrefix 🖰Btn, doNothing, "On")  ; enable  doNothing → disable key
    }
    ; dbgTT(_d,"✗sys🖰Btn " preciseTΔ(),_t,i0,x,y)
  } else if OnOff = On   {
    for 🖰Btn in disable🖰Btn {
      Hotkey(hkModPrefix 🖰Btn, doNothing, "Off") ; disable doNothing → enable key
    }
    ; dbgTT(_d,"✓sys🖰Btn " preciseTΔ(),_t,i1,x,y1)
  }
  HotIf ; turn off context sensitivity
}

if cfg🖰hide['enableModifiers'] = true {
  cfg🖰hide['hkModPrefix'] := "*"
} else {
  cfg🖰hide['hkModPrefix'] := ""
}
; NB!!! wrapping Hotkey function in another fails: Unlike v1, the Hotkey function in v2 defaults to acting on global hotkeys, unless you call it from within a hotkey, in which case it defaults to the same criteria as the hotkey autohotkey.com/boards/viewtopic.php?f=82&t=118616&p=526495&hilit=hotkey+within+another+hotkey#p526495
HotIfWinNotActive("ahk_group no🖰HideOnType") ; turn on context sensitivity
; _dbgregistered_list := ""
__∗ := cfg🖰hide['hkModPrefix']
for _vkKey in getKeys🖰hide() { ; for every defined key, register a call to hide the mouse cursor
  Hotkey(˜ __∗ _vkKey, hk🖰PointerHide)
  ; Hotkey(˜ __∗ GetKeyName(_scKey), hk🖰PointerHide)
  ; _dbgregistered_list .= GetKeyName("sc" . format("{1:X}",_scKey)) . " "
}
; _dbgout() {
  ; dbgTT(0,_dbgregistered_list,t:=3,id:=15,x:=1500,y:=600)
; }
; _dbgout()

sys🖰Btn(Init) ; register button supressing hotkey (disabled)
HotIf ; turn off context sensitivity


on🖰Moved() { ; Restore mouse pointer (and record its new position) unless keyboard key is held
  static minΔ🖰x	:= cfg🖰hide['minΔ🖰x']
   ,     minΔ🖰y	:= cfg🖰hide['minΔ🖰y']
   , suppress  	:= cfg🖰hide['suppressionMethod']
   , _d        	:= 3
    return
  }
  for vkKey in getKeys🖰hide() { ; for every defined key, check if user is still holding a key while moving the mouse
    if (IsDown := GetKeyState(vkKey,"P")) { ; still typing, don't flash a pointer
      return
    }
  }
  global 🖰x_,🖰y_
  MouseGetPos(&🖰x, &🖰y)
  🖰Δ↔ := abs(🖰x - 🖰x_)
  🖰Δ↕ := abs(🖰y - 🖰y_)
  if (  (🖰Δ↔ < minΔ🖰x) ; don't show a mosue on tiny movements below these thresholds (in pixels)
    and (🖰Δ↕ < minΔ🖰y)) {
    return
  }
  if ( 🖰x_ != 🖰x
    && 🖰y_ != 🖰y) {
    if suppress = 'sys' or suppress = 'both' {
      sys🖰Pointer(On)
    }
    if suppress = 'gui' or suppress = 'both' {
      app🖰Pointer(On)
      dbgtt(_d,'✓on🖰Moved gui',t:=3,i:=3,0,50) ;
    }
      ; dbgtt(0,'suppress=' suppress ,t:=3,i:=4,0,150) ;11
      dbgtt(_d,'suppress=' suppress ,t:=3,i:=4,0,150) ;
    dbgTT(_d, "sys🖰P On" , Time:=1,id:=1,X:=0,Y:=850)
    🖰x_ := 🖰x
    🖰y_ := 🖰y
  }
}
sys🖰Pointer(OnOff := On) {
  global isSys🖰PointerHidden
  static C := win32Constant.Misc ; various win32 API constants

  static hCur,AndMask,XorMask
  , isInit	:= false, toShow := 1, toHide := 2
  , lrDef 	:= C.lrShared | C.lrDefColor            	; lrDefSz
  , lcDef 	:= C.lrShared | C.lrDefColor | C.lrCcSrc	; lrDefSz

  if ( (OnOff = Off)
    or (OnOff = Toggle and (not isSys🖰PointerHidden
                         or not isInit)) ) { ; hide on first init call as well
    ; dbgTT(dbgMin:=0, Text:='toHide', Time:=1,id:=6,X:=0,Y:=150)
    changeTo := toHide  ; use hCur_blank cursors
  } else {
    ; dbgTT(dbgMin:=0, Text:='toShow', Time:=1,id:=8,X:=0,Y:=250)
    changeTo := toShow  ; use hCur_saved cursors
  }

  static curSID  	:= [ ;system_cursors learn.microsoft.com/en-us/windows/win32/menurc/about-cursors
      Arrow      	:= 32512  	; IDC_ARROW   	MAKEINTRESOURCE(32512)	 Normal select
    , Ibeam      	:= 32513  	; IDC_IBEAM   	MAKEINTRESOURCE(32513)	 Text select
    , Wait       	:= 32514  	; IDC_WAIT    	MAKEINTRESOURCE(32514)	 Busy
    , Cross      	:= 32515  	; IDC_CROSS   	MAKEINTRESOURCE(32515)	 Precision select
    , UpArrow    	:= 32516  	; IDC_UPARROW 	MAKEINTRESOURCE(32516)	 Alternate select
    , Size⤡      	:= 32642  	; IDC_SIZENWSE	MAKEINTRESOURCE(32642)	 Diagonal resize 1
    , Size⤢      	:= 32643  	; IDC_SIZENESW	MAKEINTRESOURCE(32643)	 Diagonal resize 2
    , Size↔      	:= 32644  	; IDC_SIZEWE  	MAKEINTRESOURCE(32644)	 Horizontal resize
    , Size↕      	:= 32645  	; IDC_SIZENS  	MAKEINTRESOURCE(32645)	 Vertical resize
    , Size⤨      	:= 32646  	; IDC_SIZEALL 	MAKEINTRESOURCE(32646)	 Move
    , No         	:= 32648  	; IDC_NO      	MAKEINTRESOURCE(32648)	 Unavailable
    , Hand       	:= 32649  	; IDC_HAND    	MAKEINTRESOURCE(32649)	 Link select
    ; ↓ not in   	OCR_NORMAL	so can't be a restore target? learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setsystemcursor. Or just a doc omission?
    , AppStarting	:= 32650  	; IDC_APPSTARTING	MAKEINTRESOURCE(32650)	 Working in background
    , Help       	:= 32651  	; IDC_HELP       	MAKEINTRESOURCE(32651)	 Help select
    , Pin        	:= 32671  	; IDC_PIN        	MAKEINTRESOURCE(32671)	 Location select
    , Person     	:= 32672  	; IDC_PERSON     	MAKEINTRESOURCE(32672)	 Person select
    ;, _handwrite	:= 32631  	;                	MAKEINTRESOURCE(32631)	 Handwriting
  ]
   , hCursors := Array()
  hCursors.Capacity := curSID.Length

  static sys := helperSystem
  ; Get mouse pointer actual size (https://stackoverflow.com/a/65534381)
    ; GetIconInfo will return a bitmap sized for the primary display only
      ; If your main display is 150%, but the cursor is on a 100% secondary monitor, you'll get an incorrect 48x48 bitmap instead of 32x32
    ; 1 get monitor DPI     	via GetDpiForMonitor
    ; 2 get proper icon size	via GetSystemMetricsForDpi
    ; 3 scale by the "cursor magnification" settings from accessibility
  dpi🖥️       	:= sys.getDPI🖥️(), dpi🖥️x:=dpi🖥️[1], dpi🖥️y:=dpi🖥️[2]                                       	; 1) monitor dpi
  sysCurMagniF	:= RegRead('HKEY_CURRENT_USER\SOFTWARE\Microsoft\Accessibility','CursorSize',1)             	; 2) pointer size @ Settings/Ease of Access/Mouse pointer
  dpi🖰Pointer 	:= sys.getDPI🖰Pointer(dpi🖥️x), width🖰Pointer:=dpi🖰Pointer[1], height🖰Pointer:=dpi🖰Pointer[2]	;  3) get dpi-scaled system metric for mouse cursor size learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getsystemmetricsfordpi
  cx          	:= sysCurMagniF * width🖰Pointer, cy := sysCurMagniF * height🖰Pointer ; LoadImageW
  cxc         	:= 0, cyc := 0 ; copy
  ; cxc       	:= cx, cyc := cy ; copy

  if	(OnOff = Init or isInit = false) {	; init when requested or at first call
    dbgTT(dbgMin:=3, Text:='init', Time:=2,id:=5,X:=0,Y:=450)
    hCur   	:= Buffer( 4*A_PtrSize, 1)   	;
    AndMask	:= Buffer(32*A_PtrSize, 0xFF)	;
    XorMask	:= Buffer(32*A_PtrSize, 0)   	;
    loop curSID.Length {
      hCur := DllCall('LoadImageW' ; ↓ LoadImage ret HANDLE to the newly loaded image; NULL on error, use GetLastError
        , 'Ptr',0                      	; opt HINSTANCE hInst	handle to the module DLL/EXE that contains image to be loaded
        ,'uint',curSID[A_Index]        	; LPCWSTR   name     	if ↑Null and fuLoad≠lrLOADFROMFILE, predefined image to load
        ,'uint',C.imgCursor            	; uint      type     	type of image to be loaded
        , 'Int',cx, 'Int',cy           	; int       cx|xy    	icon/cursor's width|height  px
          ; 0 & fuLoad=lrDefSz         	                     	use SM_CXICON/CURSOR (/Y) system metric value to set W/H
          ; 0 & not    lrDefSz         	                     	use actual resource height
        ,'uint',lrDef                  	; uint      fuLoad
        , 'Ptr')                       	; learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-loadimagew
      hCur_saved := DllCall("CopyImage"	; create a new image (icon/cursor/bitmap) and copy its attributes to the new one. Stretch the bits to fit the desired size if needed, learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-copyimage
        ,"Ptr" ,hCur                   	; HANDLE	h
        ,"uint",C.imgCursor            	; uint  	type
        , "int",cxc, "int",cyc         	; int   	cx|cy	0=returned image will have same width|height as original hImage
        ,"uint",lcDef                  	; uint  	flags
        , 'Ptr')
      hCur_blank := DllCall("CreateCursor" ; create a monochrome cursor
        , "Ptr",0          	;opt HINSTANCE  hInst,
        , "int", 0,"int", 0	;int        xHotSpot / yHotSpot
        , "int",32,"int",32	;int        nWidth   / nHeight
        , 'Ptr',AndMask    	;const VOID *pvANDPlane	array of bytes with bit values for the AND mask of the cursor, as in a device-dependent monochrome bitmap
        , 'Ptr',XorMask    	;const VOID *pvXORPlane	array of bytes with bit values for the XOR mask of the cursor, as in a device-dependent monochrome bitmap
        , 'Ptr')
      hCursors.Push([hCur_saved, hCur_blank]) ; toShow=1 toHide=2
    }
    ; isInit	:= true ; move to the end to allow hiding cursor on 1st toggle call
  }
  ; MouseGetPos(&🖰x, &🖰y)	; Get the current mouse position, and store its coordinates
  dbgOut := "changeTo=" changeTo
    . "`nsysCurMagniF=" sysCurMagniF
    . "`nmonDPIx|y`t= " dpi🖥️x " | " dpi🖥️y ;"`n" 🖰x " " 🖰y
    . "`ncurW|H_dpi`t= " width🖰Pointer " | " height🖰Pointer
    . "`ncX|Y`t= " cx " | " cy

  loop curSID.Length {
    hCur := DllCall("CopyImage", "Ptr", hCursors[A_Index][changeTo]
      ,"uint",C.imgCursor, "int",cxc,"int",cyc, "uint",lcDef)
    DllCall("SetSystemCursor" ; replace the contents of the system cursor specified by id with the contents of the cursor handled by hcur
      , "Ptr",hCur           	; cursor handle, destroyed via DestroyCursor, so can't be LoadCursor, use CopyCursor
      ,"uint",curSID[A_Index]	; system cursor to replace
      )
    ; dbgOut .= "`nhCur=" hCur
    }
  isSys🖰PointerHidden := (changeTo = toHide) ? true : false
  dbgOut .= "`nisSys🖰PointerHidden=" isSys🖰PointerHidden
  dbgOut .= "`nOnOff=" OnOff
  if changeTo = toShow {
    restore🖰Pointers()
    sys🖰Btn(On)
  } else if changeTo = toHide {
    sys🖰Btn(Off)
  }
  dbgTT(dbgMin:=4, Text:=dbgOut, Time:=3,id:=3,X:=0,Y:=750)
  isInit	:= true
}

is🖰PointerVisible() {
  static C := win32Constant.Misc ; various win32 API constants
   , Cursor_Showing := 0x00000001
  vSize := (A_PtrSize=8)?24:20
  CursorInfo := Buffer(vSize, 0)
  NumPut("UInt",vSize, CursorInfo, 0) ;cbSize
  _ := DllCall("user32\GetCursorInfo", "Ptr",CursorInfo)
  flags := NumGet(CursorInfo, 4, "Ptr") ;flags
  is🖰vis := flags & Cursor_Showing
  ; dbgtt(0,'flags ' 🖰I.flags,t:=2,,200,200) ;
  return is🖰vis
}

app🖰Pointer(OnOff := '') { ; create our own gui element, make the target app its owner, then show a pointer there so it's redirected from the app to our invisible element
  static C := win32Constant.Misc ; various win32 API constants
   , guiBlankChild := Gui()
   , guiOwner := 0
   ; , isHidden := 0
   , displayCounter := 0 ; track thread pointer counter, pointer is shown only if >=0, no way to get current value
   , x := A_ScreenWidth*.7
   , _d := 3
   , i1 := 3 ; tooltip index for on
   , i0 := 4 ; ...               off
   , _t := '∞' ; time for tooltip
   , attachGUI_🖰 := cfg🖰h['attachGUI_🖰']
  is🖰vis := is🖰PointerVisible() ; check if pointer is visible otherwise ShowCursor can stack hiding it requiring multiple calls to unstack
  MouseGetPos(,,&winID,)

  if    OnOff = Off                     	; hide if explicit command to hide is given
    or (OnOff = Toggle and is🖰vis = 0)  	; or   if explicti command to toggle is given and it's not hidden yet
    or (OnOff = ''     and is🖰vis = 1) {	; or no command and it hasn't been hidden yet

  winID := 0
  if attachGUI_🖰 {
    winID := WinGetID("A")
  } else {
    MouseGetPos(,,&winID,)
  }
  if not winID {
    return
  }
    ; if not winID = guiOwner { ;+Owner breaks SetPoint mouse buttons, so set/reset it for every Off/On
      ; dbgtt(_d,"Δowner " preciseTΔ() "`n" (guiOwner>0?WinGetTitle(guiOwner):'') '`n' WinGetTitle(winID),_t,i1,x,100)
      guiBlankChild.Opt("+Owner" . winID) ; make the GUI owned by winID
      guiOwner := winID
    ; }
    if is🖰vis {
      if displayCounter < -1 { ;;; likely an issue with being unable to hide the pointer
        ; dbgtt(0,"✗✗✗hidden3 cursor " displayCounter " flag=" 🖰I.flags " at " WinGetTitle(guiOwner),t:=2,i:=3,x,200)
        ; dbgtt(_d,"✗✓ hide± #" displayCounter ' ' preciseTΔ() "`n" WinGetTitle(guiOwner),_t,i0,x,200)
      } else {
        displayCounter := DllCall("ShowCursor", "int",0)
        ; dbgtt(_d,"✓ hide #" displayCounter ' ' preciseTΔ() "`n" WinGetTitle(guiOwner),_t,i0,x,200)
      }
    } else {
        ; dbgtt(_d,"✗ already hidden #" displayCounter ' ' preciseTΔ() "`n" WinGetTitle(guiOwner),_t,i0,x,200)
    }
    ; isHidden := 1
  } else {
    if is🖰vis { ;
      ; dbgtt(0,"✗shown #" displayCounter ' ' preciseTΔ() "`n" (guiOwner>0?WinGetTitle(guiOwner):''),_t,i1,x,50)
    } else {
      if not winID = guiOwner {
        guiBlankChild.Opt("+Owner" . winID) ; make the GUI owned by winID
        guiOwner := winID
        displayCounter := DllCall("ShowCursor", "int",1)
        guiBlankChild.Opt("-Owner")
        ; dbgtt(_d,"✓shown GUI #" displayCounter ' ' preciseTΔ() "`n" (guiOwner>0?WinGetTitle(guiOwner):''),_t,i1,x,50)
      } else {
        displayCounter := DllCall("ShowCursor", "int",1)
        guiBlankChild.Opt("-Owner")
        ; dbgtt(_d,"✓shown     #" displayCounter ' ' preciseTΔ() "`n" (guiOwner>0?WinGetTitle(guiOwner):''),_t,i1,x,50)
      }
    }
    ; isHidden := 0
  }
}

doNothing(ThisHotkey){
  return
}

restore🖰Pointers() {
  static C := win32Constant.Misc ; various win32 API constants
  DllCall("SystemParametersInfo"
   ,'uint',C.curReload	; uint   	uiAction	system-wide parameter to be retrieved or set
   ,'uint',0          	; uint   	uiParam 	parameter whose usage and format depends on the system parameter being queried or set., see uiAction. Must be 0 if not otherwise indicated
   ,'uint',0          	;io PVOID	pvParam 	parameter whose usage and format depends on the system parameter being queried or set, see uiAction. Must be NULL if not otherwise indicated
   ,'uint',0          	; uint   	fWinIni 	If a system parameter is being set, specifies whether the user profile is to be updated, and if so, whether the WM_SETTINGCHANGE message is to be broadcast to all top-level windows to notify them of the change
   )
}

MouseGetPos(&🖰x_, &🖰y_)	; Get the current mouse position, and store its coordinates
; regWatchers()        	; set up hotkeys to fire mouse hide commands on press
OnMouseEvent(MouseTest)	; alternative way, subscribe to raw mouse movements, don't poll
MouseTest(RawInputWrapper) {
  if RawInputWrapper.IsMovement { ; track only movements
    on🖰Moved()
  } else {
    return
  }
}
