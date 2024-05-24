#Requires AutoHotKey 2.1-alpha.4

add_HomeRowCursor()
add_HomeRowCursor() {
  static K 	:= keyConstant , vk := K._map, sc := K._mapsc  ; various key name constants, gets vk code to avoid issues with another layout
   , s     	:= helperString ; K.▼ = vk['▼']
   , hkf   	:= keyFunc.customHotkeyFull
   , hkSend	:= keyFunc.hkSend, hkSendI := keyFunc.hkSendI

  preMod := ␠›1 ;  physical ⎇, but maybe be remapped to other key in the Registry eg ⎈›
  if s.modiMap.has(preMod) {
    pre := preMod       , blind_ex := s.modi_ahk_map[preMod] ; ⎈› → >^
  } else { ; non-modifier key needs & to be turned into a modifier
    pre := preMod ' & ' , blind_ex := ''
  } ; Blind mode avoids releasing mods if they started out in the down position (unless mod is excluded). +s::Send
  blind := '{Blind' blind_ex '}' ; with modifiers, exclude self from Blind commands

  mHomeRow := Map('g',K.␡,'h',K.␈
    ,'i',K.⏎
    ,'j',sc['▼'],'k',sc['▲'],'l',sc['◀'],';',sc['▶'] ; fail with VKs
    ,'o',sc['⇤'],'p',sc['⇥']
    ,'m',vk['🖱↓'],',',vk['🖱↑'],'.',vk['🖱←'],'/',vk['🖱→']
    ,'n',sc['⇟'],'y',sc['⇞']
    ) ;
  for k_from, k_to in mHomeRow {
    r := hkf("*",pre k_from,"") ; (with modifiers)
    hkSend(r[1], blind '{' k_to '}')
  }
}
add_⎈›PassThrough() ; print symbol when ⎈› is pressed to avoid issues when using HomeRowCursor with ␠›1
add_⎈›PassThrough() {
  static K 	:= keyConstant , vk := K._map, sc := K._mapsc  ; various key name constants, gets vk code to avoid issues with another layout
   , s     	:= helperString ; K.▼ = vk['▼']
   , hkf   	:= keyFunc.customHotkeyFull
   , hkSend	:= keyFunc.hkSend, hkSendI := keyFunc.hkSendI

  preMod := ␠›1 ;  physical ⎇, but maybe be remapped to other key in the Registry eg ⎈›
  if s.modiMap.has(preMod) {
    pre := preMod       , blind_ex := s.modi_ahk_map[preMod] ; ⎈› → >^
  } else { ; non-modifier key needs & to be turned into a modifier
    pre := preMod ' & ' , blind_ex := ''
  } ; Blind mode avoids releasing mods if they started out in the down position (unless mod is excluded). +s::Send
  blind := '{Blind' blind_ex '}' ; with modifiers, exclude self from Blind commands

  loop parse "wertasdfxcvb" { ; *with modifiers, reserve 'z' for undo n⇟
    r := hkf('*',pre A_LoopField,""), hkSend(r[1], blind '{' A_LoopField '}')
  }
}

cursorKey1(dir,mask:="") { ;;; todo
  static K 	:= keyConstant , vk := K._map, sc := K._mapsc  ; various key name constants, gets vk code to avoid issues with another layout
   , s     	:= helperString ; K.▼ = vk['▼']
   , hkf   	:= keyFunc.customHotkeyFull
   , hkSend	:= keyFunc.hkSend, hkSendI := keyFunc.hkSendI

  key_prefix 	:= ""
  key_arrow  	:= ""
  key_mask_LR	:= ""
  key_mask_in	:= ""
  if (dir = "") {
    return
  } else { ; get cursor key VK from direction name or symbol
    key_arrow := vk[dir]
  }

  mask_first := SubStr(mask, 1,1)
  mask_last  := SubStr(mask,-1,1)
  if        (mask = ""                       	                   	                   		) {
  } else if (StrCompare(mask_first,"L",cS:=1)	or mask_first = "<"	or mask_first = "‹"	) {
    key_mask_LR := "L"                       	                   	                   		;
  } else if (StrCompare(mask_first,"R",cS:=1)	or mask_last  = ">"	or mask_last  = "›"	) {
    key_mask_LR := "R"
  } else if (InStr(mask,"Shift")	or InStr(mask,"⇧")	                  	)                  	{
    key_mask_in := "Shift"      	                  	                  	                   	;
  } else if (InStr(mask,"Ctrl" )	or InStr(mask,"⎈")	or InStr(mask,"⌃")	)                  	{
    key_mask_in := "Ctrl"       	                  	                  	                   	;
  } else if (InStr(mask,"Alt"  )	or InStr(mask,"⎇")	or InStr(mask,"⌥")	)                  	{
    key_mask_in := "Alt"        	                  	                  	                   	;
  } else if (InStr(mask,"Win"  )	or InStr(mask,"⌘")	or InStr(mask,"◆")	or InStr(mask,"❖"))	{ ;
    key_mask_in := "Win"        	                  	                  	                   	;
  }
  key_mask   	:= key_mask_LR key_mask_in
  key_mask_up	:= "{" key_mask " Up}"

  is⇧ 	:= GetKeyState( "Shift","P") ; physical state
  is⎈ 	:= GetKeyState( "Ctrl" ,"P")
  is⎇ 	:= GetKeyState( "Alt"  ,"P")
  is◆ 	:= GetKeyState( "Win"  ,"P")
  is‹⇧	:= GetKeyState("LShift","P")
  is‹⎈	:= GetKeyState("LCtrl" ,"P")
  is‹⎇	:= GetKeyState("LAlt"  ,"P")
  is‹◆	:= GetKeyState("LWin"  ,"P")
  is⇧›	:= GetKeyState("RShift","P")
  is⎈›	:= GetKeyState("RCtrl" ,"P")
  is⎇›	:= GetKeyState("RAlt"  ,"P")
  is◆›	:= GetKeyState("RWin"  ,"P")

  if        is⇧ {
    key_prefix += '<+'
  } else if          is⎈      {
  } else if is⇧ and is⎈      {
  } else if               is⎇ {
  } else {
  }
    SendInput key_prefix key_arrow
}


 ; Right-most key is AppsKey, make it behave like Ctrl with arrouws
 AppsKey::Send('{AppsKey}')   	;AppsKey	AppsKey on release unless AppsKey+X combo was pressed
 ; ~AppsKey::Send('{AppsKey}')	;AppsKey	AppsKey on press
 ; (with modifiers)
 AppsKey & Down:: 	Send('{Blind}^{Down}') 	;☰↓​ ⎈self
 AppsKey & Up::   	Send('{Blind}^{Up}')   	;☰​↑ ⎈self
 AppsKey & Left:: 	Send('{Blind}^{Left}') 	;☰​← ⎈self
 AppsKey & Right::	Send('{Blind}^{Right}')	;☰​→ ⎈self
 AppsKey & vkBF:: 	^/                     	;☰/;​ ⎈self
 ; r3 := "AppsKey & "
 ; Hotkey(r3 " & " "vkBF", Send('{Blind}^/'))
 ; Hotkey(r3 "vkBF", "vkBF")
 ; Hotkey("AppsKey & vkBF", "AltTab")
 ; Hotkey("AppsKey & vkBF", Send('^/')) ; sends key right away
 ; Hotkey("AppsKey & vkBF", '{LCtrl}a') ;; need a function
   ; https://www.autohotkey.com/boards/viewtopic.php?f=94&t=120662&p=535556&hilit=Error%3A+Parameter+%232+of+Hotkey+is+invalid.#p535556

; AppsKey & vkBF::^/                         	;☰/;​ ⎈self      (with modifiers)
 ; AppsKey::Send('{AppsKey}')                	;AppsKey         	AppsKey on release unless AppsKey+X combo was pressed
 ; ; ~AppsKey::Send('{AppsKey}')             	;AppsKey         	AppsKey on press
 ; AppsKey & vk47::Send('{Blind}{Delete}')   	;⌥>g​ Delete     	(with modifiers)
 ; AppsKey & vk48::Send('{Blind}{Backspace}')	;⌥>h​ Backspace  	(with modifiers)
 ; AppsKey & vk49::Send('{Blind}{Enter}')    	;⌥>i​ Enter      	(with modifiers)
 ; AppsKey & vk4A::Send('{Blind}{Down}')     	;⌥>j​ Arrow Down 	(with modifiers)
 ; AppsKey & vk4B::Send('{Blind}{Up}')       	;⌥>k​ Arrow Up   	(with modifiers)
 ; AppsKey & vk4C::Send('{Blind}{Left}')     	;⌥>l​ Arrow Left 	(with modifiers)
 ; AppsKey & vkBA::Send('{Blind}{Right}')    	;⌥>;​ Arrow Right	(with modifiers)
 ; ; AppsKey::ToolTip "Press < or > to cycle through windows."
 ; ; AppsKey Up::{
 ;    ; ToolTip
 ;    ; Send('{AppsKey}')
 ;  ; }

