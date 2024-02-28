#Requires AutoHotKey 2.1-alpha.4

; +#Tab::AppWindowSwitcher(→)	;⇧❖​ 	⭾​ ⟶ Switch to Next     App's Window (↑ Z-order)
; #Tab:: AppWindowSwitcher(←)	;  ❖​	⭾​ ⟶ Switch to Previous App's Window (↓ Z-order)
; #vk4b::AppWindowSwitcher(→)	;  ❖​	k​  ⟶ Switch to Next     App's Window (↑ Z-order)
; #vk4a::AppWindowSwitcher(←)	;  ❖​	j​  ⟶ Switch to Previous App's Window (↓ Z-order)
; #vk49::SwapTwoAppWindows() 	;  ❖​	i​  ⟶ Switch between 2   App's Windows
; +#vk49::dbgShowWinZOrder() 	;  ❖​	i​  ⟶ Switch between 2   App's Windows
; ↑ shorter, but to avoid i18n layout issues need(?) to use VKs :(
; ↓ can use variables in key names, e.g. have dynamic modifiers that are easier to update if hardware is changed
setAppSwitcher()
setAppSwitcher() {
  static k	:= keyConstant._map ; various key name constants, gets vk code to avoid issues with another layout
   , s    	:= helperString

  loop parse "⭾kj" { ;⭾
    HotKey(s.key→ahk(‹␠3 k[A_LoopField]), AppSwitcher)
  }
    HotKey(s.key→ahk('⇧❖​ ⭾'), AppSwitcher)
  AppSwitcher(ThisHotkey) {
    Switch ThisHotkey  {
      default  : return
      ; default  : msgbox('nothing matched AppSwitcher ThisHotkey=' . ThisHotkey)
      case s.key→ahk('⇧❖​ ⭾​') 	: AppWindowSwitcher(→)	; Switch to Next     App's Window (↑ Z-order)
      case s.key→ahk('  ❖​ ⭾​')	: AppWindowSwitcher(←)	;   ...    to Previous App's Window (↓ Z-order)
      case s.key→ahk('  ❖​ k​')	: AppWindowSwitcher(→)	;   ...    to Next     App's Window (↑ Z-order)
      case s.key→ahk('  ❖​ j​')	: AppWindowSwitcher(←)	;   ...    to Previous App's Window (↓ Z-order)
      case s.key→ahk('  ❖​ i​')	: SwapTwoAppWindows() 	;   ...    between 2   App's Windows
      ; case s.key→ahk('❖​ i​')	: dbgShowWinZOrder()  	;   ...    between 2   App's Windows
    }
  }
}

; #HotIf WinActive("ahk_group ⌥⭾AppSwitcher") ; BUG autohotkey.com/boards/viewtopic.php?f=82&t=120739 Invoking ShiftAltTab changes direction for regular Alt+Tab
#HotIf WinActive("ahk_exe explorer.exe ahk_class MultitaskingViewFrame")
  ; !vk49::dbgShowWinZOrder()	;  ❖​	i  ⟶ Switch between the last 2 Windows of the same App
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

AppWindowSwitcher(dir:=→) {
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

  winA_id    	:= WinGetID(         "A")
  winA_proc  	:= WinGetProcessName("A")
  winA_procP 	:= WinGetProcessPath("A")
  winA_procID	:= WinGetPID(        "A")
  winA_cls   	:= WinGetClass(      "A")

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

dbgShowWinZOrder() {
  winA_id    	:= WinGetID(         "A")
  winA_proc  	:= WinGetProcessName("A")
  winA_cls   	:= WinGetClass(      "A")
  winA_procID	:= WinGetPID(        "A")
  if winA_proc = "explorer.exe" { ; Explorer needs an extra condition to only count actual File Explorer windows
    winTitleMatch	:= "ahk_pid " winA_procID " ahk_class " winA_cls
  } else {
    winTitleMatch	:= "ahk_pid " winA_procID
  }
  winIDs	:= WinGetList(winTitleMatch)

  _test	:= "winA_proc="  . winA_proc
  _test	.= "`nwinTitle=" . winTitleMatch
  showWinZOrder(winTitleMatch, _test)
  return
}
showWinZOrder(winTitleMatch:="", txt:="", skipEmtpy:=1) {
  _test 	:= txt
  winIDs	:= WinGetList(winTitleMatch)
  _test .= "│id" "`t│title="
  for this_id in winIDs {
    winA_title	:= WinGetTitle(this_id)
    if (skipEmtpy = 1) and (winA_title = "") {
    } else {
      _test .= "`n│" this_id "`t│" winA_title
    }
  }
  ; winA_title	:= WinGetTitle(winNext_id)
  ; _test .= "`n│next_id=" winNext_id "│title=" winA_title
  rndid := Round(Random(1,20))
  _lastID := winIDs[-1]
  winA_title	:= WinGetTitle(_lastID)
  _test .= "`n│_lastID=" _lastID "│" winA_title
  dbgTT(dbgMin:=0, Text:=_test , Time:=4,id:=rndid,X:=1550,Y:=850)
  return
}
