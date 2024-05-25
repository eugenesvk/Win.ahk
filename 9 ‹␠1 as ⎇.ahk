#Requires AutoHotKey 2.1-alpha.4
;LControl & Tab::      	myAltTab()	;^⭾​	vk09 ⟶ Ctrl+Tab AppSwitcher, defined in '9 ‹␠1 as ⎇' to allow flexible first key from space
;LCtrl & Tab::AltTab   	; ⎈⭾​  ⟶ Switch to Next     window (due to AltTab can't use Send) ;bugs if Language switcher is on for short taps, rebind directly in the Ctrl function
;LCtrl & q::ShiftAltTab	;  ⌥​q​                                                    	 ⟶ Switch to Previous window (← in the switcher)
;^Tab::                	SendInput '{Ctrl Down}{Tab}{Ctrl Up}'                      	;^⭾​ 	vk09 ⟶ Ctrl+Tab Restore
;^+Tab::               	SendInput '{Ctrl Down}{Shift Down}{Tab}{Ctrl Up}{Shift Up}'	;⇧^⭾​	vk09 ⟶ Ctrl+Shift+Tab Restore
; AppsKey & vkBF::^vkBF ;

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
  r := hkf(	,pre ⅋ 'Tab' ,)	, HotKey('LControl & Tab',hkmyAltTab) ; r[1] = vkA2 & vk09  bugs, doesn't close app switcher on release
}
