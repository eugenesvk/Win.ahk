#Requires AutoHotKey 2.1-alpha.4

add_Numpad()
add_Numpad() {
  static K 	:= keyConstant , vk := K._map, sc := K._mapsc  ; various key name constants, gets vk code to avoid issues with another layout
   , s     	:= helperString ; K.▼ = vk['▼']
   , hkf   	:= keyFunc.customHotkeyFull
   , hkSend	:= keyFunc.hkSend, hkSendI := keyFunc.hkSendI

  ; ————— ‹🔢
  /*
  preMod := ␠›1 ;  physical ⎇, but may be remapped to other key in the Registry eg ⎈›
  if s.modiMap.has(preMod) {
    pre := preMod       , blind_ex := s.modi_ahk_map[preMod] ; ⎈› → >^
  } else { ; non-modifier key needs & to be turned into a modifier
    pre := preMod ' & ' , blind_ex := ''
  } ; Blind mode avoids releasing mods if they started out in the down position (unless mod is excluded). +s::Send "{Blind}abc" → ABC, not abc because the user is holding ⇧
  blind := '{Blind' blind_ex '}' ; with mods, exclude self from Blind commands

  lbl‹🔢 := "
    ( Join ` LTrim ; spaces are removed, so both lists must match in length, to disable remove a key/symbol pair
    12345
    qwert
    asdf
    zxcvb
    )"
  sym‹🔢 := "
    ( Join ` LTrim
    //*-+
    =123+
    0456
    .789⏎
    )"
  lbl‹🔢 := StrReplace(lbl‹🔢, ' ','')
  sym‹🔢 := StrReplace(sym‹🔢, ' ','')

  for i,lbl in StrSplit(lbl‹🔢) { ; 6 q
    r := hkf("*",pre lbl,"") ; [key_combo_out,key_combo_FNm] *>^vk51 hk⎈›q    vk[🔢=]→vkBB
    hkSend(r[1], blind '{' vk['🔢' SubStr(sym‹🔢,i,1)] '}') ; *>^vk51 :: Send('blind{vkBB}')
  }
    r := hkf("*",pre 'b',""), hkSend(r[1], blind '{' sc['🔢⏎'] '}') ; g_key_to_sc, see constKey.ahk
  */

  ; ————— 🔢›
  preMod := '⇪' ;  physical ⎇, but may be remapped to other key in the Registry eg ⎈›
  if s.modiMap.has(preMod) {
    pre := preMod       , blind_ex := s.modi_ahk_map[preMod] ; ⎈› → >^
  } else { ; non-modifier key needs & to be turned into a modifier
    pre := preMod ' & ' , blind_ex := ''
  }
  ; dbgtt(0,pre '`t' vk['⎈›'] ' ' vk['‹⎈'] ' ' s.key→ahk('‹⎈') ' ' s.modi_ahk_map.has('⇪'),t:=5)
  blind := '{Blind' blind_ex '}' ; with modifiers, exclude self from Blind commands

  lbl🔢› := "
    ( Join ` LTrim ; spaces are removed, so both lists must match in length, to disable remove a key/symbol pair
    7 8
    yuiop
     jkl;
    bnm,./␠
    )"
  sym🔢› := "
    ( Join ` LTrim
    / *
    -123+
     456=
    ⏎.789.0
    )"
  lbl🔢› := StrReplace(lbl🔢›, ' ','')
  sym🔢› := StrReplace(sym🔢›, ' ','')

  for i,lbl in StrSplit(lbl🔢›) {
    r := hkf('',pre lbl,""), hkSend(r[1], blind '{' vk['🔢' SubStr(sym🔢›,i,1)] '}')
  } ; ␈ not a numpad keys, so map h→␈ manually (same for others)
    r := hkf('',pre 'g',""), hkSend(r[1], blind  '{' vk['␡'] '}')
    r := hkf('',pre 'h',""), hkSend(r[1], blind  '{' vk['␈'] '}')
    r := hkf('',pre '9',""), hkSend(r[1], blind '+{' vk['9'] '}')
    r := hkf('',pre '0',""), hkSend(r[1], blind '+{' vk['0'] '}')

  sym🔢›mod := Map(1,'.',2,'.',3,'/') ; modifier keys require special & syntax
  for lbl, sym in sym🔢›mod {
    r := hkf('',pre ' ' ␠›%lbl%,''), hkSend(r[1], blind '{' vk['🔢' sym] '}')
  }
}
