#include <Win>
#include <constLocale>
#include <constWin32alt>
wapi	:= win32Constant ; various win32 API constants

class Lyt { ; some methods from autohotkey.com/boards/viewtopic.php?f=6&t=28258
  static INPUTLANGCHANGE_FORWARD	:= 0x0002
   , INPUTLANGCHANGE_BACKWARD   	:= 0x0004
   , KLIDsREG_PATH              	:= "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Keyboard Layouts\"
  ; —————————— Locale Functions ——————————
  static locInf := localeInfo.m  ; Constants Used in the LCType Parameter of GetLocaleInfo, GetLocaleInfoEx, and SetLocaleInfo
  static getLocaleInfo(infoLCTs, LocaleID:=this.locInf.Get("USER_Def")) { ; get info about a locale specified by ID
    ;infoLCT 	LCTYPE	locale information to retrieve, LCType @ learn.microsoft.com/en-us/windows/desktop/api/winnls/nf-winnls-getlocaleinfoex
    ;LocaleID	LCID  	learn.microsoft.com/en-us/windows/desktop/Intl/locale-identifiers
    ;→ found value or empty string on error
    static retNumber := 0x20000000   ; return number instead of string
    if (infoLCT := this.locInf.Get(infoLCTs,"")) = "" {
      throw ValueError("1st argument ‘infoLCTs’ doesn't match any known locate types",-1,infoLCT)
    }
    if LocaleID = "" {
      throw ValueError("2nd argument ‘LocaleID’ is empty" ,-1,LocaleID)
    }
    if (SubStr(infoLCTs,1,1) =        "I") or
       (SubStr(infoLCTs,1,8) = "LOCALE_I") {
      outVar := 0
      DllCall("GetLocaleInfo", "uint",LocaleID, "uint",infoLCT | retNumber, "uint*",&outVar, "int",4 // bytes⁄char)
      return outVar
    } else {
      ;↓ need to call twice, 1st to get variable size, 2nd time to fill the variable of the proper size
      charCount	:= DllCall("GetLocaleInfo", "uint",LocaleID, "uint",infoLCT , "str","", "int",0) ; cchData=0 → get buffer size
      VarSetStrCapacity(&outVar, charCount * bytes⁄char)
      DllCall("GetLocaleInfo", "uint",LocaleID, "uint",infoLCT ;→aint learn.microsoft.com/en-us/windows/win32/api/winnls/nf-winnls-getlocaleinfow
        , "str",outVar   	;→ opt LPWSTR	lpLCData	pointer to a buffer in which this function retrieves the requested locale information. This pointer is not used if cchData is set to 0
        ,"uint",charCount	;int         	cchData 	Size, in TCHAR values, of the data buffer indicated by lpLCData. 0: not use the lpLCData parameter and returns the required buffer size, including the terminating null character
        )
      return outVar
    }
  }

  ; ——————————————— public method Set ———————————————
  Set(arg := "switch"	;[opt] |switch| forward ¦ backward ¦ locale indicator name (EN, usually 2-letter) ¦ # of layout in system loaded layout list ¦ language id e.g. HKL (0x04090409)
    , win := "" 	;[opt] ahk format WinTitle ¦ hWnd ¦ "global" (def: active window)
    ) { ; return value: empty or description of error
    winID := getWinID(win)
    if        (arg = "forward" ) {
      return this.ChangeCommon(, this.INPUTLANGCHANGE_FORWARD, winID)
    } else if (arg = "backward") {
      return this.ChangeCommon(, this.INPUTLANGCHANGE_BACKWARD, winID)
    } else if (arg = "switch"  ) {
      tmphWnd   	:= (winID = "global") ? WinExist("A") : winID
      HKL       	:= this.GetInputHKL(tmphWnd)
      HKL_Number	:= this.GetNum(,HKL)
      LytList   	:= this.GetList()
      Loop HKL_Number - 1 {
        If (LytList[A_Index].hkl & 0xFFFF  !=  HKL & 0xFFFF) {
          return this.ChangeCommon(LytList[A_Index].hkl,, winID)
        }
      }
      Loop LytList.MaxIndex() - HKL_Number {
        If (LytList[A_Index + HKL_Number].hkl & 0xFFFF  !=  HKL & 0xFFFF) {
          return this.ChangeCommon(LytList[A_Index + HKL_Number].hkl,, winID)
        }
      }
    } else if (arg ~= "^-?[A-z]{2}") {
      invert := ((SubStr(arg, 1, 1) = "-") && (arg := SubStr(arg, 2, 2))) ? true : false
      For index, layout in this.GetList() {
        if (InStr(layout.LocName, arg) ^ invert) {
          return this.ChangeCommon(layout.hkl,, winID)
        }
      }
      return "HKL from this locale not found in system loaded layout list"
    } else if (arg >     0 && arg <= this.GetList().MaxIndex()) { ; HKL number in system loaded layout list
      return this.ChangeCommon(this.GetList()[arg].hkl,, winID)
    } else if (arg > 0x400 || arg < 0                         ) { ; HKL handle input
      For index, layout in this.GetList()
        if layout.hkl = arg
          return this.ChangeCommon(arg,, winID)
      return "This HKL not found in system loaded layout list"
    } else {
      return "Not valid input"
    }
  }
  ChangeCommon(HKL := 0, INPUTLANGCHANGE := 0, hWnd := 0) { ;;;;;
    return (hWnd = "global")
      ? this.ChangeGlobal(HKL, INPUTLANGCHANGE      )
      : this.ChangeWindow(HKL, INPUTLANGCHANGE, hWnd)
  }
  ChangeGlobal(HKL, INPUTLANGCHANGE) { ;;;;; ; in all windows
    If (INPUTLANGCHANGE != 0)
      return "FORWARD and BACKWARD not support with global parametr."
    if (A_DetectHiddenWindows != "On")
      DetectHiddenWindows((prevDHW := "false") ? "true" : "")
    oList := WinGetList(,,,)
    aList := Array()
    List := oList.Length
    For v in oList
    {   aList.Push(v)
    }
    Loop aList.Length
      this.Change(HKL, INPUTLANGCHANGE, aList[A_Index])
    DetectHiddenWindows(prevDHW)
  }
  ChangeWindow(HKL, INPUTLANGCHANGE, hWnd) { ;;;;;
    static hTaskBarHwnd := WinExist("ahk_class Shell_TrayWnd ahk_exe explorer.exe")
    (hWnd = hTaskBarHwnd)
     ? this.ChangeTaskBar(HKL, INPUTLANGCHANGE, hTaskBarHwnd)
     : this.Change(       HKL, INPUTLANGCHANGE, hWnd)
  }
  ChangeTaskBar(HKL, INPUTLANGCHANGE, hTaskBarHwnd) { ;;;
    static hStartMenu, hLangBarInd, hDV2CH
    if (A_DetectHiddenWindows != "On")
      DetectHiddenWindows((prevDHW := "false") ? "true" : "")
    hStartMenu := hStartMenu  ? hStartMenu  : WinExist('ahk_class NativeHWNDHost'  	' ahk_exe explorer.exe')
    hLangBarInd:= hLangBarInd ? hLangBarInd : WinExist('ahk_class CiceroUIWndFrame'	' ahk_exe explorer.exe')
    hDV2CH     := hDV2CH      ? hDV2CH      : WinExist('ahk_class DV2ControlHost'  	' ahk_exe explorer.exe')

    this.Change(HKL, INPUTLANGCHANGE, hTaskBarHwnd)
    this.Change(HKL, INPUTLANGCHANGE, hStartMenu)
    If INPUTLANGCHANGE {
      Sleep(20)
      HKL := this.GetInputHKL(hStartMenu), INPUTLANGCHANGE := 0
    }
    ; to update Language bar indicator
    this.Change(HKL, INPUTLANGCHANGE, hLangBarInd)
    this.Change(HKL, INPUTLANGCHANGE, hDV2CH)
    DetectHiddenWindows(prevDHW)
  }
  Change(HKL, INPUTLANGCHANGE, hWnd) { ;;;
    hWndOwn := DllCall("GetWindow", "Ptr", hWnd, "UInt", GW_OWNER:=4, "Ptr")
    PostMessage(wapi.wm.Input
      , HKL ? ""  : INPUTLANGCHANGE
      , HKL ? HKL : ""
      ,
      , "ahk_id" (hWndOwn ? hWndOwn : hWnd))
  }

  GetNum(win := "", HKL := 0) { ;;;;; ; layout Number in system loaded layout list
    HKL ? "" :HKL := this.GetInputHKL(win)
    If HKL {
      For index, layout in this.GetList() {
        if (layout.hkl = HKL) {
          return index
        }
      }
    } else If (KLID := this.KLID, this.KLID := "") {
      For index, layout in this.GetList() {
        if (layout.KLID = KLID) {
          return index
        }
      }
    }
  }



  static getList() { ; list of loaded layouts
    ; GetKeyboardLayoutList( learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getkeyboardlayoutlist?redirectedfrom=MSDN
    ;→ int 0             	fail, get extended error info via GetLastError
    ;       #            	of input localeIDs identifiers copied to the buffer
    ;       Size         	(in array elements) of the buffer needed to receive all current input locale identifiers (nBuff=0)
    ;   [in]  int nBuff  	ahk_int	maximum number of handles that the buffer can hold
    ;   [out] HKL *lpList	ahk_ptr	pointer to the buffer that receives the array of input locale identifiers
    static mLayouts
    if isSet(mLayouts) {
      return mLayouts
    } else {
      mLayouts	:= Map()
      Size    	:= DllCall("GetKeyboardLayoutList", "int",0    ,"ptr",0)
      List    	:= Buffer(A_PtrSize*Size)
      Size    	:= DllCall("GetKeyboardLayoutList", "int",Size ,"ptr",List)
      Loop Size {
        layout               	:= Map()
        ,layout.CaseSense    	:= 0
        id                   	:= NumGet(List, A_PtrSize*(A_Index - 1), "ptr")
        layout['id']         	:= id
        layout['hkl']        	:= layout['id']
        layout['LangShort']  	:= this.GetLocaleName(, layout['id'])      	; en
        layout['LangLong']   	:= this.GetLocaleName(, layout['id'], true)	; English
        layout['LayoutName'] 	:= this.GetLayoutName(, layout['id'])      	; US
        layout['KLID']       	:= this.getKLIDfromHKL( layout['id'])
        layout['idKL']       	:= layout['KLID']
        layout['LocName']    	:= layout['LangShort']
        layout['LocFullName']	:= layout['LangLong']
        mLayouts[id]         	:= layout
      }
      return mLayouts
    }
  }
  static GetLocaleName(win := "", HKL := false, FullName := false) { ; EN or English
    HKL ? "" : HKL := this.GetInputHKL(win)
    if         HKL {
      LocID := HKL & 0xFFFF
    } else if (HKL = 0) {  ; ConsoleWindow
      LocID := "0x" . SubStr(this.KLID, -4), this.KLID := ""
    } else {
      return
    }
    infoLCT	:= FullName ? 'SENGLISHLANGUAGENAME' : 'SISO639LANGNAME'
    return this.getLocaleInfo(infoLCT, LocID)
  }
  static getLayoutName(win := "", HKL := false) { ; Layout name in OS display lang: "US", "United States-Dvorak"
    HKL ? "" : HKL := this.GetInputHKL(win)
    if         HKL {
      KLID := this.getKLIDfromHKL(HKL)
    } else if (HKL = 0) {  ;ConsoleWindow
      KLID := this.KLID, this.KLID := ""
    } else {
      return
    } ;;;
    LayoutName := RegRead(this.KLIDsREG_PATH KLID, "Layout Display Name")
    DllCall("Shlwapi.dll\SHLoadIndirectString" ; learn.microsoft.com/en-us/windows/win32/api/shlwapi/nf-shlwapi-shloadindirectstring
     , "Str",LayoutName     	;i PCWSTR pszSource,
     , "Str",LayoutName     	;o  PWSTR   pszOutBuf,
     , "UInt",outBufSize:=50	;i UINT   cchOutBuf,
     , "UInt", 0)           	; void   **ppvReserved
    ; dbgTT(0,LayoutName '`tLayoutName')
    if not LayoutName {
      LayoutName := RegRead(this.KLIDsREG_PATH KLID, "Layout Text")
      ; dbgTT(0,LayoutName '`tLayoutText (LayoutName not found)')
    }
    return LayoutName
  }

  static getKLIDfromHKL(localeID) { ;HKL only for loaded in system layouts Computer\HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\Keyboard Layouts
    KL_NAMELENGTH	:= 8 * 2
    klID         	:= Buffer(KL_NAMELENGTH)
    procID       	:= DllCall('GetWindowThreadProcessId', 'Ptr',0, 'UInt',0, 'Ptr')
    priorHKL     	:= DllCall('GetKeyboardLayout' , 'Ptr',procID, 'Ptr')
    if   not DllCall('ActivateKeyboardLayout', 'Ptr',localeID, 'UInt', 0)
      || not DllCall('GetKeyboardLayoutName' , 'Ptr',klID) { ; LPWSTR pwszKLID	buffer (of at least KL_NAMELENGTH characters in length) that receives the name of the input locale identifier, including the terminating null character. This will be a copy of the string provided to the LoadKeyboardLayout function, unless layout substitution took place. KLID = keyboard layout identifier
      ; learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getkeyboardlayout
      return false
    }
    DllCall('ActivateKeyboardLayout', 'Ptr',priorHKL, 'UInt',0)
    return StrGet(klID)
  }

  static GetCurLayout(&lytPhys := 0, &idLang := 0, win:="") {
    ; ??? int layout = (int) GetKeyboardLayout(GetWindowThreadProcessId(GetForegroundWindow(), NULL)) & 0xFFFF; https://forum.rainmeter.net/viewtopic.php?t=12337
    winID_fg	:= DllCall("GetForegroundWindow") ; Get handle (HWND) to the foreground window docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getforegroundwindow
    dbgtxt := "Layout info from GetForegroundWindow"
    if not (winID := getWinID(win)) {
      return
    }
    if not (winCls := WinGetClass(winID)) {
      return
    }
    ; dbgTT(3, winCls '`twinCls')
    if winCls == 'ConsoleWindowClass' { ; get layout for Console
      ; 1. Best Solution via IME method instead of having to lookup conhost ThreadID found code.google.com/archive/p/waitzar/issues/118 from this app github.com/yathit/waitzar/blob/master/win32_source/Input/VirtKey.cpp
      ; 2. Alternative via addon (enumerates all conhosts and tries to find the one that maps to our console window): github.com/Elfy/getconkbl ()
      IMEWnd	:= DllCall(getDefIMEWnd, "Ptr",winID_fg) ; "Imm32\ImmGetDefaultIMEWnd"
      if (IMEWnd == 0) {
        dbgtxt	.= "Console: ImmGetDefaultIMEWnd is 0`n"
        return
      } else {
        dbgtxt	.= "Console: layout info from ImmGetDefaultIMEWnd`n"
        winID_fg := IMEWnd
      }
    } else if (winCls == 'vguiPopupWindow'
           or  winCls == 'ApplicationFrameWindow') { ; Steam, some UWP apps, get layout from a keyboard focused control since can't read it from a regular window autohotkey.com/boards/viewtopic.php?f=76&t=69414
      Focused	:= ControlGetFocus("A")
      if (Focused == 0) {
        dbgtxt	.= "UWP: ControlGetFocus got 0 :(`n"
        return
      } else {
        dbgtxt  	.= "UWP: Layout info from ControlGetFocus`n"
        CtrlID  	:= ControlGetHwnd(Focused, "A")
        winID_fg	:= CtrlID
      }
    }
    threadID     	:= DllCall("GetWindowThreadProcessId"	,  "Ptr",winID_fg, "Ptr",0) ; DWORD GetWindowThreadProcessId(HWND hWnd, LPDWORD lpdwProcessId) docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getwindowthreadprocessid
    inputLocaleID	:= DllCall("GetKeyboardLayout"       	, "UInt",threadID, 'Ptr') ; HKL=Ptr (some examples mistakenly use UInt=4, need the full '0xfffffffff0c00409' value), hKL = handle to a keyboard layout for the thread
      ;|SubLangID|PrimaryLangID| enU: 0xfffffffff0c0 0409
      ;+---------+-------------+ ruU: 0xfffffffff0c1 0419
      ;15     10 9             0 bit
    idLang 	:= inputLocaleID & 0xFFFF	; Language Identifier for the input language docs.microsoft.com/en-us/windows/win32/intl/language-identifiers
    lytPhys	:= inputLocaleID >> 16   	; device handle to the physical layout. Bitwise right shift by 16 bits = 4 hex characters (=size of lWord) . User can associate any input language with a physical layout, eg, an English-speaking user who very occasionally works in French can set the input language of the keyboard to French without changing the physical layout of the keyboard. This means the user can enter text in French using the familiar English layout
    ; 0=default
    ; dbgtxt	.= Format("hW={1:#x} lw={2:#x}`ninputLocaleID={3:#x}`nthreadID: {4:}`n", lytPhys, idLang, inputLocaleID, threadID)
    ; dbgTT(0,dbgtxt,t:=3,id:=4)
    return inputLocaleID
    }
  ; ——————————————— public method GetInputHKL ———————————————
  static GetInputHKL(win := "") {
    return this.GetCurLayout(&lytPhys, &idLang, win) ;;; compare ↓ with GetCurLayout
    ; Parameters:     win (optional)   - ("" / hWnd / WinTitle). Default: "" — Active Window
    ; return value:   HKL of window / if handle incorrect, system default layout HKL return / 0 - if KLID found
    ; hWnd := getWinID(win)
    ; winCls := WinGetClass(hWnd)
    ; if (winCls == "ConsoleWindowClass") {
    ;     consolePID := WinGetPID()
    ;     DllCall("AttachConsole", "Ptr", consolePID)
    ;     KLID := Buffer(16)
    ;     DllCall("GetConsoleKeyboardLayoutName", "Ptr",KLID)
    ;     DllCall("FreeConsole")
    ;     this.KLID := KLID
    ;     return 0
    ; } else { ; Dvorak on OSx64 0xfffffffff0020409 = -268303351   ->   0xf0020409 = 4026663945 Dvorak on OSx86
    ;   HKL:=DllCall("GetKeyboardLayout", "Ptr", DllCall("GetWindowThreadProcessId", "Ptr", hWnd, "UInt", 0, "Ptr"), "Ptr")
    ;   return A_PtrSize = 4 ? HKL & 0xFFFFFFFF : HKL
    ; }
  }
/*
~LShift Up::(A_PriorKey = "LShift") ? Lyt.Set("EN")
~RShift Up::(A_PriorKey = "RShift") ? Lyt.Set("RU")

#Space::PostMessage WM_INPUTLANGCHANGEREQUEST:=0x50, INPUTLANGCHANGE_FORWARD:=0x2,,, % (hWndOwn := DllCall("GetWindow", Ptr, hWnd:=WinExist("A"), UInt, GW_OWNER := 4, Ptr)) ? "ahk_id" hWndOwn : "ahk_id" hWnd
*/
}




; learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-loadkeyboardlayoutw
  ; HKL LoadKeyboardLayoutW(
  ; [in] LPCWSTR pwszKLID	; name of the input locale identifier to load. This name is a string composed of the hexadecimal value of the Language Identifier (low word) and a device identifier (high word). For example, U.S. English has a language identifier of 0x0409, so the primary U.S. English layout is named "00000409". Variants of U.S. English layout (such as the Dvorak layout) are named "00010409", "00020409", and so on.
  ; [in] UINT    Flags   	; Specifies how the input locale identifier is to be loaded. This parameter can be one of the following values
  ; KLF_ACTIVATE         	0x00000001	If the specified input locale identifier is not already loaded, the function loads and activates the input locale identifier for the system (pre Win8: for the current thread
  ; KLF_NOTELLSHELL      	0x00000080	pre Win 8  Prevents a ShellProc hook procedure from receiving an HSHELL_LANGUAGE hook code when the new input locale identifier is loaded. This value is typically used when an application loads multiple input locale identifiers one after another. Applying this value to all but the last input locale identifier delays the shell's processing until all input locale identifiers have been added.
 ;                       	          	    Win 8+ In this scenario, the last input locale identifier is set for the entire system.
  ; KLF_REORDER          	0x00000008	pre Win 8  Moves the specified input locale identifier to the head of the input locale identifier list, making that locale identifier the active locale identifier for the current thread. This value reorders the input locale identifier list even if KLF_ACTIVATE is not provided.
 ;                       	          	    Win 8+ Moves the specified input locale identifier to the head of the                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               	 locale identifier list, making that locale identifier the active locale identifier for the system. This value reorders the input locale identifier list even if KLF_ACTIVATE is not provided.	                 	KLF_REPLACELANG	0x00000010                                                                                                                   	If the new input locale identifier has the same language identifier as a current input locale identifier, the new input locale identifier replaces the current one as the input locale identifier for that language. If this value is not provided and the input locale identifiers have the same language identifiers, the current input locale identifier is not replaced and the function returns NULL.
  ; KLF_SUBSTITUTE_OK    	0x00000002	Substitutes the specified input locale identifier with another locale preferred by the user. The system starts with this flag set, and it is recommended that your application always use this flag. The substitution occurs only if the registry key HKEY_CURRENT_USER\Keyboard Layout\Substitutes explicitly defines a substitution locale. For example, if the key includes the value name "00000409" with value "00010409", loading the US layout ("00000409") causes the United States-Dvorak layout ("00010409") to be loaded instead. The system uses KLF_SUBSTITUTE_OK when booting, and it is recommended that all applications	 this value when loading input locale identifiers to ensure that the user's preference is selected.                                                                                           	KLF_SETFORPROCESS	0x00000100     	Prior to Windows 8: This flag is valid only with KLF_ACTIVATE. Activates the specified input locale identifier for the entire		 sends the WM_INPUTLANGCHANGE message to the current thread's Focus or Active window. Typically, LoadKeyboardLayout activates an input locale identifier only for the current thread. Beginning in Windows 8: This flag is not used. LoadKeyboardLayout always activates an input locale identifier for the entire system if the current process owns the window with keyboard focus.
  ; KLF_UNLOADPREVIOUS   	          	This flag is unsupported. Use the UnloadKeyboardLayout function instead.
