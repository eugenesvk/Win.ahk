#Requires AutoHotKey 2.1-alpha.4

add_Numpad()
add_Numpad() {
  static K 	:= keyConstant , vk := K._map, sc := K._mapsc  ; various key name constants, gets vk code to avoid issues with another layout
   , s     	:= helperString ; K.▼ = vk['▼']
   , hkf   	:= keyFunc.customHotkeyFull
   , hkSend	:= keyFunc.hkSend, hkSendI := keyFunc.hkSendI

  ; ————— ‹🔢
  preMod := ␠›1 ;  physical ⎇, but may be remapped to other key in the Registry eg ⎈›
  if preMod = '☰' { ; non-modifier key needs & to be turned into a modifier
    pre := preMod ' & ' , blind_ex := ''
  } else {
    pre := preMod       , blind_ex := s.modi_ahk_map[preMod] ; ⎈› → >^
  }
  blind := '{Blind' blind_ex '}' ; with modifiers, exclude self from Blind commands
  ; Blind mode avoids releasing the modifier keys (Alt, Ctrl, Shift, and Win) if they started out in the down position, unless the modifier is excluded. For example, the hotkey +s::Send "{Blind}abc" would send ABC rather than abc because the user is holding down Shift. lexikos.github.io/v2/docs/commands/Send.htm

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


  ; ————— 🔢›
  preMod := '⭾' ;  physical ⎇, but may be remapped to other key in the Registry eg ⎈›
  if preMod = '⭾' { ; non-modifier key needs & to be turned into a modifier
    pre := preMod ' & ' , blind_ex := ''
  } else {
    pre := preMod       , blind_ex := s.modi_ahk_map[preMod] ; ⎈› → >^
  }
  blind := '{Blind' blind_ex '}' ; with modifiers, exclude self from Blind commands
  ; Blind mode avoids releasing the modifier keys (Alt, Ctrl, Shift, and Win) if they started out in the down position, unless the modifier is excluded. For example, the hotkey +s::Send "{Blind}abc" would send ABC rather than abc because the user is holding down Shift. lexikos.github.io/v2/docs/commands/Send.htm

  lbl🔢› := "
    ( Join ` LTrim ; spaces are removed, so both lists must match in length, to disable remove a key/symbol pair
    7890
    yuiop
     jkl;
    nm,./␠
    )"
  sym🔢› := "
    ( Join ` LTrim
    / *-+
    =123-
     456+
    ⏎789.0
    )"
  lbl🔢› := StrReplace(lbl🔢›, ' ','')
  sym🔢› := StrReplace(sym🔢›, ' ','')

  for i,lbl in StrSplit(lbl🔢›) {
    r := hkf('',pre lbl,""), hkSend(r[1], blind '{' vk['🔢' SubStr(sym🔢›,i,1)] '}')
  } ; ␈ isn't a numpad key, so map h→␈ manually
    r := hkf('',pre 'h',""), hkSend(r[1], blind '{' vk['␈'] '}')

  sym🔢›mod := Map(1,'0',2,'.',3,'/') ; modifier keys require special & syntax
  for lbl, sym in sym🔢›mod {
    r := hkf('','⭾ & ' ␠›%lbl%,''), hkSend(r[1], blind '{' vk['🔢' sym] '}')
  }
}
