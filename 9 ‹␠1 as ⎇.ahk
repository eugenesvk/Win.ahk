#Requires AutoHotKey 2.1-alpha.4
;LControl & Tab::      	myAltTab()	;^⭾​	vk09 ⟶ Ctrl+Tab AppSwitcher, defined in '9 ‹␠1 as ⎇' to allow flexible first key from space
;LCtrl & Tab::AltTab   	; ⎈⭾​  ⟶ Switch to Next     window (due to AltTab can't use Send) ;bugs if Language switcher is on for short taps, rebind directly in the Ctrl function
;LCtrl & q::ShiftAltTab	;  ⌥​q​                                                    	 ⟶ Switch to Previous window (← in the switcher)
;^Tab::                	SendInput '{Ctrl Down}{Tab}{Ctrl Up}'                      	;^⭾​ 	vk09 ⟶ Ctrl+Tab Restore
;^+Tab::               	SendInput '{Ctrl Down}{Shift Down}{Tab}{Ctrl Up}{Shift Up}'	;⇧^⭾​	vk09 ⟶ Ctrl+Shift+Tab Restore
; AppsKey & vkBF::^vkBF ;

#include %A_scriptDir%\gVar\isKey.ahk	; track key status programmatically

add_‹␠1_as_⎇()
add_‹␠1_as_⎇() { ; ‹⎇ remapped to ‹⎈ via SharpKeys
  static K 	:= keyConstant , vk := K._map, sc := K._mapsc  ; various key name constants, gets vk code to avoid issues with another layout
   , s     	:= helperString ; K.▼ = vk['▼']
   , hkf   	:= keyFunc.customHotkeyFull ; → [key_combo <^vk09, key_combo_FNm hk‹⎈⭾]
   , hkSend	:= keyFunc.hkSend, hkSendI := keyFunc.hkSendI

  preMod := ‹␠1 ;  physical ⎇, but maybe be remapped to other key in the Registry eg ⎈
  if preMod = '☰' { ; non-modifier key needs & to be turned into a modifier
    pre := preMod ' & ' , blind✗ := ''
  } else {
    pre := preMod       , blind✗ := s.modi_ahk_map[preMod] ; ‹⎈ → <^
  }
  blind := '{Blind' blind✗ '}' ; with mods, exclude self from Blind commands (avoids releasing mods if they started out in the down position, unless the modifier is excluded: +s::Send "{Blind}a" → ‘A’ not ‘a’ because ⇧ is held and isn't released by ‘Blind’

  ;    (pre  ,key_combo ,pos,kT:='vk',lng:='en') {
  ; r := hkf( 	,pre '1' ,)     	, hkSend(r[1], blind s.key→send('⎇1'))
  ; r := hkf( 	,pre '2' ,)     	, hkSend(r[1], blind s.key→send('⎇2'))
  r := hkf(   	,pre 'F4' ,)    	, hkSend(r[1], s.key→send('  ⎇	f4'))
  r := hkf(   	,"‹⇧‹◆ ▼",,'sc')	, hkSend(r[1], s.key→send('⇧⎈ 	▼','sc')) ; arrows require sc to work
  r := hkf(   	,"‹⇧‹◆ ▲",,'sc')	, hkSend(r[1], s.key→send('⇧⎈ 	▲','sc'))
  r := hkf(   	,"‹⇧‹◆ ⎋",)     	, hkSend(r[1], s.key→send('⇧⎈ 	⎋')) ; Task manager
  r := hkf('*'	,"   ◆ ▼",,'sc')	, hkSend(r[1], s.key→send(' ⎈ 	▼','sc'))
  r := hkf('*'	,"   ◆ ▲",,'sc')	, hkSend(r[1], s.key→send(' ⎈ 	▲','sc'))
  r := hkf('*'	,"   ◆ ◀",,'sc')	, hkSend(r[1], s.key→send(' ⎈ 	◀','sc'))
  r := hkf('*'	,"   ◆ ▶",,'sc')	, hkSend(r[1], s.key→send(' ⎈ 	▶','sc'))

  ; AltTab
  ; r := hkf(	,pre ⅋ 'Tab' ,)	, HotKey('LControl & Tab',hkmyAltTab) ; r[1] = vkA2 & vk09  bugs, doesn't close app switcher on release
  ; r := hkf(	,pre ⅋ 'Tab' ,)	, HotKey(r[1], hkmyAltTab) ; no bug, it depends on the blind mode in app switcher
  r := hkf(˜ 	,pre ⅋ 'Tab' ,)	, HotKey(r[1], hkmyAltTab) ;‹⎈⭾​  no bug, it depends on the blind mode in app switcher
  ; dbgtt(0,pre ' r[1]=' r[1],3) ;‹⎈ ~vkA2 & vk09
}

; #MaxThreadsPerHotkey 1
~*LCtrl up::on‹⎈↑()
~*RCtrl up::on⎈›↑()
 *LControl::on‹⎈↓() ; name Control to match ??? previously registered key
 *RControl::on⎈›↓()
on‹⎈↓() { ; keys are named Control, so using LCtrl wouldn't match
  static K	:= keyConstant, vk:=K._map, vkr:=K._mapr, vkl:=K._maplng, vkrl:=K._maprlng, sc:=K._mapsc  ; various key name constants, gets vk code to avoid issues with another layout
   , s    	:= helperString
   ,_d := 1, id:=5
   ,kk := '‹⎈'
   ,kvk := s.key→ahk(kk)
  SetKeyDelay(-1)
  SendEvent("{Blind}{LCtrl down}")
  if (dbg>=_d) {
    is↓H := (GetKeyState(kvk,'P')?'↓':'')
    is↓L := (GetKeyState(kvk    )?'↓':'')
    ksym := is↓H is↓L kk
    log(0,ksym)
    (dbg<_d+1)?'':(dbgtt(0,ksym,'∞',id,0,A_ScreenHeight*.9))
  }
  KeyWait("LCtrl")
}
on⎈›↓() {
  static K	:= keyConstant, vk:=K._map, vkr:=K._mapr, vkl:=K._maplng, vkrl:=K._maprlng, sc:=K._mapsc  ; various key name constants, gets vk code to avoid issues with another layout
   , s    	:= helperString
   ,_d := 1, id:=6
   ,kk := '⎈›'
   ,kvk := s.key→ahk(kk)
  SetKeyDelay(-1)
  SendEvent("{Blind}{RCtrl down}")
  if (dbg>=_d) {
    is↓H := (GetKeyState(kvk,'P')?'↓':'')
    is↓L := (GetKeyState(kvk    )?'↓':'')
    ksym := is↓H is↓L kk
    log(0,ksym)
    (dbg<_d+1)?'':(dbgtt(0,ksym,'∞',id,50,A_ScreenHeight*.9))
  }
  KeyWait("RCtrl")
}
on‹⎈↑() {
  static _d := 1
   ,anyMod := keyFunc.anyMod
   ,min_t := 100
  (dbg<_d)?'':(🕐1 := A_TickCount)
  SetKeyDelay(-1) ; no delay
  SendEvent("{Blind}{LCtrl up}")
  (dbg<_d+1)?'':(dbgtt(0,'',,3),dbgtt(0,'',,4),dbgtt(0,'',,5))
  dbgtxt := '↑‹⎈'
  if   A_PriorHotkey = "LControl & Tab" ; mapped to hkmyAltTab and sends ↓⎇
    || A_PriorHotkey = "LControl & q"   ; mapped at '5 App Switcher' and sends ↓⎇
    || A_PriorHotkey = "LCtrl    & Tab"
    || A_PriorHotkey = "LCtrl    & q"
    || isKey↓.⎇↹
    || isKey↓.⎇q {
    if GetKeyState("Shift") {
      SendEvent("{LShift up}{LAlt up}") , (dbg<_d)?'':(dbgtxt .= ' ↑‹⇧‹⎇')
    } else {
      SendEvent(           "{LAlt up}") , (dbg<_d)?'':(dbgtxt .= '   ↑‹⎇')
    }
    (dbg<_d)?'':(dbgtxt .= ' (is↓.⎇↹' isKey↓.⎇↹ ' is↓.⎇q' isKey↓.⎇q ')')
    isKey↓.⎇↹ := 0, isKey↓.⎇q := 0 ; reset
  }
  if A_PriorHotkey = ("*" A_PriorKey)
    && A_TimeSincePriorHotkey<min_t
    && !anyMod('p') {
    LayoutSwitch(enU) , (dbg<_d+1)?'':(dbgtxt .= 'LayoutSwitchEn')
    }
  (dbg<_d)?'':(dbgtxt .= ' prek‘' A_PriorKey '’ hk‘' A_PriorHotkey '’')
  (dbg<_d)?'':(🕐2 := A_TickCount)
  (dbg<_d)?'':(OutputDebug(dbgtxt format(" 🕐Δ{:.3f}",🕐2-🕐1) ' ' 🕐2 ' preHK🕐' A_TimeSincePriorHotkey ' @' A_ThisFunc))
}
on⎈›↑() {
  static _d := 1
   ,anyMod := keyFunc.anyMod
   ,min_t := 100
  (dbg<_d)?'':(🕐1 := A_TickCount)
  SetKeyDelay(-1) ; no delay
  SendEvent("{Blind}{RCtrl up}")
  (dbg<_d+1)?'':(dbgtt(0,'',,6))
  dbgtxt := '↑⎈›'
  isTap := (A_PriorHotkey = ("*" A_PriorKey)) ;RAlt = *RAlt
  isQuick := (A_TimeSincePriorHotkey<min_t)
  if isTap
    && isQuick
    && !anyMod('p') {
    LayoutSwitch(ruU) , (dbg<_d+1)?'':(dbgtxt .= 'LayoutSwitchRu')
    ; Send "^{vkF2}" ; For Japanese, send ^{vkF2} to ensure Hiragana mode after switching. You can also send !{vkF1} for Katakana. If you use other languages, this statement can be safely omitted.
  }
  (dbg<_d)?'':(dbgtxt .= ' pre‘' A_PriorKey '’ hk‘' A_PriorHotkey '’ hk🕐' A_TimeSincePriorHotkey)
  ; (dbg<_d+1)?'':(dbgtt(0,'A_PriorKey`t' A_PriorKey ' `nA_PriorHotkey`t' A_PriorHotkey,3))
  (dbg<_d)?'':(🕐2 := A_TickCount)
  (dbg<_d)?'':(OutputDebug(dbgtxt format(" 🕐Δ{:.3f}",🕐2-🕐1) ' ' 🕐2 ' @' A_ThisFunc))
}
