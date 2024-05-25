#Requires AutoHotKey 2.0.10
#include <libFunc>	; General set of functions
#include <Locale> 	; Various i18n locale functions and win32 constants
#include <str>    	; string helper functions
; Various key constants for more ergonomic input or avoiding keyboard layout issues in key definition
set_key_global()
set_key_global() { ; register global variables
  global ___ := 0
   , ⇧     	    	:= "Shift"	, ‹⇧      	     	:= "LShift"	, ⇧›      	     	:= "RShift"
   , ⎈ := ⌃	    	:= "Ctrl" 	, ‹⎈ := ‹⌃	     	:= "LCtrl" 	, ⎈› := ⌃›	     	:= "RCtrl"
   , ◆ := ❖	:= ⌘	:= "LWin" 	, ‹◆ := ‹❖	:= ‹⌘	:= "LWin"  	, ◆› := ❖›	:= ⌘›	:= "RWin"
   , ⎇ := ⌥	    	:= "Alt"  	, ‹⎇ := ‹⌥	     	:= "LAlt"  	, ⎇› := ⌥›	     	:= "RAlt"
   , ☰:="AppsKey"
   , ∗:='*', ˜	:='~', ＄:='$'
}
set_vk_global()
set_vk_global() { ; register global variables in the format of q⃣  to a virtual key format for later use to avoid lookups and have shorter codes. When syntax doesn't allow, use v+unicode like v〔
  static k := helperString.key→ahk.Bind(helperString)
  global q⃣:=k('q'),w⃣:=k('w'),e⃣:=k('e'),r⃣:=k('r'),t⃣:=k('t'),y⃣:=k('y')
    , u⃣:=k('u'),i⃣:=k('i'),o⃣:=k('o'),p⃣:=k('p')
    , a⃣:=k('a'),s⃣:=k('s'),d⃣:=k('d'),f⃣:=k('f'),g⃣:=k('g')
    , h⃣:=k('h'),j⃣:=k('j'),k⃣:=k('k'),l⃣:=k('l'),v︔:=k(';'),v‘:=k("'"),v⧵:=k('\')
    , z⃣:=k('z'),x⃣:=k('x'),c⃣:=k('c'),v⃣:=k('v'),b⃣:=k('b')
    , n⃣:=k('n'),m⃣:=k('m'),v⸴:=k(','),v．:=k('.'),v⁄:=k('/')
    , vˋ:=k('``')
    , v1⃣:=k('1'),v2⃣:=k('2'),v3⃣:=k('3'),v4⃣:=k('4'),v5⃣:=k('5')
    , v6⃣:=k('6'),v7⃣:=k('7'),v8⃣:=k('8'),v9⃣:=k('9'),v0⃣:=k('0'),v‐:=k('-'),v₌:=k('=')
    , v〔:=k('['),v〕:=k(']')
    , ⇧q:=k('⇧q'),⇧w:=k('⇧w'),⇧e:=k('⇧e'),⇧r:=k('⇧r'),⇧t:=k('⇧t'),⇧y:=k('⇧y')
    , ⇧u:=k('⇧u'),⇧i:=k('⇧i'),⇧o:=k('⇧o'),⇧p:=k('⇧p')
    , ⇧a:=k('⇧a'),⇧s:=k('⇧s'),⇧d:=k('⇧d'),⇧f:=k('⇧f'),⇧g:=k('⇧g')
    , ⇧h:=k('⇧h'),⇧j:=k('⇧j'),⇧k:=k('⇧k'),⇧l:=k('⇧l'),⇧︔:=k('⇧;'),⇧‘:=k("'"),⇧⧵:=k('⇧\')
    , ⇧z:=k('⇧z'),⇧x:=k('⇧x'),⇧c:=k('⇧c'),⇧v:=k('⇧v'),⇧b:=k('⇧b')
    , ⇧n:=k('⇧n'),⇧m:=k('⇧m'),⇧⸴:=k('⇧,'),⇧．:=k('⇧.'),⇧⁄:=k('⇧/')
    , ⇧ˋ:=k('⇧``')
    , ⇧1:=k('⇧1'),⇧2:=k('⇧2'),⇧3:=k('⇧3'),⇧4:=k('⇧4'),⇧5:=k('⇧5')
    , ⇧6:=k('⇧6'),⇧7:=k('⇧7'),⇧8:=k('⇧8'),⇧9:=k('⇧9'),⇧0:=k('⇧0'),⇧‐:=k('⇧-'),v₌:=k('⇧=')
    , ⇧〔:=k('⇧['),⇧〕:=k('⇧]')
}
; msgbox('q⃣ →' q⃣  ' 1→' v1⃣  ' ``→' vˋ ' `'→' v‘ ' =→' v₌ '⇧a→' ⇧a ' v‐→' v‐)


class keyConstant {
  ; learn.microsoft.com/en-us/windows/win32/inputdev/virtual-key-codes
  ; kbdedit.com/manual/low_level_vk_list.html
  static __new() { ; fill the map
    this.fillKeyList()
  }
  static fillKeyList() { ; get all vars and store their values in this .Varname as well ‘vk’ map, and add aliases
    ; k	:= keyConstant ; various key name constants
    ; k.a → vk41
    ; k	:= keyConstant._map
    ; k['a'] → vk41
    static vk := Map(), vklng := Map(), sc := Map(), vkrev := Map(), vkrevlng := Map(), labels := Map(), ahk_token := Map()
     , isInit := false
    if isInit {
      return
    } else {
      isInit := true
    }
    vk.CaseSense       	:= 0 ; make key matching case insensitive
    vklng.CaseSense    	:= 0
    vkrev.CaseSense    	:= 0 ; reverse, vk → key
    vkrevlng.CaseSense 	:= 0
    sc.CaseSense       	:= 0
    labels.CaseSense   	:= 0
    ahk_token.CaseSense	:= 0 ; key tokens that can be used in var/function names like a︔ := ';'
    labels['en'] := "
      ( Join ` LTrim
       `1234567890-=
        qwertyuiop[]
        asdfghjkl;'\
        zxcvbnm,./
       )"
    labels['ru'] := "
      ( Join ` LTrim
       ё1234567890-=
        йцукенгшщзхъ
        фывапролджэ\
        ячсмитьбю.
       )"
    ahk_token['en'] := "
      ( Join ` LTrim
       ˋ1234567890‐₌
        qwertyuiop〔〕
        asdfghjkl︔’⧵
        zxcvbnm ⸴．⁄
       )"
    ; Get dynamically actual VKs for the labels from ↑ for each active system layout
    ; though store it only in simplified 'en'/'ru' (are IDs needed?)
    ;;; add non alpha? just use the currently mapped ones, don't depend on a layout
    lyt_enabled := lyt.getlist() ; system loaded that are available in the language bar
    labels_enabled := []
    for lytID, layout in lyt_enabled {
      ; lytID	:= layout['id']
      LngNm  	:= layout['LangShort'] ;en
      LngLong	:= layout['LangLong'] ;english
      KLID   	:= layout['KLID'] ; 00000409
      if labels.Has(LngNm) {
        labels_enabled.Push(LngNm)
        vklng[LngNm]	:= Map() ; or use unique ? KLID check ;;;
        for key in StrSplit(labels[LngNm]) {
          vk_full	:= DllCall("VkKeyScanExW" ; SHORT VkKeyScanExW( ;;; preload?
           ; low-order  byte contains virtual-key code
           ; high-order byte contains shift state, which can be a combination of the following flag bits
             ; 1 SHIFT  2 CTRL 4 ALT 8 Hankaku key is pressed (either side), 16/32 reserved for the keyboard layout driver
           ,"uShort",Ord(key)	;   [in] WCHAR ch,  	; character to be translated into a virtual-key code
           ,  "ptr",lytID)   	;   [in] HKL   dwhkl	; Input localeID used to translate the character. This parameter can be any input locale identifier previously returned by the LoadKeyboardLayout function
          if not vk_full = -1 {
            vk_code	:= vk_full & 0xFF
            vklng[LngNm][key] := 'vk' hex(vk_code)
          }
        }
      }
    }
    ; Autohotkey custom keys
    vk['🖱↑']	:= 'vk9F'	; WheelUp   	0x9F	078
    vk['🖱↓']	:= 'vk9E'	; WheelDown 	0x9E	078
    vk['🖱→']	:= 'vk9D'	; WheelRight	0x9D	078
    vk['🖱←']	:= 'vk9C'	; WheelLeft 	0x9C	078


    ; "Mappable" codes, to which Unicode characters can be assigned in the High-level editor
    ;              	         	Name          	#Value	Description
    vk['ABNT_C1']  	:= 'vkC1'	; VK_ABNT_C1  	0xC1  	Abnt C1
    vk['ABNT_C2']  	:= 'vkC2'	; VK_ABNT_C2  	0xC2  	Abnt C2
    vk['ATTN']     	:= 'vkF6'	; VK_ATTN     	0xF6  	Attn
    vk['CANCEL']   	:= 'vk03'	; VK_CANCEL   	0x03  	Break
    vk['CLEAR']    	:= 'vk0C'	; VK_CLEAR    	0x0C  	Clear
    vk['CRSEL']    	:= 'vkF7'	; VK_CRSEL    	0xF7  	Cr Sel
    vk['EREOF']    	:= 'vkF9'	; VK_EREOF    	0xF9  	Er Eof
    vk['EXECUTE']  	:= 'vk2B'	; VK_EXECUTE  	0x2B  	Execute
    vk['EXSEL']    	:= 'vkF8'	; VK_EXSEL    	0xF8  	Ex Sel
    vk['ICO_CLEAR']	:= 'vkE6'	; VK_ICO_CLEAR	0xE6  	IcoClr
    vk['ICO_HELP'] 	:= 'vkE3'	; VK_ICO_HELP 	0xE3  	IcoHlp

    start	:= 0x30 ; VK_KEY_0	0x30 ('0')	0
    end  	:= 0x39 ; VK_KEY_9	0x39 ('9')	9
    loop (end - start + 1) {
      i1           	:= A_Index
      i0           	:= A_Index - 1
      key_val_hex  	:= Format("{1:x}", start + i0)
      vk[i0]        	:= 'vk' . key_val_hex
      vk[String(i0)]	:= 'vk' . key_val_hex
    }
    ; -          	0x3A-40 undefined
    start        	:= 0x41 ; VK_KEY_A	0x41 ('A')	A
    end          	:= 0x5A ; VK_KEY_Z	0x5A ('Z')	Z
    keys_alpha   	:= 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    keys_alpha_ru	:= 'фисвуапршолдьтщзйкыегмцчня'
    loop parse keys_alpha {
      i1             	:= A_Index
      i0             	:= A_Index - 1
      key_val_hex    	:= Format("{1:x}", start + i0)
      vk[A_LoopField]	:= 'vk' . key_val_hex
      ru             	:= SubStr(keys_alpha_ru,i1,1)
      vk[ru]         	:= 'vk' . key_val_hex
    }

      vk['NONAME']  	:= 'vkFC'	; VK_NONAME  	0xFC	NoName

      for key in ['ADD','🔢+','🔢₊'] {
      vk[key]	:= 'vk6B'	; VK_ADD	0x6B	Numpad +
      sc[key]	:= 'sc' hex(GetKeySC(vk[key]))
    }
    for key in ['DECIMAL','🔢.','🔢．'] {
      vk[key]	:= 'vk6E'	; VK_DECIMAL	0x6E	Numpad .
      sc[key]	:= 'sc' hex(GetKeySC(vk[key]))
    }
    for key in ['DIVIDE','🔢/','🔢⁄'] {
      vk[key]	:= 'vk6F'	; VK_DIVIDE	0x6F	Numpad /
      sc[key]	:= 'sc' hex(GetKeySC(vk[key]))
    }
    for key in ['MULTIPLY','🔢*','🔢∗'] {
      vk[key]	:= 'vk6A'	; VK_MULTIPLY	0x6A	Numpad *
      sc[key]	:= 'sc' hex(GetKeySC(vk[key]))
    }
    for key in ['SUBTRACT','🔢-','🔢₋','🔢−'] {
      vk[key]	:= 'vk6D'	; VK_SUBTRACT	0x6D	Num -
      sc[key]	:= 'sc' hex(GetKeySC(vk[key]))
    }
    sub_s := Map(1,'₁',2,'₂',3,'₃',4,'₄',5,'₅',6,'₆',7,'₇',8,'₈',9,'₉',0,'₀')
    ; msgbox(sub_s[1])
    start	:= 0x60	; VK_NUMPAD0	0x60	Numpad 0
    end  	:= 0x69	; VK_NUMPAD9	0x69	Numpad 9
    loop (end - start + 1) {
      i1    	:= A_Index
      i0    	:= A_Index - 1
      key_vk	:= 'vk' Format("{1:x}", start + i0)
      for pre in ['NumPad','🔢'] {
        vk[pre .       i0] 	:= key_vk
        vk[pre . sub_s[i0]]	:= vk[pre . i0]
        sc[pre .       i0] 	:= 'sc' hex(GetKeySC(key_vk))
        sc[pre . sub_s[i0]]	:= sc[pre . i0]
      }
    }

    vk['OEM_ATTN']      	:= 'vkF0'	; VK_OEM_ATTN      	0xF0	Oem Attn
    vk['OEM_AUTO']      	:= 'vkF3'	; VK_OEM_AUTO      	0xF3	Auto
    vk['OEM_AX']        	:= 'vkE1'	; VK_OEM_AX        	0xE1	Ax
    vk['OEM_BACKTAB']   	:= 'vkF5'	; VK_OEM_BACKTAB   	0xF5	Back Tab
    vk['OEM_CLEAR']     	:= 'vkFE'	; VK_OEM_CLEAR     	0xFE	OemClr
    vk['OEM_COPY']      	:= 'vkF2'	; VK_OEM_COPY      	0xF2	Copy
    vk['OEM_CUSEL']     	:= 'vkEF'	; VK_OEM_CUSEL     	0xEF	Cu Sel
    vk['OEM_ENLW']      	:= 'vkF4'	; VK_OEM_ENLW      	0xF4	Enlw
    vk['OEM_FINISH']    	:= 'vkF1'	; VK_OEM_FINISH    	0xF1	Finish
    vk['OEM_FJ_LOYA']   	:= 'vk95'	; VK_OEM_FJ_LOYA   	0x95	Loya
    vk['OEM_FJ_MASSHOU']	:= 'vk93'	; VK_OEM_FJ_MASSHOU	0x93	Mashu
    vk['OEM_FJ_ROYA']   	:= 'vk96'	; VK_OEM_FJ_ROYA   	0x96	Roya
    vk['OEM_FJ_TOUROKU']	:= 'vk94'	; VK_OEM_FJ_TOUROKU	0x94	Touroku
    vk['OEM_JUMP']      	:= 'vkEA'	; VK_OEM_JUMP      	0xEA	Jump
    vk['OEM_PA1']       	:= 'vkEB'	; VK_OEM_PA1       	0xEB	OemPa1
    vk['OEM_PA2']       	:= 'vkEC'	; VK_OEM_PA2       	0xEC	OemPa2
    vk['OEM_PA3']       	:= 'vkED'	; VK_OEM_PA3       	0xED	OemPa3
    vk['OEM_RESET']     	:= 'vkE9'	; VK_OEM_RESET     	0xE9	Reset
    vk['OEM_WSCTRL']    	:= 'vkEE'	; VK_OEM_WSCTRL    	0xEE	WsCtrl
    vk['PA1']           	:= 'vkFD'	; VK_PA1           	0xFD	Pa1
    vk['PACKET']        	:= 'vkE7'	; VK_PACKET        	0xE7	Packet
    vk['PLAY']          	:= 'vkFA'	; VK_PLAY          	0xFA	Play
    vk['PROCESSKEY']    	:= 'vkE5'	; VK_PROCESSKEY    	0xE5	Process
    vk['SELECT']        	:= 'vk29'	; VK_SELECT        	0x29	Select
    vk['SEPARATOR']     	:= 'vk6C'	; VK_SEPARATOR     	0x6C	Separator
    vk['ZOOM']          	:= 'vkFB'	; VK_ZOOM          	0xFB	Zoom

      for key in ['OEM_MINUS','-','‐'] {
      vk[key]	:= 'vkBD'	; VK_OEM_MINUS	0xBD	OEM_MINUS (_ -)
    }
    for key in ['OEM_PLUS','=','₌','+','🔢=','🔢₌'] {
      vk[key]	:= 'vkBB'	; VK_OEM_PLUS	0xBB	OEM_PLUS (+ =)
    }
    for key in ['ESCAPE','Esc','⎋','‹🖰'] {
      vk[key]	:= 'vk1B'	; VK_ESCAPE	0x1B	Esc
    }
    for key in ['LBUTTON','🖰1','‹🖰'] {
      vk[key]	:= 'vk01'	; VK_LBUTTON	0x01	Left Button **
    }
    for key in ['MBUTTON','🖰3','🖱'] {
      vk[key]	:= 'vk04'	; VK_MBUTTON	0x04	Middle Button **
    }
    for key in ['RBUTTON','🖰2','🖰›'] {
      vk[key]	:= 'vk02'	; VK_RBUTTON	0x02	Right Button **
    }
    for key in ['XBUTTON1','🖰4','🖰x1'] {
      vk[key]	:= 'vk05'	; VK_XBUTTON1	0x05	X Button 1 **
    }
    for key in ['XBUTTON2','🖰5','🖰x2'] {
      vk[key]	:= 'vk06'	; VK_XBUTTON2	0x06	X Button 2 **
    }

      for key in ['Tab','⭾','↹'] {
      vk[key]	:= 'vk09'	; VK_TAB	0x09	Tab
    }
    for key in ['SPACE','␠','␣'] {
      vk[key]	:= 'vk20'	; VK_SPACE	0x20	Space
    }
    for key in ['BACK','BS','␈','⌫'] {
      vk[key]	:= 'vk08'	; VK_BACK	0x08	Backspace
    }
    for key in ['OEM_COMMA',',','⸴','б'] {
      vk[key]	:= 'vkBC'	; VK_OEM_COMMA	0xBC	OEM_COMMA (< ,)
    }
    for key in ['OEM_PERIOD','.','．','ю'] {
      vk[key]	:= 'vkBE'	; VK_OEM_PERIOD	0xBE	OEM_PERIOD (> .)
    }
    for key in ['OEM_2','/','⁄'] {
      vk[key]	:= 'vkBF'	; VK_OEM_2	0xBF	OEM_2 (? /)
    }
    for key in ['OEM_1',';','︔','ж'] {
      vk[key]	:= 'vkBA'	; VK_OEM_1	0xBA	OEM_1 (: ;)
    }

      for key in ['OEM_102'] {
      vk[key]	:= 'vkE2'	; VK_OEM_102	0xE2	OEM_102 (> <)
    }
    for key in ['OEM_3','ё','``','ˋ','˜'] {
      vk[key]	:= 'vkC0'	; VK_OEM_3	0xC0	OEM_3 (~ `)
    }
    for key in ['OEM_4','х','[','【','「','〔','⎡'] {
      vk[key]	:= 'vkDB'	; VK_OEM_4	0xDB	OEM_4 ({ [)
    }
    for key in ['OEM_6','ъ',']','】','」','〕','⎣'] {
      vk[key]	:= 'vkDD'	; VK_OEM_6	0xDD	OEM_6 (} ])
    }
    for key in ['OEM_5','\','⧵ ','＼'] {
      vk[key]	:= 'vkDC'	; VK_OEM_5	0xDC	OEM_5 (| \)
    }
    for key in ['OEM_7','э',"'",'“','”','＂','«','»'] {
      vk[key]	:= 'vkDE'	; VK_OEM_7	0xDE	OEM_7 (" ')
    }
    for key in ['OEM_8','⅋'] {
      vk[key]	:= 'vkDF'	; VK_OEM_8	0xDF	OEM_8 (§ !)
    }
    for key in ['APPS','AppsKey','☰'] {
      vk[key]	:= 'vk5D'	; VK_APPS	0x5D	Context Menu
    }
    for key in ['CAPITAL','CapsLock','Caps','⇪'] {
      vk[key]	:= 'vk14'	; VK_CAPITAL	0x14	Caps Lock
    }
    for key in ['NumLock','⇭'] {
      vk[key]	:= 'vk90'	; VK_NUMLOCK	0x90	Num Lock
    }
    for key in ['SCROLL','ScrollLock','⇳🔒'] { ; '⤓' conflicts with end
      vk[key]	:= 'vk91'	; VK_SCROLL	0x91	Scrol Lock
    }

      ; autohotkey.com/boards/viewtopic.php?f=76&t=18836&p=91282&hilit=keyboard+hook+home+end#p91282
    ; hook handles each key either by virtual key code or by scan code, not both. All keys listed in the g_key_to_sc array are handled by SC, meaning that pressing one of these keys will not trigger a hook hotkey which was registered by VK
      ; g_key_to_sc: NumpadEnter, Del, Ins, Up, Down, Left, Right, Home, End, PgUp and PgDn
    for key in ['DOWN','▼','↓'] {
      vk[key]	:= 'vk28' 	; VK_DOWN	0x28	Arrow Down
      sc[key]	:= 'sc150'	;
    }
    for key in ['UP','▲','↑'] {
      vk[key]	:= 'vk26' 	; VK_UP	0x26	Arrow Up
      sc[key]	:= 'sc148'	;
    }
    for key in ['LEFT','◀','←'] {
      vk[key]	:= 'vk25' 	; VK_LEFT	0x25	Arrow Left
      sc[key]	:= 'sc14B'	;
    }
    for key in ['RIGHT','▶','→'] {
      vk[key]	:= 'vk27' 	; VK_RIGHT	0x27	Arrow Right
      sc[key]	:= 'sc14D'	;
    }
    for key in ['PRIOR','PgUp','⇞'] {
      vk[key]	:= 'vk21' 	; VK_PRIOR	0x21	Page Up
      sc[key]	:= 'sc149'	;
    }
    for key in ['NEXT','PgDn','⇟'] {
      vk[key]	:= 'vk22' 	; VK_NEXT	0x22	Page Down
      sc[key]	:= 'sc151'	;
    }
    for key in ['INSERT','⎀'] {
      vk[key]	:= 'vk2D' 	; VK_INSERT	0x2D	Insert
      sc[key]	:= 'sc152'	;
    }
    for key in ['Home','⇤','⤒','↖'] {
      vk[key]	:= 'vk24' 	; VK_HOME	0x24	Home
      sc[key]	:= 'sc147'	;
    }
    for key in ['End','⇥','⤓','↘'] {
      vk[key]	:= 'vk23' 	; VK_END	0x23	End
      sc[key]	:= 'sc14F'	;
    }
    for key in ['DELETE','del','␡','⌦'] {
      vk[key]	:= 'vk2E' 	; VK_DELETE	0x2E	Delete
      sc[key]	:= 'sc153'	;
    }
    for key in ['RETURN','Enter','⏎','↩','⌤','␤','␍','NumpadEnter','🔢⏎','🔢↩','🔢Enter'] {
      vk[key]	:= 'vk0D' 	; VK_RETURN	0x0D	Enter
      sc[key]	:= 'sc11C'	;          	    	NumpadEnter
    }


      _left 	:= ['‹','<']
    _right	:= ['›','>']
    for key in ['SHIFT','⇧'] {
      for l in _left {
        vk[l . key]	:= 'vkA0'	; VK_LSHIFT	0xA0	Left Shift
      }
      for r in _right {
        vk[      key . r]	:= 'vkA1'	; VK_RSHIFT	0xA1	Right Shift
      }
    }
    for key in ['CONTROL','Ctrl','⎈','⌃','^'] {
      for l in _left {
        vk[l . key]	:= 'vkA2'	; VK_LCONTROL	0xA2	Left Ctrl
      }
      for r in _right {
        vk[      key . r]	:= 'vkA3'	; VK_RCONTROL	0xA3	Right Ctrl
      }
    }
    for key in ['Win','◆','❖','⌘'] {
      for l in _left {
        vk[l . key]	:= 'vk5B'	; VK_LWIN	0x5B	Left Win
      }
      for r in _right {
        vk[      key . r]	:= 'vk5C'	; VK_RWIN	0x5C	Right Win
      }
    }
    for key in ['Alt','⎇','⌥'] {
      for l in _left {
        vk[l . key]	:= 'vkA4'	; VK_LMENU	0xA4	Left Alt
      }
      for r in _right {
        vk[      key . r]	:= 'vkA5'	; VK_RMENU	0xA5	Right Alt
      }
    }

      vk['BROWSER_HOME']     	:= 'vkAC'	; VK_BROWSER_HOME     	0xAC  	Browser Home
    ;                     	         	Name                  	#Value	Description
    vk['_none_']           	:= 'vkFF'	; VK__none_           	0xFF  	no VK mapping
    vk['ACCEPT']           	:= 'vk1E'	; VK_ACCEPT           	0x1E  	Accept
    vk['BROWSER_BACK']     	:= 'vkA6'	; VK_BROWSER_BACK     	0xA6  	Browser Back
    vk['BROWSER_FAVORITES']	:= 'vkAB'	; VK_BROWSER_FAVORITES	0xAB  	Browser Favorites
    vk['BROWSER_FORWARD']  	:= 'vkA7'	; VK_BROWSER_FORWARD  	0xA7  	Browser Forward
    vk['BROWSER_REFRESH']  	:= 'vkA8'	; VK_BROWSER_REFRESH  	0xA8  	Browser Refresh
    vk['BROWSER_SEARCH']   	:= 'vkAA'	; VK_BROWSER_SEARCH   	0xAA  	Browser Search
    vk['BROWSER_STOP']     	:= 'vkA9'	; VK_BROWSER_STOP     	0xA9  	Browser Stop
    vk['CONVERT']          	:= 'vk1C'	; VK_CONVERT          	0x1C  	Convert

    start	:= 0x70 ; VK_F1 	0x70	F1
    end  	:= 0x87 ; VK_F24	0x87	F24
    loop (end - start + 1) {
      i1         	:= A_Index
      i0         	:= A_Index - 1
      key_val_hex	:= Format("{1:x}", start + i0)
      ; loop parse 'F🌐ƒⓕⒻ🄵🅕🅵' { ; bugs due to unicode chars, which are split into invalid parts
      for k in ['F','🌐','ƒ','ⓕ','Ⓕ','🄵','🅕','🅵'] {
        vk[k . i1]	:= 'vk' . key_val_hex
      }
    }

    vk['FINAL']              	:= 'vk18'	; VK_FINAL              	0x18	Final
    vk['HELP']               	:= 'vk2F'	; VK_HELP               	0x2F	Help
    vk['ICO_00']             	:= 'vkE4'	; VK_ICO_00             	0xE4	Ico00 *
    vk['JUNJA']              	:= 'vk17'	; VK_JUNJA              	0x17	Junja
    vk['KANA']               	:= 'vk15'	; VK_KANA               	0x15	Kana
    vk['KANJI']              	:= 'vk19'	; VK_KANJI              	0x19	Kanji
    vk['LAUNCH_APP1']        	:= 'vkB6'	; VK_LAUNCH_APP1        	0xB6	App1
    vk['LAUNCH_APP2']        	:= 'vkB7'	; VK_LAUNCH_APP2        	0xB7	App2
    vk['LAUNCH_MAIL']        	:= 'vkB4'	; VK_LAUNCH_MAIL        	0xB4	Mail
    vk['LAUNCH_MEDIA_SELECT']	:= 'vkB5'	; VK_LAUNCH_MEDIA_SELECT	0xB5	Media
    vk['MEDIA_NEXT_TRACK']   	:= 'vkB0'	; VK_MEDIA_NEXT_TRACK   	0xB0	Next Track
    vk['MEDIA_PLAY_PAUSE']   	:= 'vkB3'	; VK_MEDIA_PLAY_PAUSE   	0xB3	Play / Pause
    vk['MEDIA_PREV_TRACK']   	:= 'vkB1'	; VK_MEDIA_PREV_TRACK   	0xB1	Previous Track
    vk['MEDIA_STOP']         	:= 'vkB2'	; VK_MEDIA_STOP         	0xB2	Stop
    vk['MODECHANGE']         	:= 'vk1F'	; VK_MODECHANGE         	0x1F	Mode Change
    vk['NONCONVERT']         	:= 'vk1D'	; VK_NONCONVERT         	0x1D	Non Convert
    vk['OEM_FJ_JISHO']       	:= 'vk92'	; VK_OEM_FJ_JISHO       	0x92	Jisho
    vk['PAUSE']              	:= 'vk13'	; VK_PAUSE              	0x13	Pause
    vk['PRINT']              	:= 'vk2A'	; VK_PRINT              	0x2A	Print
    vk['SLEEP']              	:= 'vk5F'	; VK_SLEEP              	0x5F	Sleep
    vk['SNAPSHOT']           	:= 'vk2C'	; VK_SNAPSHOT           	0x2C	Print Screen
    vk['VOLUME_DOWN']        	:= 'vkAE'	; VK_VOLUME_DOWN        	0xAE	Volume Down
    vk['VOLUME_MUTE']        	:= 'vkAD'	; VK_VOLUME_MUTE        	0xAD	Volume Mute
    vk['VOLUME_UP']          	:= 'vkAF'	; VK_VOLUME_UP          	0xAF	Volume Up

    for keyNm, vkCode in vk { ; Back vk08
      this.%keyNm%	:= vkCode ; convert map into object properties
    }
    for LngNm in labels_enabled { ; en / ru (but only if such layouts exist)
      vkrevlng[LngNm]	:= Map()
    }
    for keyNm, vkCode in vk { ; Back vk08
      vkrev[              vkCode ]	:= keyNm ;     [vk08] = Back create a reverse map
      for LngNm in labels_enabled { ; en / ru (but only if such layouts exist)
          vkrevlng[LngNm][vkCode ]	:= keyNm ; [en][vk08] = Back
        for keyNml, vkCodel in vklng[LngNm] { ; q vk51
          vkrevlng[LngNm][vkCodel]	:= keyNml ; overwrite dupes with layout-specific combo since same VK has layout-specific key
        }
      }
    }

    this._map      	:= vk
    this._maplng   	:= vklng
    this._mapr     	:= vkrev
    this._maprlng  	:= vkrevlng
    this._mapsc    	:= sc
    this._labels   	:= labels
    this._ahk_token	:= ahk_token
  }
}
