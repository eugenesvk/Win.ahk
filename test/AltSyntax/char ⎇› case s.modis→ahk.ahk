#Requires AutoHotKey 2.1-alpha.4
; same as Char-AltGr, but working for right Alt (which doesn't pass Control as well like AltGr does)
;#SingleInstance force
;#InstallKeybdHook
;#UseHook
; #HotIf WinActive("ahk_class PX_WINDOW_CLASS") ; Or WinActive("ahk_class GxWindowClass")
; Typographic Layout via Right Alt, alternatively AltGr>! [Guide](https://superuser.com/questions/592970/can-i-make-ctrlalt-not-act-like-altgr-on-windows)
; Variables set in gVars
; Unicode codepoints https://unicode-table.com
  ; >!2::SendRaw '@' or  >!2::SendInput "{Raw}@"

;;; add blacklist and skip during iteration, check commented items below
;;; todo convert
; Numbers ⌥
  ; >!vkC0::{ ;[⌥`] vkC0 ⟶ [` / ~Ru] name (U+0060 / U+007E)
  ;   global ruU
  ;   if (GetCurLayout() = ruU) {
  ;     SendInput Bir["1R"][1]
  ;   } else {
  ;     SendInput Bir["1"][1]
  ;   }
  ;   }
  ; >!vk37::{  ;[⌥7] vk37 ⟶ [§/&Ru] name (U+)
  ;   global ruU
  ;   if (GetCurLayout() = ruU) {
  ;     SendInput Bir["1R"][8]
  ;   } else {
  ;     SendInput Bir["1"][8]
  ;   }
  ;   }
  ; ; >!vk37::	SendInput Bir["1"][8]	;[⌥7] vk37 ⟶ [§] name	(U+)
  ; >!vkBF:: ;[⌥/] vkBF ⟶ [⁄ or /Ru] Typographic (Fraction Slash)/Regular Solidus (U+2044 / U+002F)
   	; global ruU
  ;	if (GetCurLayout() = ruU) {
  ;		SendInput Bir["ZR"][10]
  ;	} else {
  ;		SendInput Bir["Z"][10]
  ;	}
  ;Return

;;; can't differentiate layout 0t the VK level, add a function, currently inserts are the same
setModifier()
setModifier() { ; disable? → Custom combinations act as though they have the wildcard (*) modifier by default
  ; !+sc153::msgbox('manual') ; fails with right delete+shift+alt
  static vk	:= keyConstant._map, sc := keyConstant._mapsc  ; various key name constants, gets vk code to avoid issues with another layout
   , s     	:= helperString
   , hkf   	:= keyFunc.customHotkeyFull

  ; msgbox(s.modis→ahk('⇧›⎇›‹⎈')) ; >!>+LCtrl ; preserves the position of the last modifier
  ; msgbox(s.key→ahk('⇧›⎇›⇪')) ; >+>!vk14
  ; msgbox(s.key→ahk('⇧›⎇›␡')) ;
  loop parse "⇧⎈◆⎇" { ; insert modifier symbols with the right-side symbol key and left-side mod
    HotKey(s.modis→ahk('   ⎇›‹' A_LoopField), insertSymbol)
    HotKey(s.modis→ahk('⇧›⎇›‹' A_LoopField), insertSymbol)
  }
  loop parse "⭾⇪␠␈⏎" { ; insert symbols for other keys
    HotKey(s.key→ahk('   ⎇›' A_LoopField), insertSymbol)
    HotKey(s.key→ahk('⇧›⎇›' A_LoopField), insertSymbol)
  }
  HotKey(s.key→ahk('⇧›⎇›☰'), insertSymbol)

  loop parse "▼▲◀▶" { ;  mandatory ⇧ with arrow keys to allow simple modifiers to modify; need scan codes
    r := hkf("","⇧›⎇›" . A_LoopField,"",kT:='sc'), Hotkey(r[1],%r[2]%)
  }
  hk⇧›⎇›▼(ThisHotkey) => SendInput('▼')	;
  hk⇧›⎇›▲(ThisHotkey) => SendInput('▲')	;
  hk⇧›⎇›◀(ThisHotkey) => SendInput('◀')	;
  hk⇧›⎇›▶(ThisHotkey) => SendInput('▶')	;

  ; autohotkey.com/boards/viewtopic.php?f=76&t=18836&p=91282&hilit=keyboard+hook+home+end#p91282
  ; hook handles each key either by virtual key code or by scan code, not both. All keys listed in the g_key_to_sc array are handled by SC, meaning that pressing one of these keys will not trigger a hook hotkey which was registered by VK
    ; g_key_to_sc: NumpadEnter, Del, Ins, Up, Down, Left, Right, Home, End, PgUp and PgDn.
  loop parse "␡⎀⇞⇟⇤⇥" { ; insert symbols for keys that don't work with a hook with VKs (or use scan codes)
    HotKey(s.key→ahk('   ⎇›' A_LoopField,'sc'), insertSymbol)
    HotKey(s.key→ahk('⇧›⎇›' A_LoopField,'sc'), insertSymbol)
  }

  insertSymbol(ThisHotkey) {
    Switch ThisHotkey  {
      default  : return
      ; default  : msgbox('nothing matched insertSymbol ThisHotkey ' . ThisHotkey)
      case s.modis→ahk('   ⎇›‹⇧')	: SendInput('⇧')
      case s.modis→ahk('⇧›⎇›‹⇧') 	: SendInput('⇧')
      case s.modis→ahk('   ⎇›‹⎈')	: SendInput('⎈')
      case s.modis→ahk('⇧›⎇›‹⎈') 	: SendInput('⌃')
      case s.modis→ahk('   ⎇›‹◆')	: SendInput('◆')
      case s.modis→ahk('⇧›⎇›‹◆') 	: SendInput('❖⌘')
      case s.modis→ahk('   ⎇›‹⎇')	: SendInput('⎇')
      case s.modis→ahk('⇧›⎇›‹⎇') 	: SendInput('⌥')
      case s.key→ahk('   ⎇› ⭾')  	: SendInput('⭾')
      case s.key→ahk('⇧›⎇› ⭾')   	: SendInput('↹')
      case s.key→ahk('   ⎇› ⇪')  	: SendInput('⇪')
      case s.key→ahk('⇧›⎇› ⇪')   	: SendInput('⇪')
      case s.key→ahk('   ⎇› ␠')  	: SendInput('␠')
      case s.key→ahk('⇧›⎇› ␠')   	: SendInput('␣')
      case s.key→ahk('   ⎇› ␈')  	: SendInput('␈')
      case s.key→ahk('⇧›⎇› ␈')   	: SendInput('⌫')
      case s.key→ahk('   ⎇› ⏎')  	: SendInput('⏎')
      case s.key→ahk('⇧›⎇› ⏎')   	: SendInput('↩⌤␤')
      case s.key→ahk('⇧›⎇› ☰')   	: SendInput('☰')
      ; ↓ sc, see above
      case s.key→ahk('   ⎇› ␡','sc')	: SendInput('␡')
      case s.key→ahk('⇧›⎇› ␡','sc') 	: SendInput('⌦')
      case s.key→ahk('   ⎇› ⇞','sc')	: SendInput('⇞')
      case s.key→ahk('⇧›⎇› ⇞','sc') 	: SendInput('⇞')
      case s.key→ahk('   ⎇› ⇟','sc')	: SendInput('⇟')
      case s.key→ahk('⇧›⎇› ⇟','sc') 	: SendInput('⇟')
      case s.key→ahk('   ⎇› ⎀','sc')	: SendInput('⎀')
      case s.key→ahk('⇧›⎇› ⎀','sc') 	: SendInput('⎀')
      case s.key→ahk('   ⎇› ⇤','sc')	: SendInput('⇤')
      case s.key→ahk('⇧›⎇› ⇤','sc') 	: SendInput('⤒↖')
      case s.key→ahk('   ⎇› ⇥','sc')	: SendInput('⇥')
      case s.key→ahk('⇧›⎇› ⇥','sc') 	: SendInput('⤓↘')
    }
  }
}
