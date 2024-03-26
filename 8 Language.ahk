#Requires AutoHotKey 2.1-alpha.4
; Remap Capslock to keyboard layout switching between User layouts (learn.microsoft.com/en-us/openspecs/windows_protocols/ms-lcid/70feba9f-294e-491e-b6eb-56532684c37f)

; HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\Keyboard Layouts
; HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Console\Nls
; NB! ↓ loads a layout, disable if you've removed this layout manually in Settings and don't need it to reappear!
; en	:= DllCall("LoadKeyboardLayout"	, "str","00000409"	, "uint",1) ; kbdus.dll
; ru	:= DllCall("LoadKeyboardLayout"	, "str","00000419"	, "uint",1) ; kbdru.dll
enU 	:= DllCall("LoadKeyboardLayout"	, "str","00000409"	, "uint",1)
ruU 	:= DllCall("LoadKeyboardLayout"	, "str","00000419"	, "uint",1)
isRu() {
  return (lyt.GetCurLayout() = ruU) ? 'Ru' : ''
  }

^CapsLock::
!CapsLock::                     	{	;⎇⇪​	vk09 ⟶ Ctrl+Tab Restore
  ; SetCapsLockState "AlwaysOff"	;[CapsLock] disable
  LayoutSwitch()
  ; SendInput '#{Space}'	;[Alt+CapsLock] to switch Keyboard Layout (Win+Space)
  }

*LControl::{ ; keys are named Control, so using LCtrl wouldn't match
  SetKeyDelay(-1)
  Send("{Blind}{LCtrl down}")
  dbgtt(0,"↓‹⎈",'∞',5,0,A_ScreenHeight*.9)
  ; KeyWait("LCtrl") ;;; todo bugs shows ↓, but z prints z instead of undo
}
*RControl::{
  SetKeyDelay(-1)
  Send("{Blind}{RCtrl down}")
  dbgtt(0,"↓⎈›",'∞',6,50,A_ScreenHeight*.9)
  ; KeyWait("RCtrl")
}
~*LCtrl up::LCtrlUp()
LCtrlUp() {
  🕐1 := A_TickCount
  SetKeyDelay(-1) ; no delay
  Send "{Blind}{LCtrl up}"
  ; dbgtt(0,"↑‹⎈",'∞',5,0,A_ScreenHeight*.9)
  dbgtt(0,"",,5),dbgtt(0,"",,4),dbgtt(0,"",,3) ;
  dbgtt(0,"",'∞',5,0,A_ScreenHeight*.9)
  dbgtt(0,"",'∞',4,0,A_ScreenHeight*.8)
  dbgtxt := ''
  if A_PriorHotkey = ("*" A_PriorKey)
    && A_TimeSincePriorHotkey<120
    && !(GetKeyState("Shift"   	,"P")
      || GetKeyState("Ctrl"    	,"P")
      || GetKeyState("Alt"     	,"P")
      || GetKeyState("LWin"    	,"P")
      || GetKeyState("CapsLock"	,"P") ) {
    LayoutSwitch(enU)
    dbgtxt .= 'LayoutSwitch'
    }
  ; dbgtt(0,A_PriorHotkey ' ' A_PriorKey, 5) ;
  if   A_PriorHotkey = "LControl & Tab"
    || A_PriorHotkey = "LControl & q"
    || A_PriorHotkey = "LCtrl & Tab"
    || A_PriorHotkey = "LCtrl & q" {
    if GetKeyState("Shift") {
      dbgtxt .= '⇧↑⎇↑'
      Send("{LShift up}{LAlt up}")
    } else {
      dbgtxt .= '  ⎇↑'
      Send(           "{LAlt up}")
    }
  }
  🕐2 := A_TickCount
  OutputDebug('post ' format(" 🕐Δ{:.3f}",🕐2-🕐1) ' ' 🕐2 ' ' dbgtxt ' @' A_ThisFunc)
}
~*RCtrl up::{
  SetKeyDelay(-1) ; no delay
  Send "{Blind}{RCtrl up}"
  ; dbgtt(0,"↑⎈›",'∞',6,50,A_ScreenHeight*.9)
  dbgtt(0,"",,6) ;
  if A_PriorHotkey = ("*" A_PriorKey) ;RAlt = *RAlt
    && A_TimeSincePriorHotkey<120
    && !(GetKeyState("Shift"   	,"P")
      || GetKeyState("Ctrl"    	,"P")
      || GetKeyState("Alt"     	,"P")
      || GetKeyState("LWin"    	,"P")
      || GetKeyState("CapsLock"	,"P") ) {
    LayoutSwitch(ruU)
    ; Send "^{vkF2}" ; For Japanese, send ^{vkF2} to ensure Hiragana mode after switching. You can also send !{vkF1} for Katakana. If you use other languages, this statement can be safely omitted.
  }
  ; dbgtt(0,'A_PriorKey`t' A_PriorKey ' `nA_PriorHotkey`t' A_PriorHotkey,3)
}

LayoutSwitch(target?) {
  static locInf := localeInfo.m  ; Constants Used in the LCType Parameter of lyt.getLocaleInfo, lyt.getLocaleInfoEx, and SetLocaleInfo learn.microsoft.com/en-us/windows/win32/intl/locale-information-constants
   , kbdCountry	:= "sEnCountryNm"	;
   , kbdDisplay	:= "sEnDisplayNm"	;
  ; SendInput '{LWin Down}{Space}{LWin Up}'
  local curlayout := lyt.GetCurLayout(&lytPhys, &idLang)
  local targetWin := "A" ; Active window to PostMessage to, need to be changed for '#32770' class (dialog window)

  if WinActive("ahk_class #32770") {  ; dialog window class requires sending a message to the active window via ControlGetFocus
    targetWin := ControlGetFocus("A") ; Retrieves which control of the target window has keyboard focus, if any
  }
  if not WinExist(targetWin) { ; no window to post message to, use shortcuts
    if not isSet(target) {
      SendInput('#{Space}')
    } else if target = enU {
      ; SendInput('{LShift down}{LAlt down}6{LShift up}{LAlt up}') ; set in system config
      SendInput('+!6')
    } else if target = ruU { ;
      ; SendInput('{LShift down}{LAlt down}7{LShift up}{LAlt up}')
      SendInput('+!7')
    }
    ; return
  }
  if isSet(target) {
    PostMessage changeInputLang, 0, target,       , targetWin
    return
  }
  if        (curlayout = enU) {
    PostMessage changeInputLang, 0, ruU,       , targetWin
    ;           Msg,            w/, lParam ,Control, WinTitle
    ; dbgTT(0,"Current enU, switching to ruU")
  } else if (curlayout = ruU) {
    PostMessage changeInputLang, 0, enU,       , targetWin
    ; dbgTT(0,"Current ruU, switching to enU")
  } else {
    dbgTT(0,"Layout neither enU nor ruU, not switching anything")
  }
  ; LocaleDbg()
  }
