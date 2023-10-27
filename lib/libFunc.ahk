#Requires AutoHotKey 2.1-alpha.4

#include <constKey>	; various key constants
#include <str>     	; string helper functions

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
  }
}
; ————————————————————————— Functions —————————————————————————
RunActivMin(App, WorkDir:="", Size:="", Title:=0, PosFix:=0, Menu:=1, Match:="exe", CLIOpts:="") {
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
          TT("NoMenu`nTimed out without hiding the menu",dbgT,4,TTx,TTy+TTyOff*(4-2))
        }
      }
      if (Title = 0) {
        if hWin {
          ; Win_TitleToggle(PosFix)
          Win_TitleToggleAll(App, PosFix, "-")
        } else {
          TT("NoTitle`nTimed out without applying a window style",dbgT,4,TTx,TTy+TTyOff*(4-2))
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
          TT("Debug: Timed out without applying a window style",dbgT,5,TTx,TTy+TTyOff*(5-2))
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
            TT("Debug:2.2 WinNotActive in 5s`n HideMen`nTimed out without hiding the menu",dbgT,4,TTx,TTy+TTyOff*(4-2))
          }
        }
        if (Title = 0) {
          if hWin {
            ; Win_TitleToggle(PosFix)
            Win_TitleToggleAll(App, PosFix, "-")
          } else {
            TT("Debug:2.2 WinNotActive in 5s`n NoTitle`nimed out without applying a window style",dbgT,4,TTx,TTy+TTyOff*(4-2))
          }
        }
      }
    }
  }
}

TotalCMD_CD(CDTo) {
  ; RunActivMin("c:\Dev\totalcmd\TOTALCMD64.EXE") ; avoding dupliate TC instance done via /O
  ; replace the following with native New-Tab command not to depend on keyboard shortcuts
  ;Sleep 100
  ;SendInput ^{vk54}     ;t vk54  ; not needed anymore as opening a new tab by TC
  Run("C:\Dev\totalcmd\TOTALCMD64.EXE /O /S /T " CDTo)
  Sleep 300   ; a simple wait until TC is launched (too short to bother with a cond check)
  Run("C:\Dev\totalcmd\Addons\TCFS2\TCFS2.exe /ef eval(tcd(``" CDTo "```,`,S)+msg($433`,3009`,`,1))")
  Sleep 100
  SendInput '{UP}{ENTER}'   ; Ingores user's keys
}

OpusDir_CD(CDTo) { ; AppDOpus
  ;AppDOpusRt /acmd Go LASTACTIVELISTER
  ;AppDOpusRt /acmd Go LASTACTIVELISTER NEW
  ; DopusWinID := WinExist(WinTitle, WinText, ExcludeTitle, ExcludeText)
  SplitPath(AppDOpus, &ExeFileName)
  PID := ProcessExist(ExeFileName)
  if (PID := 0) {
    ; dbgTT(3,"Debug:`nPID=0 1) Run " AppDOpus "`n2) Sleep 1000",dbgT,2,TTx,TTy+TTyOff*(2-2))
    Run('"' . AppDOpus . '"')
    Sleep 1000
  } else {
      if WinExist("ahk_class dopus.lister") {
        ; dbgTT(3,"Debug:`nElse 1) WinExist ahk_class dopus.lister`n2) WinActivate",dbgT,2,TTx,TTy+TTyOff*(2-2))
        WinActivate  ; Uses the last found window
      } else {
        Run('"' . AppDOpusRt . '"' . " /acmd Go LASTACTIVELISTER NEW")
        Sleep 1000 ; wait untill new Lister is launched
      }
    Run('"' . AppDOpusRt . '"' . " /acmd Go " '"' CDTo '"' " NewTab=findexisting,tofront")
    Sleep 300
    Run('"' . AppDOpusRt . '"' . " /acmd CloseTabSiblings")
  }
  ;Quit Opus or OpusRT from scripts
  ;AppDOpusRt /dblclk=off
  ;AppDOpusRt /CMD Close PROGRAM
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

  vIsDisabled := RegRead("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\System", "DisableLockWorkstation")
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
