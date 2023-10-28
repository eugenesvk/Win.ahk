#Requires AutoHotKey 2.1-alpha.4
#Include <Array>
add_Numpad()
add_Numpad() {
  static K 	:= keyConstant , vk := K._map, sc := K._mapsc  ; various key name constants, gets vk code to avoid issues with another layout
   , s     	:= helperString ; K.▼ = vk['▼']
   , hkf   	:= keyFunc.customHotkeyFull
   , hkSend	:= keyFunc.hkSend, hkSendI := keyFunc.hkSendI

  ; ————— ‹🔢
  preMod := ␠›1 ;  physical ⎇, but maybe be remapped to other key in the Registry eg ⎈›
  if preMod = '☰' { ; non-modifier key needs & to be turned into a modifier
    pre := preMod ' & ' , blind_ex := ''
  } else {
    pre := preMod       , blind_ex := s.modi_ahk_map[preMod] ; ⎈› → >^
  }
  blind := '{Blind' blind_ex '}' ; with modifiers, exclude self from Blind commands
  ; Blind mode avoids releasing the modifier keys (Alt, Ctrl, Shift, and Win) if they started out in the down position, unless the modifier is excluded. For example, the hotkey +s::Send "{Blind}abc" would send ABC rather than abc because the user is holding down Shift. lexikos.github.io/v2/docs/commands/Send.htm

  lbl‹🔢 := "
    ( Join ` LTrim
    12345
    qwert
    asdf
    zxcvb
    )"
  lbl‹🔢 := StrReplace(lbl‹🔢, ' ','')
  sym‹🔢 := "
    ( Join ` LTrim
    //*-+
    =123+
    0456
    .789⏎
    )"
  sym‹🔢 := StrReplace(sym‹🔢, ' ','')
  for i,lbl in StrSplit(lbl‹🔢) {
    r := hkf("*",pre lbl,"")
    hkSend(r[1], blind '{' vk['🔢' SubStr(sym‹🔢,i,1)] '}')
  }
    r := hkf("*",pre 'b',""), hkSend(r[1], blind '{' sc['🔢⏎'] '}') ; g_key_to_sc, see constKey.ahk


  ; ————— 🔢›
  preMod := '⭾' ;  physical ⎇, but maybe be remapped to other key in the Registry eg ⎈›
  if preMod = '⭾' { ; non-modifier key needs & to be turned into a modifier
    pre := preMod ' & ' , blind_ex := ''
  } else {
    pre := preMod       , blind_ex := s.modi_ahk_map[preMod] ; ⎈› → >^
  }
  blind := '{Blind' blind_ex '}' ; with modifiers, exclude self from Blind commands
  ; Blind mode avoids releasing the modifier keys (Alt, Ctrl, Shift, and Win) if they started out in the down position, unless the modifier is excluded. For example, the hotkey +s::Send "{Blind}abc" would send ABC rather than abc because the user is holding down Shift. lexikos.github.io/v2/docs/commands/Send.htm

  lbl🔢› := "
    ( Join ` LTrim
    7890
    yuiop
    hjkl;
    nm,./␠
    )"
  lbl🔢› := StrReplace(lbl🔢›, ' ','')
  sym🔢› := "
    ( Join ` LTrim
    //*-+
    =123+
    0456
    .789⏎0
    )"
  sym🔢› := StrReplace(sym🔢›, ' ','')
  for i,lbl in StrSplit(lbl🔢›) {
    r := hkf('',pre lbl,"")
    hkSend(r[1], blind '{' vk['🔢' SubStr(sym🔢›,i,1)] '}')
  }
  ; sym🔢›mod := Map(1,'0',2,'1',3,'1')
  ; for lbl, sym in sym🔢›mod {
    ; r := hkf('','⭾ & ' ␠›%lbl%,''), hkSend(r[1], blind '{' vk['🔢' sym] '}')
  ; }
  ; hk⭾⅋⎈›(	ThisHotkey) => SendInput('{Blind}{Numpad0}')  	;⭾⌥›​	🔢₀
  ; hk⭾⅋⎇›(	ThisHotkey) => SendInput('{Blind}{NumpadDot}')	;⭾⭾​ 	🔢．
  ; hk⭾⅋☰( 	ThisHotkey) => SendInput('{Blind}{NumpadDot}')	;⭾⎈›​	🔢．
  ; ↓ can't user vars in function names
  ; hk⭾⅋␠›1(	ThisHotkey) => SendInput('{Blind}{Numpad0}')  	;⭾⌥›​	🔢₀
  ; hk⭾⅋␠›2(	ThisHotkey) => SendInput('{Blind}{NumpadDot}')	;⭾⭾​ 	🔢．
  ; hk⭾⅋␠›3(	ThisHotkey) => SendInput('{Blind}{NumpadDot}')	;⭾⎈›​	🔢．

}

setNumPad_func() { ; Requires setting a precisely named function (no vars in names) (functions can be 1-liners with fat arrow syntax =>)
  pre := '⭾' ; can't use vars in function names
  loop parse "" { ; ⌥☰ Right numpad, Left prefix key
    ; r := hkf("","⭾ & " . A_LoopField,"") ;, Hotkey(r[1],%r[2]%)
  }
  ; hk⭾⅋7(	ThisHotkey) => SendInput('{Blind}{NumpadDiv}')  	;⭾7​	🔢⁄
  ; hk⭾⅋8(	ThisHotkey) => SendInput('{Blind}{NumpadMult}') 	;⭾8​	🔢∗
  ; hk⭾⅋9(	ThisHotkey) => SendInput('{Blind}{NumpadSub}')  	;⭾9​	🔢₋
  ; hk⭾⅋0(	ThisHotkey) => SendInput('{Blind}{NumpadAdd}')  	;⭾0​	🔢₊
  ; hk⭾⅋y(	ThisHotkey) => SendInput('{Blind}{=}')          	;⭾y​	🔢₌
  ; hk⭾⅋u(	ThisHotkey) => SendInput('{Blind}{Numpad1}')    	;⭾u​	🔢₁
  ; hk⭾⅋i(	ThisHotkey) => SendInput('{Blind}{Numpad2}')    	;⭾i​	🔢₂
  ; hk⭾⅋o(	ThisHotkey) => SendInput('{Blind}{Numpad3}')    	;⭾o​	🔢₃
  ; hk⭾⅋p(	ThisHotkey) => SendInput('{Blind}{−}')          	;⭾p​	−
  ; hk⭾⅋h(	ThisHotkey) => SendInput('{Blind}{BackSpace}')  	;⭾h​	␈
  ; hk⭾⅋j(	ThisHotkey) => SendInput('{Blind}{Numpad4}')    	;⭾j​	🔢₄
  ; hk⭾⅋k(	ThisHotkey) => SendInput('{Blind}{Numpad5}')    	;⭾k​	🔢₅
  ; hk⭾⅋l(	ThisHotkey) => SendInput('{Blind}{Numpad6}')    	;⭾l​	🔢₆
  ; hk⭾⅋︔(	ThisHotkey) => SendInput('{Blind}{NumpadAdd}')  	;⭾;​	🔢₊
  ; hk⭾⅋n(	ThisHotkey) => SendInput('{Blind}{NumpadEnter}')	;⭾n​	🔢Enter
  ; hk⭾⅋m(	ThisHotkey) => SendInput('{Blind}{Numpad7}')    	;⭾m​	🔢₇
  ; hk⭾⅋⸴(	ThisHotkey) => SendInput('{Blind}{Numpad8}')    	;⭾,​	🔢₈
  ; hk⭾⅋．(	ThisHotkey) => SendInput('{Blind}{Numpad9}')    	;⭾.​	🔢₉
  ; hk⭾⅋⁄(	ThisHotkey) => SendInput('{Blind}{NumpadDot}')  	;⭾/​	🔢．
  ; hk⭾⅋␠(	ThisHotkey) => SendInput('{Blind}{Numpad0}')    	;⭾␠​	🔢₀
}


; setNumPad2_func() ;
setNumPad2_func() { ; Requires setting a precisely named function (no vars in names) (functions can be 1-liners with fat arrow syntax =>)
  static k	:= keyConstant._map ; various key name constants, gets vk code to avoid issues with another layout
   , s    	:= helperString
   , hkf  	:= keyFunc.customHotkeyFull

  pre := '⎈›' ; ␠›1 ; can't use vars in function names, so hk⎈›⅋1 would need to be manually updated
  blind := '{Blind' s.modi_ahk_map[pre] '}' ; ⎈› → >^, exclude self from Blind commands
  loop parse "12345qwertasdfzxcvb" { ; Left numpad, Right prefix key
    r := hkf("",pre . A_LoopField,""), Hotkey(r[1],%r[2]%)
    ; r := hkf("",pre " & " . A_LoopField,""), Hotkey(r[1],%r[2]%) ; ☰ would require & and ⅋ in function name
  }                                                    	;↓ physical ⎇, but maybe be remapped to other key in the Registry
  hk⎈›1(ThisHotkey) => SendInput(blind '{NumpadDiv}')  	;⎇›1​	🔢⁄
  hk⎈›2(ThisHotkey) => SendInput(blind '{NumpadDiv}')  	;⎇›2​	🔢⁄
  hk⎈›3(ThisHotkey) => SendInput(blind '{NumpadMult}') 	;⎇›3​	🔢∗
  hk⎈›4(ThisHotkey) => SendInput(blind '{NumpadSub}')  	;⎇›4​	🔢₋
  hk⎈›5(ThisHotkey) => SendInput(blind '{NumpadAdd}')  	;⎇›5​	🔢₊
  hk⎈›q(ThisHotkey) => SendInput(blind '{=}')          	;⎇›q​	🔢₌
  hk⎈›w(ThisHotkey) => SendInput(blind '{Numpad1}')    	;⎇›w​	🔢₁
  hk⎈›e(ThisHotkey) => SendInput(blind '{Numpad2}')    	;⎇›e​	🔢₂
  hk⎈›r(ThisHotkey) => SendInput(blind '{Numpad3}')    	;⎇›r​	🔢₃
  hk⎈›t(ThisHotkey) => SendInput(blind '{NumpadAdd}')  	;⎇›t​	🔢₊
  hk⎈›a(ThisHotkey) => SendInput(blind '{Numpad0}')    	;⎇›a​	🔢₀
  hk⎈›s(ThisHotkey) => SendInput(blind '{Numpad4}')    	;⎇›s​	🔢₄
  hk⎈›d(ThisHotkey) => SendInput(blind '{Numpad5}')    	;⎇›d​	🔢₅
  hk⎈›f(ThisHotkey) => SendInput(blind '{Numpad6}')    	;⎇›f​	🔢₆
  hk⎈›z(ThisHotkey) => SendInput(blind '{NumpadDot}')  	;⎇›z​	🔢．
  hk⎈›x(ThisHotkey) => SendInput(blind '{Numpad7}')    	;⎇›x​	🔢₇
  hk⎈›c(ThisHotkey) => SendInput(blind '{Numpad8}')    	;⎇›c​	🔢₈
  hk⎈›v(ThisHotkey) => SendInput(blind '{Numpad9}')    	;⎇›v​	🔢₉
  hk⎈›b(ThisHotkey) => SendInput(blind '{NumpadEnter}')	;⎇›b​	🔢Enter

  pre := '⭾' ; can't use vars in function names
  loop parse "7890yuiophjkl;nm,./␠" { ; ⌥☰ Right numpad, Left prefix key
    r := hkf("","⭾ & " . A_LoopField,""), Hotkey(r[1],%r[2]%)
  }
    r := hkf("","⭾ & ⎈›",""), Hotkey(r[1],%r[2]%) ; ␠›1 can use vars here, but not in function names
    r := hkf('','⭾ & ⎇›',''), Hotkey(r[1],%r[2]%) ; ␠›2
    r := hkf('','⭾ & ☰'  ,''), Hotkey(r[1],%r[2]%) ; ␠›3
  hk⭾⅋7( 	ThisHotkey) => SendInput('{Blind}{NumpadDiv}')  	;⭾7​ 	🔢⁄
  hk⭾⅋8( 	ThisHotkey) => SendInput('{Blind}{NumpadMult}') 	;⭾8​ 	🔢∗
  hk⭾⅋9( 	ThisHotkey) => SendInput('{Blind}{NumpadSub}')  	;⭾9​ 	🔢₋
  hk⭾⅋0( 	ThisHotkey) => SendInput('{Blind}{NumpadAdd}')  	;⭾0​ 	🔢₊
  hk⭾⅋y( 	ThisHotkey) => SendInput('{Blind}{=}')          	;⭾y​ 	🔢₌
  hk⭾⅋u( 	ThisHotkey) => SendInput('{Blind}{Numpad1}')    	;⭾u​ 	🔢₁
  hk⭾⅋i( 	ThisHotkey) => SendInput('{Blind}{Numpad2}')    	;⭾i​ 	🔢₂
  hk⭾⅋o( 	ThisHotkey) => SendInput('{Blind}{Numpad3}')    	;⭾o​ 	🔢₃
  hk⭾⅋p( 	ThisHotkey) => SendInput('{Blind}{−}')          	;⭾p​ 	−
  hk⭾⅋h( 	ThisHotkey) => SendInput('{Blind}{BackSpace}')  	;⭾h​ 	␈
  hk⭾⅋j( 	ThisHotkey) => SendInput('{Blind}{Numpad4}')    	;⭾j​ 	🔢₄
  hk⭾⅋k( 	ThisHotkey) => SendInput('{Blind}{Numpad5}')    	;⭾k​ 	🔢₅
  hk⭾⅋l( 	ThisHotkey) => SendInput('{Blind}{Numpad6}')    	;⭾l​ 	🔢₆
  hk⭾⅋︔( 	ThisHotkey) => SendInput('{Blind}{NumpadAdd}')  	;⭾;​ 	🔢₊
  hk⭾⅋n( 	ThisHotkey) => SendInput('{Blind}{NumpadEnter}')	;⭾n​ 	🔢Enter
  hk⭾⅋m( 	ThisHotkey) => SendInput('{Blind}{Numpad7}')    	;⭾m​ 	🔢₇
  hk⭾⅋⸴( 	ThisHotkey) => SendInput('{Blind}{Numpad8}')    	;⭾,​ 	🔢₈
  hk⭾⅋．( 	ThisHotkey) => SendInput('{Blind}{Numpad9}')    	;⭾.​ 	🔢₉
  hk⭾⅋⁄( 	ThisHotkey) => SendInput('{Blind}{NumpadDot}')  	;⭾/​ 	🔢．
  hk⭾⅋␠( 	ThisHotkey) => SendInput('{Blind}{Numpad0}')    	;⭾␠​ 	🔢₀
  hk⭾⅋⎈›(	ThisHotkey) => SendInput('{Blind}{Numpad0}')    	;⭾⌥›​	🔢₀
  hk⭾⅋⎇›(	ThisHotkey) => SendInput('{Blind}{NumpadDot}')  	;⭾⭾​ 	🔢．
  hk⭾⅋☰( 	ThisHotkey) => SendInput('{Blind}{NumpadDot}')  	;⭾⎈›​	🔢．
  ; ↓ can't user vars in function names
  ;hk⭾⅋␠›1(	ThisHotkey) => SendInput('{Blind}{Numpad0}')  	;⭾⌥›​	🔢₀
  ;hk⭾⅋␠›2(	ThisHotkey) => SendInput('{Blind}{NumpadDot}')	;⭾⭾​ 	🔢．
  ;hk⭾⅋␠›3(	ThisHotkey) => SendInput('{Blind}{NumpadDot}')	;⭾⎈›​	🔢．


  ; hk☰⅋2(ThisHotkey) {
  ;   SendInput('{Blind}{NumpadDiv}')	;⌥>2​	🔢⁄
  ; }
  ; Hotkey("vk5D & vk32",hk☰⅋2)
}



; alternative way to set up
; setNumPad()
setNumPad() {
  static vk	:= keyConstant._map ; various key name constants, gets vk code to avoid issues with another layout

  pre	:= vk[☰]
  loop parse "2345qwertasdfzxcvb" {
    HotKey(pre " & " vk[A_LoopField], hkNumpad←)
  }
  hkNumpad←(ThisHotkey) {
    Switch ThisHotkey  {
      default  : msgbox('nothing matched hkNumpad← ThisHotkey=' . ThisHotkey)
      ; default  : return
      case pre ' & ' vk['2'] : SendInput('{Blind}{NumpadDiv}')  	;⎇›2​	🔢⁄
      case pre ' & ' vk['3'] : SendInput('{Blind}{NumpadMult}') 	;⎇›3​	🔢∗
      case pre ' & ' vk['4'] : SendInput('{Blind}{NumpadSub}')  	;⎇›4​	🔢₋
      case pre ' & ' vk['5'] : SendInput('{Blind}{NumpadAdd}')  	;⎇›5​	🔢₊
      case pre ' & ' vk['q'] : SendInput('{Blind}{=}')          	;⎇›q​	🔢₌
      case pre ' & ' vk['w'] : SendInput('{Blind}{Numpad1}')    	;⎇›w​	🔢₁
      case pre ' & ' vk['e'] : SendInput('{Blind}{Numpad2}')    	;⎇›e​	🔢₂
      case pre ' & ' vk['r'] : SendInput('{Blind}{Numpad3}')    	;⎇›r​	🔢₃
      case pre ' & ' vk['t'] : SendInput('{Blind}{NumpadAdd}')  	;⎇›t​	🔢₊
      case pre ' & ' vk['a'] : SendInput('{Blind}{Numpad0}')    	;⎇›a​	🔢₀
      case pre ' & ' vk['s'] : SendInput('{Blind}{Numpad4}')    	;⎇›s​	🔢₄
      case pre ' & ' vk['d'] : SendInput('{Blind}{Numpad5}')    	;⎇›d​	🔢₅
      case pre ' & ' vk['f'] : SendInput('{Blind}{Numpad6}')    	;⎇›f​	🔢₆
      case pre ' & ' vk['z'] : SendInput('{Blind}{NumpadDot}')  	;⎇›z​	🔢．
      case pre ' & ' vk['x'] : SendInput('{Blind}{Numpad7}')    	;⎇›x​	🔢₇
      case pre ' & ' vk['c'] : SendInput('{Blind}{Numpad8}')    	;⎇›c​	🔢₈
      case pre ' & ' vk['v'] : SendInput('{Blind}{Numpad9}')    	;⎇›v​	🔢₉
      case pre ' & ' vk['b'] : SendInput('{Blind}{NumpadEnter}')	;⎇›b​	🔢Enter
    }
  }

  pre := vk['⭾']  ; With  ⭾	; with modifiers
  loop parse "7890yuiophjkl;nm,./␠" { ; ⌥☰
    HotKey(pre " & " vk[A_LoopField], hkNumpad→)
  }
    HotKey(pre " & " vk[␠›1], hkNumpad→)
    HotKey(pre " & " vk[␠›2], hkNumpad→)
    HotKey(pre " & " vk[␠›3], hkNumpad→)
  hkNumpad→(ThisHotkey) {
    Switch ThisHotkey  {
      default  : msgbox('nothing matched hkNumpad← ThisHotkey=' . ThisHotkey)
      ; default  : return
      case pre ' & ' vk['7']: SendInput('{Blind}{NumpadDiv}')  	;⭾7​ 	🔢⁄
      case pre ' & ' vk['8']: SendInput('{Blind}{NumpadMult}') 	;⭾8​ 	🔢∗
      case pre ' & ' vk['9']: SendInput('{Blind}{NumpadSub}')  	;⭾9​ 	🔢₋
      case pre ' & ' vk['0']: SendInput('{Blind}{NumpadAdd}')  	;⭾0​ 	🔢₊
      case pre ' & ' vk['y']: SendInput('{Blind}{=}')          	;⭾y​ 	🔢₌
      case pre ' & ' vk['u']: SendInput('{Blind}{Numpad1}')    	;⭾u​ 	🔢₁
      case pre ' & ' vk['i']: SendInput('{Blind}{Numpad2}')    	;⭾i​ 	🔢₂
      case pre ' & ' vk['o']: SendInput('{Blind}{Numpad3}')    	;⭾o​ 	🔢₃
      case pre ' & ' vk['p']: SendInput('{Blind}{−}')          	;⭾p​ 	−
      case pre ' & ' vk['h']: SendInput('{Blind}{BackSpace}')  	;⭾h​ 	␈
      case pre ' & ' vk['j']: SendInput('{Blind}{Numpad4}')    	;⭾j​ 	🔢₄
      case pre ' & ' vk['k']: SendInput('{Blind}{Numpad5}')    	;⭾k​ 	🔢₅
      case pre ' & ' vk['l']: SendInput('{Blind}{Numpad6}')    	;⭾l​ 	🔢₆
      case pre ' & ' vk[';']: SendInput('{Blind}{NumpadAdd}')  	;⭾;​ 	🔢₊
      case pre ' & ' vk['n']: SendInput('{Blind}{NumpadEnter}')	;⭾n​ 	🔢Enter
      case pre ' & ' vk['m']: SendInput('{Blind}{Numpad7}')    	;⭾m​ 	🔢₇
      case pre ' & ' vk[',']: SendInput('{Blind}{Numpad8}')    	;⭾,​ 	🔢₈
      case pre ' & ' vk['.']: SendInput('{Blind}{Numpad9}')    	;⭾.​ 	🔢₉
      case pre ' & ' vk['/']: SendInput('{Blind}{NumpadDot}')  	;⭾/​ 	🔢．
      case pre ' & ' vk['␠']: SendInput('{Blind}{Numpad0}')    	;⭾␠​ 	🔢₀
      case pre ' & ' vk[␠›1]: SendInput('{Blind}{Numpad0}')    	;⭾⌥›​	🔢₀
      case pre ' & ' vk[␠›2]: SendInput('{Blind}{NumpadDot}')  	;⭾☰​ 	🔢．
      case pre ' & ' vk[␠›3]: SendInput('{Blind}{NumpadDot}')  	;⭾⎈›​	🔢．
    }
  }

}

setNumPad2() { ; Numeric Keypad layer              	; with modifiers
  AppsKey & vk32::SendInput('{Blind}{NumpadDiv}')  	;⎇›2​	🔢⁄
  AppsKey & vk33::SendInput('{Blind}{NumpadMult}') 	;⎇›3​	🔢∗
  AppsKey & vk34::SendInput('{Blind}{NumpadSub}')  	;⎇›4​	🔢₋
  AppsKey & vk35::SendInput('{Blind}{NumpadAdd}')  	;⎇›5​	🔢₊
  AppsKey & vk51::SendInput('{Blind}{=}')          	;⎇›q​	🔢₌
  AppsKey & vk57::SendInput('{Blind}{Numpad1}')    	;⎇›w​	🔢₁
  AppsKey & vk45::SendInput('{Blind}{Numpad2}')    	;⎇›e​	🔢₂
  AppsKey & vk52::SendInput('{Blind}{Numpad3}')    	;⎇›r​	🔢₃
  AppsKey & vk54::SendInput('{Blind}{NumpadAdd}')  	;⎇›t​	🔢₊
  AppsKey & vk41::SendInput('{Blind}{Numpad0}')    	;⎇›a​	🔢₀
  AppsKey & vk53::SendInput('{Blind}{Numpad4}')    	;⎇›s​	🔢₄
  AppsKey & vk44::SendInput('{Blind}{Numpad5}')    	;⎇›d​	🔢₅
  AppsKey & vk46::SendInput('{Blind}{Numpad6}')    	;⎇›f​	🔢₆
  AppsKey & vk5A::SendInput('{Blind}{NumpadDot}')  	;⎇›z​	🔢．
  AppsKey & vk58::SendInput('{Blind}{Numpad7}')    	;⎇›x​	🔢₇
  AppsKey & vk43::SendInput('{Blind}{Numpad8}')    	;⎇›c​	🔢₈
  AppsKey & vk56::SendInput('{Blind}{Numpad9}')    	;⎇›v​	🔢₉
  AppsKey & vk42::SendInput('{Blind}{NumpadEnter}')	;⎇›b​	🔢Enter
}
setNumPad3() { ; With  ⭾                        	; with modifiers
  Tab & vk37::SendInput('{Blind}{NumpadDiv}')   	;⭾7​ 	🔢⁄
  Tab & vk38::SendInput('{Blind}{NumpadMult}')  	;⭾8​ 	🔢∗
  Tab & vk39::SendInput('{Blind}{NumpadSub}')   	;⭾9​ 	🔢₋
  Tab & vk30::SendInput('{Blind}{NumpadAdd}')   	;⭾0​ 	🔢₊
  Tab & vk59::SendInput('{Blind}{=}')           	;⭾y​ 	🔢₌
  Tab & vk55::SendInput('{Blind}{Numpad1}')     	;⭾u​ 	🔢₁
  Tab & vk49::SendInput('{Blind}{Numpad2}')     	;⭾i​ 	🔢₂
  Tab & vk4F::SendInput('{Blind}{Numpad3}')     	;⭾o​ 	🔢₃
  Tab & vk50::SendInput('{Blind}{−}')           	;⭾p​ 	−
  Tab & vk48::SendInput('{Blind}{BackSpace}')   	;⭾h​ 	␈
  Tab & vk4A::SendInput('{Blind}{Numpad4}')     	;⭾j​ 	🔢₄
  Tab & vk4B::SendInput('{Blind}{Numpad5}')     	;⭾k​ 	🔢₅
  Tab & vk4C::SendInput('{Blind}{Numpad6}')     	;⭾l​ 	🔢₆
  Tab & vkBA::SendInput('{Blind}{NumpadAdd}')   	;⭾;​ 	🔢₊
  Tab & vk4E::SendInput('{Blind}{NumpadEnter}') 	;⭾n​ 	🔢Enter
  Tab & vk4D::SendInput('{Blind}{Numpad7}')     	;⭾m​ 	🔢₇
  Tab & vkBC::SendInput('{Blind}{Numpad8}')     	;⭾,​ 	🔢₈
  Tab & vkBE::SendInput('{Blind}{Numpad9}')     	;⭾.​ 	🔢₉
  Tab & vkBF::SendInput('{Blind}{NumpadDot}')   	;⭾/​ 	🔢．
  Tab & vk20::SendInput('{Blind}{Numpad0}')     	;⭾␠​ 	🔢₀
  Tab & RAlt::SendInput('{Blind}{Numpad0}')     	;⭾⌥>​	🔢₀
  Tab & AppsKey::SendInput('{Blind}{NumpadDot}')	;⭾☰​ 	🔢．
}
