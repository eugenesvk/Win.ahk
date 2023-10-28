#Requires AutoHotKey 2.1-alpha.4

; User RShift+WSAD as an alternative cursor
  ; Blind mode avoids releasing the modifier keys (Alt, Ctrl, Shift, and Win) if they started out in the down position, unless the modifier is excluded. For example, the hotkey +s::Send "{Blind}abc" would send ABC rather than abc because the user is holding down Shift. lexikos.github.io/v2/docs/commands/Send.htm
add_HomeRowCursor()
add_HomeRowCursor() { ; Requires setting a precisely named function (no vars in names) (functions can be 1-liners with fat arrow syntax =>)
  static vk	:= keyConstant._map, sc := keyConstant._mapsc  ; various key name constants, gets vk code to avoid issues with another layout
   , s     	:= helperString
   , hkf   	:= keyFunc.customHotkeyFull

  pre := '⎈›' ; ␠›1 ; can't use vars in function names, so hk⎈›⅋g would need to be manually updated
  blind := '{Blind' s.modi_ahk_map[pre] '}' ; ⎈› → >^, exclude self from Blind commands

  for key in StrSplit("jkl;ihgm,op./") { ;;;; don't need & for regular modifiers, only for ☰ key, make it conditional
    r := hkf("",pre " & " . key,""), Hotkey(r[1],%r[2]%)
  } ; ↓ physical ⎇, but maybe be remapped to other key in the Registry
  mHomeRow := Map(
     'g'	, 'Delete'    	;g​ ␡	(with modifiers)
    ,'h'	, 'Backspace' 	;h​ ␈	(with modifiers)
    ,'i'	, 'Enter'     	;i​ ⏎	(with modifiers)
    ,'j'	, 'Down'      	;j​ ▼	(with modifiers)
    ,'k'	, 'Up'        	;k​ ▲	(with modifiers)
    ,'l'	, 'Left'      	;l​ ◀	(with modifiers)
    ,';'	, 'Right'     	;​ ▶ 	(with modifiers)
    ,'m'	, 'WheelDown' 	;​ 🖱↓	(with modifiers)
    ,','	, 'WheelUp'   	;​ 🖱↑	(with modifiers)
    ,'.'	, 'WheelLeft' 	;​ 🖱←	(with modifiers)
    ,'/'	, 'WheelRight'	;​ 🖱→	(with modifiers)
    ,'o'	, 'Home'      	;​ ⇤ 	(with modifiers)
    ,'p'	, 'End'       	;​ ⇥ 	(with modifiers)
    )

  hk⎈›⅋g(ThisHotkey) => Send(blind '}{Delete}')    	;g​ ␡	(with modifiers)
  hk⎈›⅋h(ThisHotkey) => Send(blind '}{Backspace}') 	;h​ ␈	(with modifiers)
  hk⎈›⅋i(ThisHotkey) => Send(blind '}{Enter}')     	;i​ ⏎	(with modifiers)
  hk⎈›⅋j(ThisHotkey) => Send(blind '}{Down}')      	;j​ ▼	(with modifiers)
  hk⎈›⅋k(ThisHotkey) => Send(blind '}{Up}')        	;k​ ▲	(with modifiers)
  hk⎈›⅋l(ThisHotkey) => Send(blind '}{Left}')      	;l​ ◀	(with modifiers)
  hk⎈›⅋︔(ThisHotkey) => Send(blind '}{Right}')     	;​ ▶ 	(with modifiers)
  hk⎈›⅋m(ThisHotkey) => Send(blind '}{WheelDown}') 	;​ 🖱↓	(with modifiers)
  hk⎈›⅋⸴(ThisHotkey) => Send(blind '}{WheelUp}')   	;​ 🖱↑	(with modifiers)
  hk⎈›⅋．(ThisHotkey) => Send(blind '}{WheelLeft}') 	;​ 🖱←	(with modifiers)
  hk⎈›⅋⁄(ThisHotkey) => Send(blind '}{WheelRight}')	;​ 🖱→	(with modifiers)
  hk⎈›⅋o(ThisHotkey) => Send(blind '}{Home}')      	;​ ⇤ 	(with modifiers)
  hk⎈›⅋p(ThisHotkey) => Send(blind '}{End}')       	;​ ⇥ 	(with modifiers)
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

; Old direct remap
 ;                                           	;physical alt, remapped to Ctrl in SharpKeys
 ; RCtrl & vk47::Send('{Blind>^}{Delete}')   	;⌥>g​ Delete     	(with modifiers)
 ; RCtrl & vk48::Send('{Blind>^}{Backspace}')	;⌥>h​ Backspace  	(with modifiers)
 ; RCtrl & vk49::Send('{Blind>^}{Enter}')    	;⌥>i​ Enter      	(with modifiers)
 ; RCtrl & vk4A::Send('{Blind>^}{Down}')     	;⌥>j​ Arrow Down 	(with modifiers)
 ; RCtrl & vk4B::Send('{Blind>^}{Up}')       	;⌥>k​ Arrow Up   	(with modifiers)
 ; RCtrl & vk4C::Send('{Blind>^}{Left}')     	;⌥>l​ Arrow Left 	(with modifiers)
 ; RCtrl & vkBA::Send('{Blind>^}{Right}')    	;⌥>;​ Arrow Right	(with modifiers)
