#Requires AutoHotKey 2.0.10
; v1.1@23-10
; PressH_ChPick function located in /lib, TimerHold defined in AES section of aCommon.ahk
#MaxThreadsPerHotkey 2 ; 2 Allows A₁BA₂ fast typing, otherwise A₂ doesn't register
#InputLevel 1          ; Set the level for the following hotkeys so that they can activate lower-level hotstrings (autohotkey.com/docs/commands/SendLevel.htm)

; Use SendEvent for SpecialChars-Alt to recognize keys
setChar🠿()
setChar🠿() { ; hold key to select a symbol from a popup menu
  static k	:= keyConstant._map ; various key name constants, gets vk code to avoid issues with another layout
   , s    	:= helperString
  HotIfWinActive("ahk_group PressnHold")
  loop parse "abce/nosuyz'" { ; ⇧🠿a​⇧🠿b​⇧🠿c​⇧🠿e​⇧🠿/​⇧🠿n​⇧🠿o​⇧🠿s​⇧🠿u​⇧🠿y​⇧🠿z​⇧🠿'​
    HotKey('$' s.key→ahk(    k[A_LoopField]), char🠿, "T2")
    HotKey('$' s.key→ahk('⇧' k[A_LoopField]), char🠿, "T2")
  }
  loop parse "qhxtfvg-r" { ; 🠿q​🠿h​🠿x​🠿t​🠿f​🠿v​🠿g​🠿-​🠿r​
    HotKey('$' s.key→ahk(    k[A_LoopField]), char🠿, "T2")
  }
  loop parse "``45" { ; ⇧🠿`​⇧🠿4​⇧🠿5​
    HotKey('$' s.key→ahk('⇧' k[A_LoopField]), char🠿, "T2")
  }
  HotIf
  WinActive_Not(active, not_active) { ; = #Hotif WinActive("ahk_group PressnHold") and !WinActive("ahk_group Browser")
    if WinActive(active) and !WinActive(not_active) {
      return true
    } else {
      return false
    }
  }
  HotIf (*) => WinActive_Not("ahk_group PressnHold", "ahk_group Browser") ; exclude Vivaldi to allow using vimium jkl;
  loop parse "il" { ; ⇧🠿i​⇧🠿l​
    HotKey('$' s.key→ahk(    k[A_LoopField]), char🠿, "T2")
    HotKey('$' s.key→ahk('⇧' k[A_LoopField]), char🠿, "T2")
  }
  HotIf ;i
  blind_ := false
  char🠿(ThisHotkey) {
    Switch ThisHotkey  {
      default  : return ; msgbox('nothing matched setChar🠿 ThisHotkey=' . ThisHotkey)
      ; —————————— Diacritic
      case '$' s.key→ahk( 'a')	: char→sym('a',Dia['a'	],unset)
      case '$' s.key→ahk('⇧a')	: char→sym('a',Dia['A'	],unset)
      case '$' s.key→ahk( 'c')	: char→sym('c',Dia['c'	],unset)
      case '$' s.key→ahk('⇧c')	: char→sym('c',Dia['C'	],unset)
      case '$' s.key→ahk( 'e')	: char→sym('e',Dia['e'	],unset)
      case '$' s.key→ahk('⇧e')	: char→sym('e',Dia['E'	],unset)
      case '$' s.key→ahk( 'i')	: char→sym('i',Dia['i'	],unset)
      case '$' s.key→ahk('⇧i')	: char→sym('i',Dia['I'	],unset)
      case '$' s.key→ahk( 'l')	: char→sym('l',Dia['l'	],unset)
      case '$' s.key→ahk('⇧l')	: char→sym('l',Dia['L'	],unset)
      case '$' s.key→ahk( 'n')	: char→sym('n',Dia['n'	],unset)
      case '$' s.key→ahk('⇧n')	: char→sym('n',Dia['N'	],unset)
      case '$' s.key→ahk( 'o')	: char→sym('o',Dia['o'	],unset)
      case '$' s.key→ahk('⇧o')	: char→sym('o',Dia['O'	],unset)
      case '$' s.key→ahk( 's')	: char→sym('s',Dia['s'	],unset)
      case '$' s.key→ahk('⇧s')	: char→sym('s',Dia['S'	],unset)
      case '$' s.key→ahk( 'u')	: char→sym('u',Dia['u'	],unset)
      case '$' s.key→ahk('⇧u')	: char→sym('u',Dia['U'	],unset)
      case '$' s.key→ahk( 'y')	: char→sym('y',Dia['y'	],unset)
      case '$' s.key→ahk('⇧y')	: char→sym('y',Dia['Y'	],unset)
      case '$' s.key→ahk( 'z')	: char→sym('z',Dia['z'	],unset)
      case '$' s.key→ahk('⇧z')	: char→sym('z',Dia['Z'	],unset)
      ; —————————— Alt symbols (math, currency etc.)
      case '$' s.key→ahk( 'b')  	: char→sym('b',Ch['Bullet'     	],unset)
      case '$' s.key→ahk('⇧b')  	: char→sym('b',Ch['Misc'       	],unset)
      ; case s.key→ahk( 'd')    	: char→sym('d',Ch['WinFile'    	],Ch['WinFileLab'])
      ; case s.key→ahk('⇧d')    	: char→sym('d',Ch['WinFile'    	],Ch['WinFileLab'])
      case '$' s.key→ahk( '/')  	: char→sym('/',Ch['WinFile'    	],Ch['WinFileLab'])
      case '$' s.key→ahk('⇧/')  	: char→sym('/',Ch['WinFile'    	],Ch['WinFileLab'])
      case '$' s.key→ahk( 'q')  	: char→sym('q',Ch['XSymbols'   	],Ch['XSymbolsLab'])
      case '$' s.key→ahk( 'h')  	: char→sym('h',Ch['Currency'   	],Ch['CurrLab'])
      case '$' s.key→ahk( 'x')  	: char→sym('x',Ch['Tech'       	],Ch['TechLab'])
      case '$' s.key→ahk( 't')  	: char→sym('t',Ch['Math'       	],Ch['MathLab'])
      case '$' s.key→ahk( 'f')  	: char→sym('f',Ch['Fractions'  	],unset)
      case '$' s.key→ahk( 'v')  	: char→sym('v',Ch['Subscript'  	],Ch['SubLab'])
      case '$' s.key→ahk( 'g')  	: char→sym('g',Ch['Superscript'	],Ch['SupLab'])
      ; case '$' s.key→ahk( 'm')	: char→sym('m',Ch['Dash'       	],Ch['DashLab'],'-')
      case '$' s.key→ahk( '-')  	: char→sym('-',Ch['Dash'       	],Ch['DashLab'])
      ; case '$' s.key→ahk( 'p')	: char→sym('p',Ch['XSymbols'   	],Ch['XSymbolsLab'])
      case '$' s.key→ahk( 'r')  	: char→sym('r',Ch['Checks'     	],Ch['ChecksLab'])
      ; case '$' s.key→ahk( 'w')	: char→sym('w',Ch['Arrows'     	],Ch['ArrowsLab'])
      case '$' s.key→ahk( "'")  	: char→sym( "'",Ch['QuotesS'   	],unset)
      case '$' s.key→ahk("⇧'")  	: char→sym( "'",Ch['QuotesD'   	],unset)
      case '$' s.key→ahk('⇧``') 	: char→sym('``',Ch['Para'      	],unset)
      case '$' s.key→ahk('⇧5')  	: char→sym('5',Ch['Percent'    	],unset)
      case '$' s.key→ahk('⇧4')  	: char→sym('4',Ch['Currency'   	],unset)
    }
  }
}
char→sym(c,key_list,labels:=unset,blind_:=true) { ;
  static k	:= keyConstant._map ; various key name constants, gets vk code to avoid issues with another layout
   , s    	:= helperString
  vkC := s.key→ahk(c) ; vkC := Format("vk{:X}",GetKeyVK(c)) bugs with locale
  SendEvent((blind_ ? '{blind}' : '') '{' . vkC . ' down}{' . vkC . ' up}') ; type the char (to be deleted later on match), use {blind} to retain ⇧◆⎇⎈ positions)
  if (KeyWait(vkC,TimerHold) = 0) {
    PressH_ChPick(key_list,(IsSet(labels) ? labels : unset),c)
  } ; else SendEvent('{' . vkC . ' up}')
  }

#MaxThreadsPerHotkey 1
#InputLevel 0
