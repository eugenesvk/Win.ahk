#Requires AutoHotKey 2.1-alpha.4

#include <libFunc Dbg>   	; Functions: Debug
#include <libFunc Native>	; Functions: Native
#include <constKey>      	; various key constants
#include <str>           	; string helper functions

preciseTΔ(n:=3) {
  static start := nativeFunc.GetSystemTimePreciseAsFileTime()
  t := round(     nativeFunc.GetSystemTimePreciseAsFileTime() - start,n)
  return t
}

perfT() { ; QueryPerformanceCounter learn.microsoft.com/en-us/windows/win32/api/profileapi/nf-profileapi-queryperformancecounter
  static count0	:= 0
   , frequency 	:= nativeFunc.QueryPerformanceFrequency()
  return DllCall(QPerfC_proc,"Int64*",&count1:=0)
    ? ((count1 - count0) / frequency * 1000) + ((count0 := count1) & 0)
    : (count0 := 0)
}

class keyFunc {
  static __new() { ; get all vars and store their values in this .Varname as well ‘m’ map, and add aliases

    this.hkSend := hkSend
    static hkSend(  keyNm, s) { ; closure allows registering hotkeys with variables in the target, so great for loops of similar keys
      fnSend(       keyNm   ) { ; closure due to a free variable S in the outer function that is used here. Can share vars with the outer function even after the outer function returns
        Send(s) ;, dbgTT(0,s)
      }
      Hotkey(keyNm, fnSend)
    }
    this.hkSendI := hkSendI
    static hkSendI(keyNm, s) {
      fnSendI(     keyNm   ) { ; closure due to a free variable S in the outer function that is used here. Can share vars with the outer function even after the outer function returns
        SendInput(s) ;, dbgTT(0,s)
      }
      Hotkey(keyNm, fnSendI)
    }

    this.hkSendC := hkSendC
    static hkSendC(keyNm, s) {
      fnSendC(     keyNm   ) { ; closure due to a free variable S in the outer function that is used here. Can share vars with the outer function even after the outer function returns
        ControlSend(s,,'A') ;, dbgTT(0,s)
      }
      Hotkey(keyNm, fnSendC)
    }

    this.customHotkey := customHotkey
    static customHotkey(key_combo) {
      customHotkeyFull("",key_combo,"")
    }

    this.customHotkeyFull := customHotkeyFull
    static customHotkeyFull(pre:='',key_combo:='',pos:='',kT:='vk',lng:='en') {
      if not key_combo{
        throw ValueError("customHotkeyFull: ‘key_combo’ should not be blank", -1)
      }
      is⅋ := false
      static s := helperString
       , vk := keyConstant._map, sc := keyConstant._mapsc  ; various key name constants, gets vk code to avoid issues with another layout

      str_replace := Map(A_Space,"", A_Tab,"") ; remove whitespace and allow & in function names
      for from,to in str_replace {
        key_combo := StrReplace(key_combo,from,to)
      }

      sep⅋      	:= ''
      ,sep⅋Fn   	:= ''
      ,pre_combo	:= ''
      if InStr(key_combo, "&") { ; ☰&x
        customCombo_arr	:= StrSplit(key_combo, "&")
        sep⅋           	:= " & "
        sep⅋Fn         	:= "⅋"
        if not customCombo_arr.Length = 2 {
          throw ValueError('At most one & should be present in ‘' . key_combo . '’', -1)
        } else {
          pre_combo	:= customCombo_arr[1] ; ☰
          key_combo	:= customCombo_arr[2] ; x
        }
        is⅋ := true
      }

      vkpre := pre_combo = "" ? "" : vk[pre_combo]
      key_combo_FNm	:= 'hk' . pre_combo . sep⅋Fn . s.replace_illegal_id(key_combo)
      key_combo_ahk	:= s.key→ahk(key_combo, kT,,lng)
      key_combo_out := pre . vkpre . sep⅋ . key_combo_ahk . pos
      ; dbgtxt := key_combo_out '`t' 'key_combo_out' '`n' key_combo_FNm '`t' 'key_combo_FNm'
      ; dbgTT(0,dbgtxt, t:=5)
      ; key_combo  	⇧5
      ; mod_ahk_str	 +5
      ; nonmod     	  5
      return [key_combo_out, key_combo_FNm]
    }

    this.anyMod      := anyMod
    static anyMod(isP?) { ; true: any modifier is down ('P'-physically)
      P := isSet(isP)?'P':''
      if isSet(isP) {
           GetKeyState("Shift"   	,'P')
        || GetKeyState("Ctrl"    	,'P')
        || GetKeyState("Alt"     	,'P')
        || GetKeyState("LWin"    	,'P')
        || GetKeyState("CapsLock"	,'P')
      } else {
           GetKeyState("Shift"   	)
        || GetKeyState("Ctrl"    	)
        || GetKeyState("Alt"     	)
        || GetKeyState("LWin"    	)
        || GetKeyState("CapsLock"	)
      }
    }
    this.whichModAny := whichModAny
    static whichModAny(isP?) { ; true: any modifier is down ('P'-physically)
      P := isSet(isP)?'P':''
      flag_mode := 0
      if isSet(isP) {
        GetKeyState("Shift"   	,'P')?flag_mode |= f⇧:''
        GetKeyState("Ctrl"    	,'P')?flag_mode |= f⎈:''
        GetKeyState("Alt"     	,'P')?flag_mode |= f⎇:''
        GetKeyState("LWin"    	,'P')?flag_mode |= f‹◆:''
        GetKeyState("RWin"    	,'P')?flag_mode |= f◆›:''
        GetKeyState("CapsLock"	,'P')?flag_mode |= f⇪:''
      } else {
        GetKeyState("Shift"   	    )?flag_mode |= f⇧:''
        GetKeyState("Ctrl"    	    )?flag_mode |= f⎈:''
        GetKeyState("Alt"     	    )?flag_mode |= f⎇:''
        GetKeyState("LWin"    	    )?flag_mode |= f‹◆:''
        GetKeyState("RWin"    	    )?flag_mode |= f◆›:''
        GetKeyState("CapsLock"	    )?flag_mode |= f⇪:''
      }
      return flag_mode
    }
    this.whichMod    := whichMod
    static whichMod(isP?) { ; true: left/right modifier is down ('P'-physically)
      P := isSet(isP)?'P':''
      flag_mode := 0
      if isSet(isP) {
        GetKeyState("LShift"   	,'P')?flag_mode |= f‹⇧:''
        GetKeyState("LCtrl"    	,'P')?flag_mode |= f‹⎈:''
        GetKeyState("LAlt"     	,'P')?flag_mode |= f‹⎇:''
        GetKeyState("LWin"    	,'P')?flag_mode |= f‹◆:''
        GetKeyState("CapsLock"	,'P')?flag_mode |= f⇪:''
        GetKeyState("RShift"  	,'P')?flag_mode |= f⇧›:''
        GetKeyState("RCtrl"   	,'P')?flag_mode |= f⎈›:''
        GetKeyState("RAlt"    	,'P')?flag_mode |= f⎇›:''
        GetKeyState("RWin"    	,'P')?flag_mode |= f◆›:''
      } else {
        GetKeyState("LShift"  	    )?flag_mode |= f‹⇧:''
        GetKeyState("LCtrl"   	    )?flag_mode |= f‹⎈:''
        GetKeyState("LAlt"    	    )?flag_mode |= f‹⎇:''
        GetKeyState("LWin"    	    )?flag_mode |= f‹◆:''
        GetKeyState("RShift"  	    )?flag_mode |= f⇧›:''
        GetKeyState("RCtrl"   	    )?flag_mode |= f⎈›:''
        GetKeyState("RAlt"    	    )?flag_mode |= f⎇›:''
        GetKeyState("RWin"    	    )?flag_mode |= f◆›:''
        GetKeyState("CapsLock"	    )?flag_mode |= f⇪:''
      }
      return flag_mode
    }

    this.keyCharNameU   := keyCharNameU
    static keyCharNameU(char) { ; get unicode name for a char, eg, 'Infinity' for ∞, using the undocumented GetUName Windows API, only the 1st letter is used
      static szWCh	:= 2 ; this is UTF-16, so double?
       , sz0      	:= 1 ; null termination, though seems to work as is
       , _b       	:= Buffer(1,0) ; small temp buffer for some reason bugs
       , bKeyNm   	:= Buffer(256,0)

      fnAPI   	:= "getuname.dll\GetUName" ; undoc GetUName(int c, LPWSTR* name) used by charmap.exe to obtain (localized) name of a Unicode char
      chCode  	:= Ord(char)
      ; char№ 	:= DllCall(fnAPI, "Int",chCode, "Ptr",_b, "Int") ; get needed buff size
      ; bKeyNm	:= Buffer(szWCh * (sz0 + char№), 0)
      char№   	:= DllCall(fnAPI, "Int",chCode, "Ptr",bKeyNm)
      keyNm   	:= StrGet(bKeyNm, "UTF-16")
      return keyNm
    }
    this.keyCharNameC   := keyCharNameC
    static keyCharNameC(char, ch_t:=0) { ; get unicode name for a char, eg, 'INFINITY' for ∞, for some reason dumb ALLCAPS format
      static szWCh	:= 2 ; this is UTF-16, so double?
        , sz0     	:= 1 ; null termination, though seems to work as is

      fnAPI	:= "icuuc.dll\u_charName" ;
      _bSz := 1 ;
      _b    	:= Buffer(_bSz,0)
      chCode	:= Ord(char)
      pErr0 	:= 0 ; CAN'T reuse pErr0, can't overwrite
      ; ch_t ; 0x24C2 ;UTF-16BE
        ; 0 CIRCLED LATIN CAPITAL LETTER M	LAO LETTER LO LING
        ; 2 CIRCLED LATIN CAPITAL LETTER M	2 LAO LETTER LO LING
        ; 3                               	3 LAO LETTER RO
        ; 1,4 empty
        ; U_UNICODE_CHAR_NAME     	Unicode character name (Name property)
        ;×U_UNICODE_10_CHAR_NAME  	The Unicode_1_Name property value which is of little practical value. Beginning with ICU 49, ICU APIs return an empty string for this name choice. Deprecated: ICU 49
        ; U_EXTENDED_CHAR_NAME    	Standard or synthetic character name
        ; U_CHAR_NAME_ALIAS       	Corrected name from NameAliases.txt
        ;×U_CHAR_NAME_CHOICE_COUNT	One more than the highest normal UCharNameChoice value. Deprecated: ICU 58 The numeric value may change over time, see ICU ticket #12420

      char№ 	:= DllCall(fnAPI, "Int",chCode,"Int",ch_t,"Ptr",_b,"Int",_bSz,"Ptr*",&pErr0,"Int")
      pErr  	:= 0
      bSz   	:= sz0 + char№
      bKeyNm	:= Buffer(bSz, 0)
      retlen	:= DllCall(fnAPI
        ,"Int",chCode ; UChar32 is a signed 32-bit integer (same as int32_t)
        ,"Int",ch_t	; enum UCharNameChoice
        ,"Ptr",bKeyNm    	;
        ,"Int",bSz       	;int32_t
        ,"Ptr*",&pErr
        ,"Int") ; ret
      keyNm := StrGet(bKeyNm, "UTF-8")
      return keyNm
    }

    this.hk🛈        := hk🛈
    static hk🛈(key, act, opt:="", help) { ; same as Builtin Hotkey, but can use ⇧ and add help message
      static k	:= keyConstant._map ; various key name constants, gets vk code to avoid issues with another layout
       , s    	:= helperString
       , k→a  	:= s.key→ahk.Bind(helperString)  ; ⎇⇧c or !+c ⟶ !+vk43
       , chU  	:= keyCharNameU
       , chC  	:= keyCharNameC
      k_ahk := k→a(key)
      for i_pre in ["$","~"] {
        if InStr(SubStr(key,1,2), i_pre) {
          key := StrReplace(key, i_pre)
        }
      }
      if help_keys.has(k_ahk) {
        throw ValueError("Duplicate hotkey being registered!", -1, key " or " k_ahk)
      } else {
        modi_flag := 0
        s.parseKeyCombo(key,&modi_ahk_arr_short,&nonmod)
        loop modi_ahk_arr_short.Length - 1 { ; skip the last that's not a modifier, but a modi as terminal key
          if s.modi_f_map.Has(modi_ahk_arr_short[A_Index]) {
            modi_flag |= s.modi_f_map[modi_ahk_arr_short[A_Index]] ; + → ⇧
          }
        }
        modi_arr := s.modf→arr(&modi_flag) ;⇧⎈◆⎇
        ;! too SLOW, fill before GUI is shown, not on startup
        ; if help.Has('🔣') {
        ;   _ch := ''
        ;   Loop Parse, help['🔣'] {
        ;     _chi := chU(A_LoopField)
        ;     if _chi == 'Undefined' {
        ;       _chi := chC(A_LoopField)
        ;     }
        ;     if _chi {
        ;       for repl in ['Latin ','Small ','Letter ','With '] {
        ;         _chi := StrReplace(_chi,repl,'')
        ;       }
        ;       _ch .= _chi . ' ¦ '
        ;     }
        ;   }
        ;   help['🔣name'] := StrLen(_ch) . " " . _ch
        ; }
        help['⇧'] := modi_arr[1]
        help['⎈'] := modi_arr[2]
        help['◆'] := modi_arr[3]
        help['⎇'] := modi_arr[4]
        help['c'] := nonmod
        help['k'] := key
        help['vk'] := "x" ; todo: convert key to helper format automatically, no need to require explicit ⌥⇧c​
        help_keys[k_ahk] := help
      }
      HotKey(k_ahk, act, opt)
    }
  }
}
; ————————————————————————— Functions —————————————————————————
RunActivMin(App, WorkDir:="", Size:="", Title:=1, PosFix:=0, Menu:=1, Match:="exe", CLIOpts:="") {
  ; App = C:\Path To\App\app.exe, add quotes to avoid running C:\Path.exe
    ; Size: Regular size unless Max/Min/Hide; Match: type of window matching (by exe, pid or window ID)
    ; CLIOpts - additional command line options
    ; PosFix make border/-less windows identical by fixing window's size/position
    ; Menu — hide Window's menu (but store it in a map for potential restoration)
  SendInput '{LWin up}' ; avoids WinKey appearing as stuck in ~CapsLock & X key combos
  static lastMinWinID := "" ; store the last minimized window to restore it instead of opening the topmost window to prevent repeated calls to this function from cycling windows
  Timeout := 10
  SplitPath(App, &ExeFileName)
  PID := ProcessExist(ExeFileName)
  ; dbgTT(3,"Debug:0`nProcessExist: " . ExeFileName,3)
  ; matchTypes := ["ahk_class", "ahk_id", "ahk_pid", "ahk_exe", "ahk_group"]
  ; Window Class, Unique ID/HWND, Process ID, Process Name/Path
  if (Match = "exe") {
    appTitle := "ahk_exe " ExeFileName
  ; } else if (i:=HasValue(matchTypes, "ahk_" Match)) {
    ; appTitle := matchTypes[i]
  } else {
    appTitle := Match
  }
  dbgTT(3,"dbg3:0`nappTitle set: " . appTitle,dbgT,2,TTx,TTy+TTyOff*(2-2))

  if (PID = 0) { ; App process doesn't exist, launch the App
    lastMinWinID := ""
    dbgTT(3,"dbg3:1 PID`n" PID . " PID is Zero",dbgT,3,TTx,TTy+TTyOff*(3-2))

    Run('"' . App . '"' . " " . CLIOpts, WorkDir, Size)
    if (Menu = 0 || Title = 0) {
      hWin := WinWait(appTitle, , Timeout)
      if (Menu = 0 ) {
        if hWin {
          Win_MenuToggle(hWin)
        } else {
          dbgTT(0,"NoMenu`nTimed out without hiding the menu",dbgT,4,TTx,TTy+TTyOff*(4-2))
        }
      }
      if (Title = 0) {
        if hWin {
          ; Win_TitleToggle(PosFix)
          Win_TitleToggleAll(App, PosFix, "-")
        } else {
          dbgTT(0,"NoTitle`nTimed out without applying a window style",dbgT,4,TTx,TTy+TTyOff*(4-2))
        }
      }
    }
  } else { ; App process exists
    dbgTT(3,"dbg3:1 PID`n" PID . " PID is nonZero",dbgT,3,TTx,TTy+TTyOff*(3-2))
    SetTitleMatchMode(2)
    DetectHiddenWindows(0)
    if WinActive(appTitle) { ; App Window Exists and is Active
      dbgTT(3,"dbg3:2.1 WinActive`nappTitle active: " . appTitle,dbgT,4,TTx,TTy+TTyOff*(4-2))
      lastMinWinID := appTitle
      WinMinimize(appTitle)
    } else if WinExist(appTitle) { ; App Window Exists, but NOT Active
      ; dbgTT(3,"Debug:2.2 WinExist`nappTitle ∃: " . appTitle,dbgT,4,TTx,TTy+TTyOff*(4-2))
      winIDs	:= WinGetList(appTitle)
      if (lastMinWinID = appTitle) {
        lastWinID	:= winIDs[-1] ; restore the previously minimized window instead of the top one
      } else {
        lastWinID	:= winIDs[ 1]
      }
      lastMinWinID := ""
      if (Title = 0) {
        Style   	:= WinGetStyle(lastWinID)
        StyleHex	:= Format("{1:#x}", Style)
        WinActivate(lastWinID)
        if WinWaitActive(lastWinID, , Timeout) {
          if (Style & 0x00C00000) {
          ; dbgTT(3,"Debug:2.4`nHas title WS_CAPTION 0x00C00000, var.Style=" StyleHex,dbgT,5,TTx,TTy+TTyOff*(5-2))
            ; Win_TitleToggle(PosFix)
            Win_TitleToggleAll(App, PosFix, "-")
          }
        } else {
          dbgTT(0,"Debug: Timed out without applying a window style",dbgT,5,TTx,TTy+TTyOff*(5-2))
        }
      } else {
        ; dbgTT(3,"Debug:2.4`nappTitle ∃: " . lastWinID . ", but Title isn't noTitle" . Title,dbgT,5,TTx,TTy+TTyOff*(5-2))
        WinActivate(lastWinID)
      }
    } else { ; App Window does NOT Exist
      ; dbgTT(3,"Debug:2.3 WinNotExists`nPID is nonZero:" . PID . ", appTitle ∃: " . appTitle . ", but Title isn't noTitle" . Title,dbgT,4,TTx,TTy+TTyOff*(4-2))
      Run('"' . App . '"' . " " . CLIOpts, WorkDir, Size)
      if (Menu = 0 || Title = 0) {
        hWin := WinWaitActive(appTitle, , Timeout) ; wait 5 seconds before applying a style
        if (Menu = 0 ) {
          if hWin {
            Win_MenuToggle(hWin)
          } else {
            dbgTT(0,"Debug:2.2 WinNotActive in 5s`n HideMen`nTimed out without hiding the menu",dbgT,4,TTx,TTy+TTyOff*(4-2))
          }
        }
        if (Title = 0) {
          if hWin {
            ; Win_TitleToggle(PosFix)
            Win_TitleToggleAll(App, PosFix, "-")
          } else {
            dbgTT(0,"Debug:2.2 WinNotActive in 5s`n NoTitle`nimed out without applying a window style",dbgT,4,TTx,TTy+TTyOff*(4-2))
          }
        }
      }
    }
  }
}

WinLock() { ;requires two elevated tasks in the Task Scheduler
  /* https://www.autohotkey.com/boards/viewtopic.php?f=76&t=69537
  I think there is a better way where you need neither an elevated script nor two UAC prompts.
  The trick is creating two tasks in the Task Scheduler that would flip the bit in the registry, e.g.
  1.
    Name: WinLock Disable
    Run with highest privileges check mark set
    Actions: start a program(this is the default)
    Program/script: REG
    Add arguments: ADD "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v DisableLockWorkstation /t REG_DWORD /d 00000001 /f
  2.
    Name: WinLock Enable
    Run with highest privileges check mark set
    Actions: start a program(this is the default)
    Program/script: REG
    Add arguments: ADD "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v DisableLockWorkstation /t REG_DWORD /d 00000000 /f
  */

  try {
    vIsDisabled := RegRead("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\System", "DisableLockWorkstation")
  } catch Error as err {
    dbgtxt := err2str(err)
    dbgtxt .= ' ¦ ' A_ThisFunc
    dbgTT(0, dbgtxt, 10,5,x:=-1,y:=-1)
    return
  }
  if (vIsDisabled) { ; enable 'lock workstation' (=Win+L) and lock
    Try RunWait('schtasks /Run /TN "\es\WinLock Enable"',,"Hide") ; REG ADD "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v DisableLockWorkstation /t REG_DWORD /d 00000000 /f
    Sleep(300)
    DllCall("user32\LockWorkStation") ; lock workstation
  }
  vIsDisabled := RegRead("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\System", "DisableLockWorkstation")
  if (!vIsDisabled) { ; disable 'lock workstation' (=Win+L)
    Try RunWait('schtasks /Run /TN "\es\WinLock Disable"',,"Hide") ; REG ADD "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v DisableLockWorkstation /t REG_DWORD /d 00000001 /f
  }
}

GroupHasWin(GroupName, wTitle:="", wText:="", ExcludeTitle:="", ExcludeText:="") {
  ; Check if the specified group contains the specified window (quasi-boolean)
  ; returns winID (HWND) if in the group, otherwise returns false (0)
  GroupIDs	:= WinGetList("ahk_group " GroupName)
  Window  	:= WinGetID(wTitle, wText, ExcludeTitle, ExcludeText)

  Loop GroupIDs.Length {
    if (GroupIDs[A_Index] = Window) { ;found match
      return Window
    }
  }
  return false
}

IsFunc(FunctionName){
  try {
    return %FunctionName%.MinParams+1
  } catch {
    return 0
  }
  return
}
