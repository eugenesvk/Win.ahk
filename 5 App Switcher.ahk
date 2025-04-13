#Requires AutoHotKey 2.1-alpha.4
#include <constKey>                        	; various key constants
#include <Array>                           	; Array helpers
#include %A_scriptDir%\gVar\varWinGroup.ahk	; App groups for window matching
#include %A_scriptDir%\gVar\isKey.ahk      	; track key status programmatically
#include <Win>                             	; win status
#include <winAltTab>                       	; Activated windows history in AltTab order

WinAltTab.set_hooks() ; start collecting activated windows history
; !F2::Send "{Alt up}"  ; Release the Alt key, which activates the selected window
<+>+1::Focus("up"    	) ;Goes through all of the windows per monitor backwards
<+>+2::Focus("down"  	) ;Goes through all of the windows per monitor forwards
<+>+3::Focus("recent"	) ;Opens the last used window per monitor
#z::Focus("up"       	) ;Goes through all of the windows per monitor backwards
#x::Focus("down"     	) ;Goes through all of the windows per monitor forwards
#e::#x ; restore open start menu

!#i::dbg_win_active_list(,ord⎇⭾:=true)
^F3::dbg_win_active_list(,ord⎇⭾:=true)
!F3::dbg_win_active_list(,ord⎇⭾:=true)

#HotIf WinExist("ahk_group AltTabWindow")
; ~*Esc::Send "{Alt up}"  ; When the menu is cancelled, release the Alt key automatically
*Esc::Send "{Esc}{Alt up}"  ; Without tilde (~), Escape would need to be sent
#HotIf

hkmyAltTab(hk) {
  myAltTab()
}
myAltTab() { ; without sending ⎈↑ AppSwitcher becomes "sticky"
  static _:=0
   ,_d 	:= 0
   ,_d1	:= 1
  (dbg<_d)?'':(🕐1 := A_TickCount)
  SetKeyDelay(-1)
  isKey↓.⎇↹ := 1
  if        GetKeyState("Shift","P") { ; move ←
    SendEvent("{Blind}{LCtrl up}{LAlt down}{LShift down}" "{Tab}") ,(dbg<_d)?'':(🕐2 := A_TickCount, dbgtxt:="↓‹⇧₊‹⎇⭾ ←¹")
    ; SendEvent("{Blind}{LCtrl up}{LAlt down}{LShift down}") ,(dbg<_d)?'':(🕐2 := A_TickCount, dbgtxt:="↓‹⇧₊‹⎇ ←¹")
  } else if GetKeyState("Shift"    ) { ; move →
    SendEvent("{Blind}{LCtrl up}{LAlt down}{LShift up}"   "{Tab}") ,(dbg<_d)?'':(🕐2 := A_TickCount, dbgtxt:="↓   ‹⎇⭾ →²")
    ; SendEvent("{Blind}{LCtrl up}{LAlt down}{LShift up}"  ) ,(dbg<_d)?'':(🕐2 := A_TickCount, dbgtxt:="↓   ‹⎇ →²")
  } else {                             ; move →
    SendEvent("{Blind}{LCtrl up}{LAlt down}"              "{Tab}") ,(dbg<_d)?'':(🕐2 := A_TickCount, dbgtxt:="↓   ‹⎇⭾ →³")
    ; SendEvent("{Blind}{LCtrl up}{LAlt down}"             ) ,(dbg<_d)?'':(🕐2 := A_TickCount, dbgtxt:="↓   ‹⎇ →³")
  }
  ; Sleep(10)
  ; SendEvent("{Blind}{Tab down}{Tab up}")
  dbgtxt .= ' (isKey↓.⎇↹)'
  (dbg<_d1)?'':ShowModStatus() ;;; text bug with Tab key getting stuck
  (dbg<_d)?'':(OutputDebug(dbgtxt format(" 🕐Δ{:.3f}",🕐2-🕐1) ' ' 🕐2 ' @' A_ThisFunc))
  ; (dbg<_d)?'':dbgtt(0,dbgtxt,'∞',4,0,A_ScreenHeight*.85)
}

; +#Tab::AppWindowSwitcher(→)	;⇧❖​ 	⭾​ ⟶ Switch to Next     App's Window (↑ Z-order)
; #Tab:: AppWindowSwitcher(←)	;  ❖​	⭾​ ⟶ Switch to Previous App's Window (↓ Z-order)
; #vk4b::AppWindowSwitcher(→)	;  ❖​	k​  ⟶ Switch to Next     App's Window (↑ Z-order)
; #vk4a::AppWindowSwitcher(←)	;  ❖​	j​  ⟶ Switch to Previous App's Window (↓ Z-order)
; #vk49::SwapTwoAppWindows() 	;  ❖​	i​  ⟶ Switch between 2   App's Windows
; +#vk49::dbg_win_active_list() 	;  ❖​	i​  ⟶ Switch between 2   App's Windows
; ↑ shorter, but to avoid i18n layout issues need(?) to use VKs :(
; ↓ can use variables in key names, e.g. have dynamic modifiers that are easier to update if hardware is changed
setAppSwitcher()
setAppSwitcher() {
  static k	:= keyConstant._map ; various key name constants, gets vk code to avoid issues with another layout
   , s    	:= helperString

  loop parse "⭾kjq" { ; Fast switching between windows without showing AppSwitcher+Desktops
    HotKey(s.key→ahk(‹␠3 k[A_LoopField]), AppSwitcher)
  }
    HotKey(s.key→ahk('⇧❖​ ⭾'           ), AppSwitcher)
  AppSwitcher(ThisHotkey) {
    Switch ThisHotkey  {
      default  : return
      ; default  : msgbox('nothing matched AppSwitcher ThisHotkey=' . ThisHotkey)
      case s.key→ahk('  ❖​ ⭾​')	: AppWindowSwitcher(←)	;   ...    to Previous App's Window (↓ Z-order)
      case s.key→ahk('  ❖​ q​')	: AppWindowSwitcher(→)	; Switch to Next     App's Window (↑ Z-order)
      case s.key→ahk('⇧ ❖​ ⭾​')	: AppWindowSwitcher(→)	; Switch to Next     App's Window (↑ Z-order)
      case s.key→ahk('⇧ ❖​ q​')	: AppWindowSwitcher(←)	;   ...    to Previous App's Window (↓ Z-order)
      case s.key→ahk('  ❖​ k​')	: AppWindowSwitcher(→)	;   ...    to Next     App's Window (↑ Z-order)
      case s.key→ahk('  ❖​ j​')	: AppWindowSwitcher(←)	;   ...    to Previous App's Window (↓ Z-order)
      case s.key→ahk('  ❖​ i​')	: SwapTwoAppWindows() 	;   ...    between 2   App's Windows
      ; case s.key→ahk('❖​ i​')	: dbg_win_active_list()  	;   ...    between 2   App's Windows
    }
  }
}

#HotIf WinActive("ahk_group ⌥⭾AppSwitcher") ; BUG autohotkey.com/boards/viewtopic.php?f=82&t=120739 Invoking ShiftAltTab changes direction for regular Alt+Tab
; #HotIf WinActive("ahk_exe explorer.exe ahk_class MultitaskingViewFrame")
  LControl & q::{
    static _:=0
     ,_d 	:= 0
     ,_d1	:= 1
    (dbg<_d)?'':(🕐1 := A_TickCount)
    SetKeyDelay(-1)
    isKey↓.⎇q := 1
    if        GetKeyState("Shift","P") { ; move →
      Send("{LAlt down}"           "{Tab}")   ,(dbg<_d)?'':(🕐2 := A_TickCount, dbgtxt:="↓  ‹⎇⭾ →¹")
    } else if GetKeyState("Shift"    ) { ; move ←
      Send("{LAlt down}{LShift down}{Tab}")   ,(dbg<_d)?'':(🕐2 := A_TickCount, dbgtxt:="↓‹⇧‹⎇⭾ ←²")
    } else                             { ; move ←
      Send("{LAlt down}{LShift down}{Tab}")   ,(dbg<_d)?'':(🕐2 := A_TickCount, dbgtxt:="↓‹⇧‹⎇⭾ ←³")
    }
    dbgtxt .= ' (isKey↓.⎇q)'
    (dbg<_d1)?'':ShowModStatus() ;;; text bug with Tab key getting stuck
    (dbg<_d)?'':(OutputDebug(dbgtxt format(" 🕐Δ{:.3f}",🕐2-🕐1) ' ' 🕐2 ' @' A_ThisFunc))
    ; KeyWait("LCtrl") ;
    ; SendEvent('{LAlt down}+{Tab}')
  }
#HotIf

#HotIf WinActive("ahk_exe explorer.exe ahk_class MultitaskingViewFrame")
  ; !vk49::dbg_win_active_list()	;  ❖​	i  ⟶ Switch between the last 2 Windows of the same App
  ; LAlt & q::ShiftAltTab    	;  ⌥​	q  ⟶ Switch to Next window (← in the switcher)
  ; LAlt & q::ShiftAltTab    	;  ⌥​	q  ⟶ Switch to Next window (← in the switcher)
  ; !vk51::+!Tab             	;  ⌥​	q  ⟶ Switch to Next window (← in the switcher)
  ; !vk51::!Left             	;  ⌥​	q  ⟶ Switch to Next window (← in the switcher)
  ; LAlt & vk51::            	ShiftAltTab
  ; LAlt & Tab::             	AltTab
  ; !4::MsgBox "You pressed Alt+4 in AppSwitcher"
  !q::Send('{Blind}+{Tab}')
  ; *F1::Send "{Alt down}{tab}" ; Asterisk is required in this case.
  ; !F2::Send "{Alt up}"  ; Release the Alt key, which activates the selected window.
#HotIf

; LAlt & q::ShiftAltTab	;  ⌥​	q  ⟶ Switch to Next window (← in the switcher)
; #If GetKeyState("LWin")
; >+Tab::ShiftAltTab

SwapTwoAppWindows() { ; Instantly swap between the last 2 windows without showing any icons/thumnails
  static isNext	:= false ; switch to the next window
  if isNext {
    AppWindowSwitcher(dir:=→)
    isNext	:= false
  } else {
    AppWindowSwitcher(dir:=←)
    isNext	:= true
  }
}

AppWindowSwitcher(dir:=→) { ; Switch between windows of the same app
  isPrevStr	:= ["Prev","←",←] ; accepted arguments for directions
  isNextStr	:= ["Next","→",→]
  ;——————————————————————————————————————————————————
  isPrev	:= false
  isNext	:= false
  winI := 0
  for iPrev in isPrevStr {
    if (dir=iPrev) {
      isPrev	:= true
    }
  }
  if (isPrev = false) {
    for iNext in isNextStr {
      if (dir=iNext) {
        isNext	:= true
      }
    }
  }
  if (isPrev = false and isNext = false) {
    return
  }

  try {
    winA_id    	:= WinGetID(         "A")
    winA_proc  	:= WinGetProcessName("A")
    winA_procP 	:= WinGetProcessPath("A")
    winA_procID	:= WinGetPID(        "A")
    winA_cls   	:= WinGetClass(      "A")
  } catch TargetError as e {
    return
  }

  ; dbgtt(0,winA_proc . " ¦ " . winA_procP . " ¦ " . winA_cls . " ¦ " . winA_procID,t:=5)
  if winA_proc = "explorer.exe" { ; Explorer needs an extra condition to only count actual File Explorer windows
    winTitleMatch	:= "ahk_pid " winA_procID " ahk_class " winA_cls
  } else {
    winTitleMatch	:= "ahk_pid " winA_procID
  }
  winIDs	:= WinGetList(winTitleMatch)

  appWins := Object()
  appWins.id := winIDs
  appWins.i  := 1

  winID_count	:= winIDs.Length

  _test	:= "winA_proc="  . winA_proc
  _test	.= "`nwinTitle=" . winTitleMatch
  if        (winID_count = 1) {
  } else if (winID_count = 2) {
    winNext_id	:= winIDs[2]
    winTop(winNext_id)
  } else {
    if        isPrev {
      ; winI	:=  1 ; most recently switched away from window, down the Z-order
      WinMoveBottom("A")
      WinActivate(winTitleMatch)
    } else if isNext {
      winI    	:= -1 ; oldest switched away from window, at the bottom of the Z-order
      winTo_id	:= winIDs[winI]
      winTop(winTo_id)
      winA_title	:= WinGetTitle(winTo_id)
      _test .= "`n│winTo_id=" winTo_id "│title=" winA_title
    }
  }
  ; _tvars := _test "`n│winI=" winI "│isPrev=" isPrev "│isNext" isNext
  ; showWinZOrder(winTitleMatch, _tvars)
  return
  }
winTop(win_id) {
  ; WinMoveTop( "ahk_id " win_id) ; Bring window to the top of the stack without explicitly activating it
    ; ↑ may have no effect due to OS protection against applications that try to steal focus from the user (it may depend on factors such as what type of window is currently active and what the user is currently doing)
    ; ↓ work-around: make the window briefly always-on-top via WinSetAlwaysOnTop, then turn off always-on-top
  WinSetAlwaysOnTop(1, "ahk_id " win_id)
  WinSetAlwaysOnTop(0, "ahk_id " win_id)
  WinActivate(         "ahk_id " win_id)
}

dbg_win_active_list(&windows?, ord⎇⭾:=true, exe:=false) { ; show a tooltip with the list of windows in Z-order
  ; W11? includes topmost 1 ApplicationManager_ImmersiveShellWindow
  static wseTopMost := 0x00000008 ; Window should be placed above all non-topmost windows and should stay above them, even when the window is deactivated. To add or remove this style, use the SetWindowPos function.
   , _d	:= 0
  if !IsSet(windows) {
    windows	:= win_active_list(ord⎇⭾)	; Gather Alt-Tab / Z-Ordered window list
  }
  win_titles := "" ; . WinGetClass(windows[1]) . '`n'
  nsp := ''
  loop StrLen(windows.Length) - 1 {
    nsp .= ' '
  }
  nsp := windows.Length > 9 ? ' ' : ''
  max_width 	:= 30
  for i, w_id in windows {
    txt_i 	:= ''
    w_name	:= WinGetTitle("ahk_id " w_id) || '🅲' WinGetClass("ahk_id " w_id)
    txt_i 	.= (wseTopMost & WinGetExStyle(w_id)) ? '⇞' : ' '
    txt_i 	.= i <= 9 ? nsp : ''
    txt_i 	.= A_Index . " " . SubStr(w_name,1,max_width)
    txt_i 	.= win.is_cloaked(w_id)?'👓':''
    txt_i 	.= win.is_invisible(w_id)?'🕶':''
    if exe {
      w_exe	:= exe?RegExReplace(WinGetProcessName("ahk_id " w_id), "\.exe$"):''
      txt_i	:= Format("{:-" max_width + 5 "}`t¦ ", txt_i) ; pad to ~align in columns
      txt_i .= w_exe
    }
    txt_i .= "`n"
    win_titles .= txt_i
  }
  (dbg<_d)?'':(dbgTT(0,win_titles,🕐:=5,,x:=0,y:=0))
}

Focus(z_to, ord⎇⭾:=true) { ; original iseahound 2022-09-16 autohotkey.com/boards/viewtopic.php?f=83&t=108531
  ;  1 first	window in ≝⎇⭾ or z-order
  ; -1 last 	window in ≝⎇⭾ or z-order
  ;  5      	window in ≝⎇⭾ or z-order (clamped by 1/window count)
  ; recent  	Switch to  last used window
  ;↑ up     	Iterate through all windows backwards (revert down or from oldest to recent)
  ;↓ down   	Iterate through all windows down      (revert up   or from recent to oldest)
  static wseTopMost := 0x00000008 ; Window should be placed above all non-topmost windows and should stay above them, even when the window is deactivated. To add or remove this style, use the SetWindowPos function.

  static _z_to	:= ""	; Last z_to parameter passed
   , _zi      	:= 0 	; Last z (use _z_to to initialize)
   , _win     	:= []	; Last z_to list to detect order changes made outside of this function
   , _d       	:= 1
   , _d1      	:= 1
  if        z_to = "↑" { ; canonicalize to avoid _z_to != z_to fails just because of a different format
    z_to := "up"
  } else if z_to = "↓" {
    z_to := "down"
  }

  windows	:= win_active_list(ord⎇⭾)	; Gather window list (Z-order, topmost have no recent sorting)
  debug  	:= False
  dbgtxt 	:= ""
  (dbg<_d)?'':(dbg_win_active_list(windows,ord⎇⭾))

  win_c := windows.length
  if        (win_c == 0) { ; Do nothing if no windows are found
    return 0
  } else if (win_c == 1) { ; Sole window
    WinActivate(windows[1])
    return      windows[1]
  }

  win_c_top := 0 ; № normal win ≥ 2. AlwaysOnTop never activated since they are already active
  for hwnd in windows {
    if wseTopMost & WinGetExStyle(hwnd) {
      win_c_top += 1
    }
  }
  win_c_nontop := win_c - win_c_top
  if (win_c_nontop < 2) {
    WinActivate(windows[-1]) ; AlwaysOnTop windows are listed first
    return      windows[-1]
  }

  recent() { ; Switches to the most recent window. Ignore topmost (no need to switch to them, they're already on top)
    loop win_c { ; Find window after active (in z_to)
      _zi := A_Index + 1
    } until (WinActive('A') = windows[A_Index])
    if (_zi > win_c) { ; no-break ; If active window is not found (desktop or another monitor), get 2nd window (except topmost)
      loop win_c {
        _zi := A_Index + 1
      } until not (wseTopMost & WinGetExStyle(windows[A_Index]))
    }
    if (_zi > win_c) { ; no-break ; 0 windows or 1 window are caught in the beginning
      debug := True
    }
  }
  prev() { ; Switches to prev window
    loop win_c { ; Find window before active
      _zi := A_Index - 1
    } until (WinActive('A') = windows[A_Index])
      (dbg<_d1)?'':(dbgtxt .= "prev()₁¦" _zi)
    if (_zi > win_c - 1) { ; no-break ; active window is not found (desktop/another monitor), get 2nd window (except topmost)
      loop win_c {
        _zi := A_Index - 1
      } until not (wseTopMost & WinGetExStyle(windows[A_Index]))
      (dbg<_d1)?'':(dbgtxt .= " ₂¦ " _zi)
    }
    if (_zi > win_c - 1) { ; no-break ; 0 windows or 1 window are caught in the beginning
      debug := True
      (dbg<_d1)?'':(dbgtxt .= " ₃¦ " _zi)
    }
    if (_zi < 1 ) { ; wrap to win_c absolute order (from first to last)
      _zi += win_c
      (dbg<_d1)?'':(dbgtxt .= " ₄¦ " _zi)
    }
    if (_zi <= win_c_nontop ) { ; ignore topmost windows, so switch to last
      _zi := win_c
      (dbg<_d1)?'':(dbgtxt .= " ₅¦ " _zi)
    }
  }
  if (z_to ~= "^-?\d+$") { ; z_to = number, use it directly. Can address elements in reverse: [-1] bottom
    abs_zi := (z_to>=0) ? z_to : z_to + win_c ; convert -1 to last (absolute win list coords)
    _zi := Min(win_c, Max(1, abs_zi)) ; avoid invalid indices
    (dbg<_d1)?'':(dbgtxt .= _zi " manual")
  } else {
    if (z_to = "recent") {
      recent()
    }

    if        (z_to  = "down") { ; Iterate through all the windows in a circular loop
      if (    _z_to != z_to ; change direction
        ||       _zi > win_c   	; index exceeds the available windows
        || !_win.🟰(&windows)) {	; unexpected order change
        (dbg<_d1)?'':(dbgtxt .= "recent (×down)" (((_z_to != "down")&&(_z_to != "up"))?" Δz_to":'      ') ((_zi > win_c)?" zi>№❖":'      ') ((!_win.🟰(&windows))?" Δ❖order ":''))
        recent()
      } else if (_zi < win_c) {
        (dbg<_d1)?'':(dbgtxt .= "zi++ (zi<win_c)")
        _zi++
      } else if (_zi = win_c) { ; move last to the top, shifting the stack down. Repeat after cycling through all the windows
        (dbg<_d1)?'':(dbgtxt .= "zi== (№" _zi "=" win_c "❖)")
      }
    } else if (z_to  = "up") { ; Iterate through all the windows in a circular loop backwards
      if ( ( (_z_to != "down") ;  change direction doesn't matter??? todo check of prev() is bugge
          && (_z_to != "up")) ; other than ±1 cycling
        ||       _zi < 1       	; index below the available windows
        || !_win.🟰(&windows)) {	; unexpected order change
        (dbg<_d1)?'':(dbgtxt .= "up (×reset)" (((_z_to != "down")&&(_z_to != "up"))?" Δz_to":'      ') ((_zi < 1)?" zi<1":'      ') ((!_win.🟰(&windows))?" Δ❖order ":''))
        prev()
      } else if (_z_to = "down") and (_zi = win_c) {
        (dbg<_d1)?'':(dbgtxt .= "recent (№" _zi ">" win_c "❖)")
        recent()
      } else if (_zi > win_c_top + 2) {
        (dbg<_d1)?'':(dbgtxt .= "zi== (№" _zi ">" win_c_top + 2 "❖⇞+1)")
      } else if (_zi <= win_c_top + 2) { ; skip topmost
        (dbg<_d1)?'':(dbgtxt .= "last (" _zi "≤" win_c_top + 2 "❖⇞+1)")
        _zi := win_c ; last/bottom. Repeats after cycling through all the windows
      }
    }
    (dbg<_d1)?'':(dbgtxt .= " ❖" win_c "⇞" win_c_top)
  }

  if debug {
    dbg_win_active_list(&windows,ord⎇⭾)
    return
  }

  db_hd := ((hwnd ?? "no")="no")?'✗':"✓"
  (dbg<_d1)?'':(dbgtxt .= "`n" _zi " " db_hd " ¦ " _z_to "← →" z_to)
  (dbg<_d1)?'':(dbgTT(0, dbgtxt, 🕐:=4, , x:=313,y:=Max(0,_zi*24-47)))
  _z_to := z_to
  hwnd := hwnd ?? windows[_zi] ;coalescing operator IsSet(A) || B
  WinActivate("ahk_id " hwnd)
  rm_win := windows.RemoveAt(_zi)
  windows.InsertAt(1 + win_c_top, rm_win) ;insert after topmost
  _win := windows

  return hwnd
}

win_active_list(ord⎇⭾:=true) { ; Window list, Z-order or Alt-Tab order
  ; ✗ Z-order: topmost have no recent sorting, minimized "lose" their recency status, get dumped to the bottom
  ; added ⎇⭾ to iseahound's autohotkey.com/boards/viewtopic.php?f=83&t=108531 (based on ophthalmos' autohotkey.com/boards/viewtopic.php?t=13288)
  static _d:=0, _d1:=1, _d2:=2

  WinZList := win.get_switcher_list_z_order()

  if not ord⎇⭾ {
    return WinZList
  } else {
    win_ord := [] ; ↓ sort WinZList according to recency stored at WinAltTab.History
    win_z_c := WinZList.Length
    (dbg<_d2)?'':(dbgTT(0, win_z_c "`nin History", 🕐:=1, , x:=A_ScreenWidth-50,y:=0))
    moved_i := []
    moved_c := 0
    loop WinAltTab.History.Length {
      win_id := WinAltTab.History[-A_Index] ; most recent
      if (i_found := WinZList.IndexOf(win_id, 1)) { ; move
        win_ord.push(win_id)
        moved_i.push(i_found)
        moved_c += 1
        if moved_c = win_z_c {
          break
        }
      }
    }
    remain := win_z_c - moved_c ; moved_i.Length
    if (remain > 0) { ; not all active windows are in the list, push them to the end of the list
      (dbg<_d1)?'':(dbgTT(0, remain " windows remaining", 🕐:=1))
      loop WinZList.Length {
        if moved_i.IndexOf(A_Index) { ; moved earlier, skip
          continue
        } else { ; new index, push to the end
          win_ord.push(WinZList[A_Index])
        }
      }
    }
    return win_ord
  }
}
