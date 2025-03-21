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
tryPostMsg(msg,w,l,Win,Contr?) {
  static _d := 3
  try {
    if isSet(Contr) {
      (dbg<_d)?'':dbgTT(_d,"using Contr",🕐:=3)
      PostMessage(msg, w,l, Contr,Win)
    } else {
      (dbg<_d)?'':dbgTT(_d,"no Contr",🕐:=3)
      PostMessage(msg, w,l,      ,Win)
    }
  } catch as err {
    dbgtxt := err2str(err) ' ¦ ' A_ThisFunc
    dbgTT(0, dbgtxt, 🕐:=10,id:=5,x:=-1,y:=-1)
  }
}
LayoutSwitch(target?) {
  static locInf := localeInfo.m  ; Constants Used in the LCType Parameter of lyt.getLocaleInfo, lyt.getLocaleInfoEx, and SetLocaleInfo learn.microsoft.com/en-us/windows/win32/intl/locale-information-constants
   , kbdCountry	:= "sEnCountryNm"	;
   , kbdDisplay	:= "sEnDisplayNm"	;
   , _d := 3
  ; SendInput '{LWin Down}{Space}{LWin Up}'
  local curlayout := lyt.GetCurLayout(&lytPhys, &idLang)
  local targetWin := "A" ; Active window to PostMsg to, need to be changed for '#32770' class (dialog window)
  if WinActive("ahk_class #32770") {  ; dialog window class requires sending a message to the active window via ControlGetFocus
    targetWin := ControlGetFocus(targetWin) ; Window Control with the keyboard focus, if any
  }
  ishidden_old := DetectHiddenWindows(true) ; avoid not being able to find target window if it's a tray app
  if not WinExist(targetWin) { ; no window to post message to, use shortcuts
    (dbg<_d)?'':dbgtt(_d,"✗Win to send a language changing message to! = " targetWin,🕐:=3)
    if not isSet(target) {
      SendInput('#{Space}')
    } else if target = enU { ; SendInput('{LShift down}{LAlt down}6{LShift up}{LAlt up}') ; set in system config
      SendInput('+!6')
    } else if target = ruU { ; SendInput('{LShift down}{LAlt down}7{LShift up}{LAlt up}')
      SendInput('+!7')
    }
    return
  }
  if isSet(target) {
    tryPostMsg(changeInputLang, 0, target, targetWin)
    return
  }
  if        (curlayout = enU) {
    tryPostMsg(changeInputLang, 0, ruU   , targetWin)
    ;           Msg,            w/, lParam ,Control, WinTitle
    (dbg<_d)?'':dbgTT(_d,"Current enU, switching to ruU",🕐:=3)
  } else if (curlayout = ruU) {
    tryPostMsg(changeInputLang, 0, enU   , targetWin)
    (dbg<_d)?'':dbgTT(_d,"Current ruU, switching to enU",🕐:=3)
  } else {
    (dbg<_d)?'':dbgTT(_d,"Layout neither enU nor ruU, not switching anything",🕐:=3)
  }
  ; LocaleDbg()
  DetectHiddenWindows(ishidden_old)
  }
