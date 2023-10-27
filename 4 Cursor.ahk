#Requires AutoHotKey 2.1-alpha.4

add_HomeRowCursor()
add_HomeRowCursor() {
  static K 	:= keyConstant , vk := K._map, sc := K._mapsc  ; various key name constants, gets vk code to avoid issues with another layout
   , s     	:= helperString ; K.▼ = vk['▼']
   , hkf   	:= keyFunc.customHotkeyFull
   , hkSend	:= keyFunc.hkSend, hkSendI := keyFunc.hkSendI

  preMod := ␠›1 ;  physical ⎇, but maybe be remapped to other key in the Registry eg ⎈›
  if preMod = '☰' { ; non-modifier key needs & to be turned into a modifier
    pre := preMod ' & ' , blind_ex := ''
  } else {
    pre := preMod       , blind_ex := s.modi_ahk_map[preMod] ; ⎈› → >^
  }
  blind := '{Blind' blind_ex '}' ; with modifiers, exclude self from Blind commands
  ; Blind mode avoids releasing the modifier keys (Alt, Ctrl, Shift, and Win) if they started out in the down position, unless the modifier is excluded. For example, the hotkey +s::Send "{Blind}abc" would send ABC rather than abc because the user is holding down Shift. lexikos.github.io/v2/docs/commands/Send.htm

  mHomeRow := Map(
     'g',K.␡
    ,'i',K.⏎
    ,'h',K.␈
    ,'j',sc['▼'],'k',sc['▲'],'l',sc['◀'],';',sc['▶'] ; fail with VKs
    ,'o',sc['⇤'],'p',sc['⇥']
    ,'m',vk['🖱↓'],',',vk['🖱↑'],'.',vk['🖱←'],'/',vk['🖱→']
    )
  for k_from, k_to in mHomeRow {
    r := hkf("*",pre k_from,"") ; (with modifiers)
    hkSend(r[1], blind '{' k_to '}')
  }
}
