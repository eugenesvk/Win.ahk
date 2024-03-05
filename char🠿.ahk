#Requires AutoHotKey 2.0.10
; v1.1@23-10
; PressH_ChPick function located in /lib, TimerHold defined in AES section of aCommon.ahk
#MaxThreadsPerHotkey 2 ; 2 Allows A₁BA₂ fast typing, otherwise A₂ doesn't register
#InputLevel 1          ; Set the level for the following hotkeys so that they can activate lower-level hotstrings (autohotkey.com/docs/commands/SendLevel.htm)

; Use SendEvent for SpecialChars-Alt to recognize keys
setChar🠿()
setChar🠿() { ; hold key to select a symbol from a popup menu
  static k   	:= keyConstant._map ; various key name constants, gets vk code to avoid issues with another layout
   , s       	:= helperString
   , pre     	:= '$~' ; use $kbd hook and don't ~block input to avoid typing lag

  HotIfWinActive("ahk_group PressnHold")
  ;;; 1 Define hotkeys with and without Shift
  loop parse "abce/nosuyz'" { ; ⇧🠿a​⇧🠿b​⇧🠿c​⇧🠿e​⇧🠿/​⇧🠿n​⇧🠿o​⇧🠿s​⇧🠿u​⇧🠿y​⇧🠿z​⇧🠿'​
    HotKey(pre s.key→ahk(    k[A_LoopField]), hkChar🠿, "T2")
    HotKey(pre s.key→ahk('⇧' k[A_LoopField]), hkChar🠿, "T2")
  }
  ;;; 2 Define hotkeys          without Shift
  loop parse "qwpxtvg-r" { ; 🠿q​🠿w​🠿p​🠿x​🠿t​🠿v​🠿g​🠿-​🠿r​ f used for home row mod h for exit insert mode
    HotKey(pre s.key→ahk(    k[A_LoopField]), hkChar🠿, "T2")
  }
  ;;; 3 Define hotkeys with             Shift
  loop parse "``45f" { ; ⇧🠿`​⇧🠿4​⇧🠿5​⇧🠿f​
    HotKey(pre s.key→ahk('⇧' k[A_LoopField]), hkChar🠿, "T2")
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
    HotKey(pre s.key→ahk(    k[A_LoopField]), hkChar🠿, "T2")
    HotKey(pre s.key→ahk('⇧' k[A_LoopField]), hkChar🠿, "T2")
  }
  HotIf
  ; blind_ := false
  ;;; 4 Match hotkeys defined above to actual symbols (see symbol.ahk)
  hkChar🠿(ThisHotkey) {
    hk := ThisHotkey
    dbgTT(5,ThisHotkey,t:=1) ;
    ; flag := s.getKeyPrefixFlag(hk)
    ; is∗ := flag & f∗ ; any modifier allowed, so match both ‘a’ and ‘⇧a’
    Switch ThisHotkey, 0 {
      default  : return ; msgbox('nothing matched setChar🠿 ThisHotkey=' . ThisHotkey)
      ; —————————— Diacritic               hk  c  key_list lblMap lblKey
      case ＄ ˜  a⃣	: char→sym(hk,'a',Dia['a'	],unset,unset)
      case ＄ ˜ ⇧a 	: char→sym(hk,'a',Dia['A'	],unset,unset)
      case ＄ ˜  c⃣	: char→sym(hk,'c',Dia['c'	],unset,unset)
      case ＄ ˜ ⇧c 	: char→sym(hk,'c',Dia['C'	],unset,unset)
      case ＄ ˜  e⃣	: char→sym(hk,'e',Dia['e'	],unset,unset)
      case ＄ ˜ ⇧e 	: char→sym(hk,'e',Dia['E'	],unset,unset)
      case ＄ ˜  i⃣	: char→sym(hk,'i',Dia['i'	],unset,unset)
      case ＄ ˜ ⇧i 	: char→sym(hk,'i',Dia['I'	],unset,unset)
      case ＄ ˜  l⃣	: char→sym(hk,'l',Dia['l'	],unset,unset)
      case ＄ ˜ ⇧l 	: char→sym(hk,'l',Dia['L'	],unset,unset)
      case ＄ ˜  n⃣	: char→sym(hk,'n',Dia['n'	],unset,unset)
      case ＄ ˜ ⇧n 	: char→sym(hk,'n',Dia['N'	],unset,unset)
      case ＄ ˜  o⃣	: char→sym(hk,'o',Dia['o'	],unset,unset)
      case ＄ ˜ ⇧o 	: char→sym(hk,'o',Dia['O'	],unset,unset)
      case ＄ ˜  s⃣	: char→sym(hk,'s',Dia['s'	],unset,unset)
      case ＄ ˜ ⇧s 	: char→sym(hk,'s',Dia['S'	],unset,unset)
      case ＄ ˜  u⃣	: char→sym(hk,'u',Dia['u'	],unset,unset)
      case ＄ ˜ ⇧u 	: char→sym(hk,'u',Dia['U'	],unset,unset)
      case ＄ ˜  y⃣	: char→sym(hk,'y',Dia['y'	],unset,unset)
      case ＄ ˜ ⇧y 	: char→sym(hk,'y',Dia['Y'	],unset,unset)
      case ＄ ˜  z⃣	: char→sym(hk,'z',Dia['z'	],unset,unset)
      case ＄ ˜ ⇧z 	: char→sym(hk,'z',Dia['Z'	],unset,unset)
      ; —————————— Alt symbols (math, currency etc.)
      case ＄ ˜  b⃣ 	: char→sym(hk,'b',Ch['Bullet'     	],unset,unset)
      case ＄ ˜ ⇧b  	: char→sym(hk,'b',Ch['Misc'       	],unset,unset)
      case ＄ ˜  d⃣ 	: char→sym(hk,'d',Ch['WinFile'    	],'Ch','WinFileLab')
      case ＄ ˜ ⇧d  	: char→sym(hk,'d',Ch['WinFile'    	],'Ch','WinFileLab')
      case ＄ ˜ v⁄  	: char→sym(hk,'/',Ch['WinFile'    	],'Ch','WinFileLab')
      case ＄ ˜ ⇧⁄  	: char→sym(hk,'/',Ch['WinFile'    	],'Ch','WinFileLab')
      case ＄ ˜  q⃣ 	: char→sym(hk,'q',Ch['XSymbols'   	],'Ch','XSymbolsLab')
      case ＄ ˜  p⃣ 	: char→sym(hk,'p',Ch['Currency'   	],'Ch','CurrLab')
      case ＄ ˜  x⃣ 	: char→sym(hk,'x',Ch['Tech'       	],'Ch','TechLab')
      case ＄ ˜  t⃣ 	: char→sym(hk,'t',Ch['Math'       	],'Ch','MathLab')
      case ＄ ˜ ⇧f  	: char→sym(hk,'f',Ch['Fractions'  	],unset,unset)
      case ＄ ˜  f⃣ 	: char→sym(hk,'f',Ch['Fractions'  	],unset,unset)
      case ＄ ˜  v⃣ 	: char→sym(hk,'v',Ch['Subscript'  	],'Ch','SubLab')
      case ＄ ˜  g⃣ 	: char→sym(hk,'g',Ch['Superscript'	],'Ch','SupLab')
      ;case ＄ ˜  m⃣	: char→sym(hk,'m',Ch['Dash'       	],Ch['DashLab'],'-')
      case ＄ ˜ v‐  	: char→sym(hk,'-',Ch['Dash'       	],'Ch','DashLab')
      ;case ＄ ˜  p⃣	: char→sym(hk,'p',Ch['XSymbols'   	],'Ch','XSymbolsLab')
      case ＄ ˜  r⃣ 	: char→sym(hk,'r',Ch['Checks'     	],'Ch','ChecksLab')
      case ＄ ˜  w⃣ 	: char→sym(hk,'w',Ch['Arrows'     	],'Ch','ArrowsLab')
      case ＄ ˜ v‘  	: char→sym(hk, "'",Ch['QuotesS'   	],unset,unset)
      case ＄ ˜ ⇧‘  	: char→sym(hk, "'",Ch['QuotesD'   	],unset,unset)
      case ＄ ˜ ⇧ˋ  	: char→sym(hk,'``',Ch['Para'      	],unset,unset)
      case ＄ ˜ ⇧5  	: char→sym(hk,'5',Ch['Percent'    	],unset,unset)
      case ＄ ˜ ⇧4  	: char→sym(hk,'4',Ch['Currency'   	],unset,unset)
    }
  }
}

global keyOnHold := ''
char→sym(hk,c,key_list,lblMap:=unset,lblKey:=unset,blind_:=true) { ;
  global keyOnHold ; store info on which key is being held to avoid repeating it
  static k   	:= keyConstant._map, lbl := keyConstant._labels ; various key name constants, gets vk code to avoid issues with another layout
   , get⎀    	:= win.get⎀.Bind(win), get⎀GUI	:= win.get⎀GUI.Bind(win), get⎀Acc := win.get⎀Acc.Bind(win)
   , s       	:= helperString

  static lbl_translit     	:= Map()
  if lbl_translit.Count   	= 0 { ; can set case only on empty maps
    lbl_translit.CaseSense	:= 0
  }

  vkC := s.key→ahk(c) ; vkC := Format("vk{:X}",GetKeyVK(c)) bugs with locale
  ; dbgTT(0,' hk=`t' hk '`nhkThis=`t' A_ThisHotkey '`nhkPrior=`t' A_PriorHotkey '`n kPrior=`t' A_PriorKey,t:=1)
  if keyOnHold == hk { ; previous key was the same, so we're KeyWaiting, don't repeat
    return
  }
  ; SendEvent((blind_ ? '{blind}' : '') '{' . vkC . ' down}{' . vkC . ' up}') ; (~ does this) type the char right away to avoid delays (to be deleted later on match), use {blind} to retain ⇧◆⎇⎈ positions)
  keyOnHold := hk
  lyt_from := 'en'
  if (KeyWait(vkC,TimerHold) = 0) {
    if keyOnHold == hk { ; (likely) no other key was pressed while this key was on hold
      if get⎀(&⎀←,&⎀↑) { ; editable text (no point in showing a picker if the picked char can't be inserted
        if    IsSet(lblMap)           	; Ch
          and IsSet(lblKey)           	; 'ArrowsLab'
          and   %lblMap%.Has(lblKey) {	; 1a arguments are set and map has labels
          local curlayout := lyt.GetCurLayout(&lytPhys, &idLang)
          sLng	:= lyt.getLocaleInfo('en',idLang) ; en/ru/... format
          if lbl.Has(sLng)
            and not sLng = 'en' { ; 2a keyboard non-en labels (qwerty...) exist for the target layout
            c_lbl_pos := InStr(lbl[lyt_from],c) ; c=w, pos=2
            c_to := c_lbl_pos ? SubStr(lbl[sLng],c_lbl_pos,1) : c
            dbgTT(2,'c=' c ' c_to =‘' c_to '’ c_lbl_pos' c_lbl_pos, t:=2) ;
            if %lblMap%.Has(lblKey sLng) { ; 3a map has labels for the target layout, use them
                PressH_ChPick(key_list,%lblMap%[lblKey sLng],c_to,'',[⎀←,⎀↑]) ; Ch['ArrowsLab' 'Ru']	:= [ф,ц,в
            } else { ; 3b no user labels, transliterate english ones and store in a static map for later retrieval
              if lbl_translit.Has(sLng) { ; 4a map contains cache of transliterated labels, use them
                PressH_ChPick(key_list,lbl_translit[sLng]   ,c_to,'',[⎀←,⎀↑])
              } else { ; 4b
                arrout := s.convert_lyt_arr(%lblMap%[lblKey],sLng,&ℯ:="") ;
                lbl_translit[sLng] := arrout
                PressH_ChPick(key_list,arrout               ,c_to,'',[⎀←,⎀↑])
              }
            }
          } else { ; 2b return the original (en) labels
                PressH_ChPick(key_list,%lblMap%[lblKey     ],c,'',[⎀←,⎀↑]) ; Ch['ArrowsLab']	:= [a,w,d
          }
        } else { ; 1b arguments not set or no labels in the map, return the original
                PressH_ChPick(key_list,unset                ,c)
        }
      } else { ;no ⎀
      }
    } else { ; keyOnHold ≠ hk
    }
  } else { ; else SendEvent('{' . vkC . ' up}')
  }
  keyOnHold := ''
  }

#MaxThreadsPerHotkey 1
#InputLevel 0
