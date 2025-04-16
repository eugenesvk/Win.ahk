#Requires AutoHotKey 2.1-alpha.4
; v1.1@23-10
#include <PressH> ; PressH_ChPick function located in /lib, TimerHold defined in AES section of aCommon.ahk
#MaxThreadsPerHotkey 2 ; 2 Allows A₁BA₂ fast typing, otherwise A₂ doesn't register
#InputLevel 1          ; Set the level for the following hotkeys so that they can activate lower-level hotstrings (autohotkey.com/docs/commands/SendLevel.htm)

; Use SendEvent for SpecialChars-Alt to recognize keys
setChar🠿()
setChar🠿() { ; hold key to select a symbol from a popup menu
  static k     	:= keyConstant._map ; various key name constants, gets vk code to avoid issues with another layout
   , s         	:= helperString
   , p         	:= helperPath
   , hk🛈       	:= keyFunc.hk🛈
   , pre       	:= '$~' ; use $kbd hook and don't ~block input to avoid typing lag
   ; , lbl🖰hide	:= ''
   ; , cfg🖰h   	:= cfg🖰convert()
  ; getKeys🖰hide(&lbl🖰hide) ; these hdotkeys override '🖰hide on 🖮', so we need to invoke pointer hiding here
  pfn := p.fname_(A_LineFile)

  HotIfWinActive("ahk_group PressnHold")
  ; `12345 67890 -=
  ;          i   []
  ;    df  hjkl; '\
  ;  z      m,.
  ;⇧ 123   67890 -=
  ;⇧ qw rt   i p []
  ;⇧   d g hjkl; '\
  ;⇧  x     m,.
  ; loop parse "abce/nosuyz'" { ; ⇧🠿a​⇧🠿b​⇧🠿c​⇧🠿e​⇧🠿/​⇧🠿n​⇧🠿o​⇧🠿s​⇧🠿u​⇧🠿y​⇧🠿z​⇧🠿'​  ;;; remove z to test a bug with ‹⎈
  ;   HotKey(pre s.key→ahk(    k[A_LoopField]), hkChar🠿, "T2")
  ;   HotKey(pre s.key→ahk('⇧' k[A_LoopField]), hkChar🠿, "T2")
  ; }
  hk🛈(pre "a​" 	,hkChar🠿,"T2",Map("h","Diacritics a"	,"t","🠿" ,"🔣",Dia['a'	].Join(" ") ,"f",pfn,"l№",A_LineNumber))
  hk🛈(pre "c​" 	,hkChar🠿,"T2",Map("h","Diacritics c"	,"t","🠿" ,"🔣",Dia['c'	].Join(" ") ,"f",pfn,"l№",A_LineNumber))
  hk🛈(pre "e​" 	,hkChar🠿,"T2",Map("h","Diacritics e"	,"t","🠿" ,"🔣",Dia['e'	].Join(" ") ,"f",pfn,"l№",A_LineNumber))
  hk🛈(pre "n​" 	,hkChar🠿,"T2",Map("h","Diacritics n"	,"t","🠿" ,"🔣",Dia['n'	].Join(" ") ,"f",pfn,"l№",A_LineNumber))
  hk🛈(pre "o​" 	,hkChar🠿,"T2",Map("h","Diacritics o"	,"t","🠿" ,"🔣",Dia['o'	].Join(" ") ,"f",pfn,"l№",A_LineNumber))
  hk🛈(pre "s​" 	,hkChar🠿,"T2",Map("h","Diacritics s"	,"t","🠿" ,"🔣",Dia['s'	].Join(" ") ,"f",pfn,"l№",A_LineNumber))
  hk🛈(pre "u​" 	,hkChar🠿,"T2",Map("h","Diacritics u"	,"t","🠿" ,"🔣",Dia['u'	].Join(" ") ,"f",pfn,"l№",A_LineNumber))
  hk🛈(pre "y​" 	,hkChar🠿,"T2",Map("h","Diacritics y"	,"t","🠿" ,"🔣",Dia['y'	].Join(" ") ,"f",pfn,"l№",A_LineNumber))
  hk🛈(pre "z​" 	,hkChar🠿,"T2",Map("h","Diacritics z"	,"t","🠿" ,"🔣",Dia['z'	].Join(" ") ,"f",pfn,"l№",A_LineNumber))
  hk🛈(pre "⇧a​"	,hkChar🠿,"T2",Map("h","Diacritics A"	,"t","🠿" ,"🔣",Dia['A'	].Join(" ") ,"f",pfn,"l№",A_LineNumber))
  hk🛈(pre "⇧c​"	,hkChar🠿,"T2",Map("h","Diacritics C"	,"t","🠿" ,"🔣",Dia['C'	].Join(" ") ,"f",pfn,"l№",A_LineNumber))
  hk🛈(pre "⇧e​"	,hkChar🠿,"T2",Map("h","Diacritics E"	,"t","🠿" ,"🔣",Dia['E'	].Join(" ") ,"f",pfn,"l№",A_LineNumber))
  hk🛈(pre "⇧n​"	,hkChar🠿,"T2",Map("h","Diacritics N"	,"t","🠿" ,"🔣",Dia['N'	].Join(" ") ,"f",pfn,"l№",A_LineNumber))
  hk🛈(pre "⇧o​"	,hkChar🠿,"T2",Map("h","Diacritics O"	,"t","🠿" ,"🔣",Dia['O'	].Join(" ") ,"f",pfn,"l№",A_LineNumber))
  hk🛈(pre "⇧s​"	,hkChar🠿,"T2",Map("h","Diacritics S"	,"t","🠿" ,"🔣",Dia['S'	].Join(" ") ,"f",pfn,"l№",A_LineNumber))
  hk🛈(pre "⇧u​"	,hkChar🠿,"T2",Map("h","Diacritics U"	,"t","🠿" ,"🔣",Dia['U'	].Join(" ") ,"f",pfn,"l№",A_LineNumber))
  hk🛈(pre "⇧y​"	,hkChar🠿,"T2",Map("h","Diacritics Y"	,"t","🠿" ,"🔣",Dia['Y'	].Join(" ") ,"f",pfn,"l№",A_LineNumber))
  hk🛈(pre "⇧z​"	,hkChar🠿,"T2",Map("h","Diacritics Z"	,"t","🠿" ,"🔣",Dia['Z'	].Join(" ") ,"f",pfn,"l№",A_LineNumber))

  hk🛈(pre "'​" 	,hkChar🠿,"T2",Map("h","QuotesS"	,"t","🠿" ,"🔣",ch␞('QuotesS'	).Join(" ") ,"f",pfn,"l№",A_LineNumber))
  hk🛈(pre "⇧'​"	,hkChar🠿,"T2",Map("h","QuotesD"	,"t","🠿" ,"🔣",ch␞('QuotesD'	).Join(" ") ,"f",pfn,"l№",A_LineNumber))
  hk🛈(pre "/​" 	,hkChar🠿,"T2",Map("h","WinFile"	,"t","🠿" ,"🔣",ch␞('WinFile'	).Join(" ") ,"f",pfn,"l№",A_LineNumber))
  hk🛈(pre "⇧/​"	,hkChar🠿,"T2",Map("h","WinFile"	,"t","🠿" ,"🔣",ch␞('WinFile'	).Join(" ") ,"f",pfn,"l№",A_LineNumber))
  hk🛈(pre "b​" 	,hkChar🠿,"T2",Map("h","Bullet" 	,"t","🠿" ,"🔣",ch␞('Bullet' 	).Join(" ") ,"f",pfn,"l№",A_LineNumber))
  hk🛈(pre "⇧b​"	,hkChar🠿,"T2",Map("h","Misc"   	,"t","🠿" ,"🔣",ch␞('Misc'   	).Join(" ") ,"f",pfn,"l№",A_LineNumber))

  ; loop parse "qwpxtvg-r" { ; 🠿q​🠿w​🠿p​🠿x​🠿t​🠿v​🠿g​🠿-​🠿r​ f used for home row mod h for exit insert mode
  ;   HotKey(pre s.key→ahk(    k[A_LoopField]), hkChar🠿, "T2")
  ; }
  hk🛈(pre "q​"	,hkChar🠿,"T2",Map("h","XSymbols"   	,"t","🠿" ,"🔣",ch␞('XSymbols'   	).Join(" ") ,"f",pfn,"l№",A_LineNumber))
  hk🛈(pre "w​"	,hkChar🠿,"T2",Map("h","Arrows"     	,"t","🠿" ,"🔣",ch␞('Arrows'     	).Join(" ") ,"f",pfn,"l№",A_LineNumber))
  hk🛈(pre "p​"	,hkChar🠿,"T2",Map("h","Currency"   	,"t","🠿" ,"🔣",ch␞('Currency'   	).Join(" ") ,"f",pfn,"l№",A_LineNumber))
  hk🛈(pre "x​"	,hkChar🠿,"T2",Map("h","Tech"       	,"t","🠿" ,"🔣",ch␞('Tech'       	).Join(" ") ,"f",pfn,"l№",A_LineNumber))
  hk🛈(pre "t​"	,hkChar🠿,"T2",Map("h","Math"       	,"t","🠿" ,"🔣",ch␞('Math'       	).Join("" ) ,"f",pfn,"l№",A_LineNumber))
  hk🛈(pre "v​"	,hkChar🠿,"T2",Map("h","Subscript"  	,"t","🠿" ,"🔣",ch␞('Subscript'  	).Join(" ") ,"f",pfn,"l№",A_LineNumber))
  hk🛈(pre "g​"	,hkChar🠿,"T2",Map("h","Superscript"	,"t","🠿" ,"🔣",ch␞('Superscript'	).Join(" ") ,"f",pfn,"l№",A_LineNumber))
  hk🛈(pre "r​"	,hkChar🠿,"T2",Map("h","Checks"     	,"t","🠿" ,"🔣",ch␞('Checks'     	).Join(" ") ,"f",pfn,"l№",A_LineNumber))
  hk🛈(pre "-​"	,hkChar🠿,"T2",Map("h","dash"       	,"t","🠿" ,"🔣",ch␞('Dash'       	).Join(" ") ,"f",pfn,"l№",A_LineNumber))

  ; loop parse "``45" { ; ⇧🠿`​⇧🠿4​⇧🠿5​⇧🠿f​
    ; HotKey(pre s.key→ahk('⇧' k[A_LoopField]), hkChar🠿, "T2")
  ; }
  hk🛈(pre "⇧``​"	,hkChar🠿,"T2",Map("h","Para"    	,"t","🠿" ,"🔣",ch␞('Para'    	).Join(" ") ,"f",pfn,"l№",A_LineNumber))
  hk🛈(pre "⇧4​" 	,hkChar🠿,"T2",Map("h","Currency"	,"t","🠿" ,"🔣",ch␞('Currency'	).Join(" ") ,"f",pfn,"l№",A_LineNumber))
  hk🛈(pre "⇧5​" 	,hkChar🠿,"T2",Map("h","Percent" 	,"t","🠿" ,"🔣",ch␞('Percent' 	).Join(" ") ,"f",pfn,"l№",A_LineNumber))

  ; loop parse "␠" { ; ⎈›⎇›␠​​ ⟶ various space symbols	(x) ;
  ;   ; HotKey(pre s.key→ahk('⎈›⎇›' k[A_LoopField]), hkChar🠿, "T2")
  ;   HotKey(pre s.key→ahk('⎈›⎇›' k[A_LoopField]), hkChar↓, "T2") ;;; todo make it work on press, need to rewrite logic in the function below that hkChar↓ calls
  ; }
  hk🛈(pre "⎈›⎇›␠"	,hkChar↓,"T2",Map("h","Space"	,"t","🠿" ,"🔣",Ch['Space'	].Join("") ,"f",pfn,"l№",A_LineNumber))

  HotIf
  WinActive_Not(active, not_active*) { ; = #Hotif WinActive("ahk_group PressnHold") and !WinActive("ahk_group Browser")
    if     WinActive(active) {
      for i in   not_active {
        if WinActive(i) {
          return false
        }
      }
      return true
    } else {
      return false
    }
  }
  HotIf (*) => WinActive_Not("ahk_group PressnHold", "ahk_group Browser") ; exclude Vivaldi to allow using vimium jkl;
  ; loop parse "l" { ; ⇧🠿l​
    ; HotKey(pre s.key→ahk(    k[A_LoopField]), hkChar🠿, "T2")
    ; HotKey(pre s.key→ahk('⇧' k[A_LoopField]), hkChar🠿, "T2")
  ; }
  hk🛈(pre "l​" 	,hkChar🠿,"T2",Map("h","Diacritics l"	,"t","🠿" ,"🔣",Dia['l'	].Join(" ") ,"f",pfn,"l№",A_LineNumber))
  hk🛈(pre "⇧l​"	,hkChar🠿,"T2",Map("h","Diacritics L"	,"t","🠿" ,"🔣",Dia['L'	].Join(" ") ,"f",pfn,"l№",A_LineNumber))
  HotIf
  HotIf (*) => WinActive_Not("ahk_group PressnHold", "ahk_group Browser") ; exclude Vivaldi to allow using vimium jkl;
  ; loop parse "i" { ; ⇧🠿i​
    ; HotKey(pre s.key→ahk('⇧' k[A_LoopField]), hkChar🠿, "T2")
  ; }
  hk🛈(pre "⇧i​"	,hkChar🠿,"T2",Map("h","Diacritics i"	,"t","🠿" ,"🔣",Dia['I'	].Join(" ") ,"f",pfn,"l№",A_LineNumber))
  HotIf
  HotIf (*) => WinActive_Not("ahk_group PressnHold", "ahk_group Browser","ahk_exe sublime_text.exe") ; exclude Vivaldi to allow using vimium jkl; and Sublime to allow 'i' to exit Insert
  ; loop parse "i" { ;  🠿i​
  ;   HotKey(pre s.key→ahk(    k[A_LoopField]), hkChar🠿, "T2")
  ; }
  hk🛈(pre "i​"	,hkChar🠿,"T2",Map("h","Diacritics i"	,"t","🠿" ,"🔣",Dia['i'	].Join(" ") ,"f",pfn,"l№",A_LineNumber))
  HotIf
  ; blind_ := false
  hkChar🠿(hk_dirty) {
    hk := StrReplace(StrReplace(hk_dirty,'~'),'$') ; other hotkeys may register first without ＄ ˜
    (dbg<5)?'':dbgTT(0,hk_dirty ' → ' hk,t:=1)
    ; flag := s.getKeyPrefixFlag(hk)
    ; is∗ := flag & f∗ ; any modifier allowed, so match both ‘a’ and ‘⇧a’
    ; is∗ := cfg🖰h['modiHide'] ; any modifier allowed, so match both ‘a’ and ‘⇧a’a
    global Ch
    Switch hk, 0 {
      default  : return ; dbgtt(0,'nothing matched setChar🠿 hk=' . hk, 4) ;
      ; Hotkey created → key name and ordering of its modifier symbols gets fixed
      ; —————————— Diacritic hk  c  key_list lblMap lblKey 🖰hide
      case  a⃣  :	char→sym(hk,Dia['a'],unset,unset,false) ;InStr(lbl🖰hide,'a'))
      case ⇧a  : 	char→sym(hk,Dia['A'],unset,unset,false) ;InStr(lbl🖰hide,'a') & is∗)
      case  c⃣  :	char→sym(hk,Dia['c'],unset,unset,false) ;InStr(lbl🖰hide,'c'))
      case ⇧c  : 	char→sym(hk,Dia['C'],unset,unset,false) ;InStr(lbl🖰hide,'c') & is∗)
      case  e⃣  :	char→sym(hk,Dia['e'],unset,unset,false) ;InStr(lbl🖰hide,'e'))
      case ⇧e  : 	char→sym(hk,Dia['E'],unset,unset,false) ;InStr(lbl🖰hide,'e') & is∗)
      case  i⃣  :	char→sym(hk,Dia['i'],unset,unset,false) ;InStr(lbl🖰hide,'i'))
      case ⇧i  : 	char→sym(hk,Dia['I'],unset,unset,false) ;InStr(lbl🖰hide,'i') & is∗)
      case  l⃣  :	char→sym(hk,Dia['l'],unset,unset,false) ;InStr(lbl🖰hide,'l'))
      case ⇧l  : 	char→sym(hk,Dia['L'],unset,unset,false) ;InStr(lbl🖰hide,'l') & is∗)
      case  n⃣  :	char→sym(hk,Dia['n'],unset,unset,false) ;InStr(lbl🖰hide,'n'))
      case ⇧n  : 	char→sym(hk,Dia['N'],unset,unset,false) ;InStr(lbl🖰hide,'n') & is∗)
      case  o⃣  :	char→sym(hk,Dia['o'],unset,unset,false) ;InStr(lbl🖰hide,'o'))
      case ⇧o  : 	char→sym(hk,Dia['O'],unset,unset,false) ;InStr(lbl🖰hide,'o') & is∗)
      case  s⃣  :	char→sym(hk,Dia['s'],unset,unset,false) ;InStr(lbl🖰hide,'s'))
      case ⇧s  : 	char→sym(hk,Dia['S'],unset,unset,false) ;InStr(lbl🖰hide,'s') & is∗)
      case  u⃣  :	char→sym(hk,Dia['u'],unset,unset,false) ;InStr(lbl🖰hide,'u'))
      case ⇧u  : 	char→sym(hk,Dia['U'],unset,unset,false) ;InStr(lbl🖰hide,'u') & is∗)
      case  y⃣  :	char→sym(hk,Dia['y'],unset,unset,false) ;InStr(lbl🖰hide,'y'))
      case ⇧y  : 	char→sym(hk,Dia['Y'],unset,unset,false) ;InStr(lbl🖰hide,'y') & is∗)
      case  z⃣  :	char→sym(hk,Dia['z'],unset,unset,false) ;InStr(lbl🖰hide,'z'))
      case ⇧z  : 	char→sym(hk,Dia['Z'],unset,unset,false) ;InStr(lbl🖰hide,'z') & is∗)
      ; —————————— Alt symbols (math, currency etc.)
      ;          	           hk  c  key_list     	 lblMap lblKey 🖰hide
      case  b⃣   	: char→sym(hk,ch␞('Bullet'     	),unset,'a',false) ;InStr(lbl🖰hide,'b'))
      case ⇧b    	: char→sym(hk,ch␞('Misc'       	),unset,'a',false) ;InStr(lbl🖰hide,'b') & is∗)
      case  d⃣   	: char→sym(hk,ch␞('WinFile'    	),&Ch,'WinFileLab') ;
      case ⇧d    	: char→sym(hk,ch␞('WinFile'    	),&Ch,'WinFileLab',false) ;InStr(lbl🖰hide,'d') & is∗)
      case v⁄    	: char→sym(hk,ch␞('WinFile'    	),&Ch,'WinFileLab')
      case ⇧⁄    	: char→sym(hk,ch␞('WinFile'    	),&Ch,'WinFileLab',false) ;InStr(lbl🖰hide,'/') & is∗)
      case  q⃣   	: char→sym(hk,ch␞('XSymbols'   	),&Ch,'XSymbolsLab',false) ;InStr(lbl🖰hide,'q'))
      case  p⃣   	: char→sym(hk,ch␞('Currency'   	),&Ch,'CurrLab',false) ;InStr(lbl🖰hide,'p'))
      case  x⃣   	: char→sym(hk,ch␞('Tech'       	),&Ch,'TechLab',false) ;InStr(lbl🖰hide,'x'))
      case  t⃣   	: char→sym(hk,ch␞('Math'       	),&Ch,'MathLab',false) ;InStr(lbl🖰hide,'t'))
      case ⇧f    	: char→sym(hk,ch␞('Fractions'  	),unset,'a',false) ;InStr(lbl🖰hide,'f'))
      case  f⃣   	: char→sym(hk,ch␞('Fractions'  	),unset,'a',false) ;InStr(lbl🖰hide,'f'))
      case  v⃣   	: char→sym(hk,ch␞('Subscript'  	),&Ch,'SubLab',false) ;InStr(lbl🖰hide,'v'))
      case  g⃣   	: char→sym(hk,ch␞('Superscript'	),&Ch,'SupLab',false) ;InStr(lbl🖰hide,'g'))
      ;case  m⃣  	: char→sym(hk,ch␞('Dash'       	),Ch['DashLab'],'-',false) ;InStr(lbl🖰hide,''))
      case v‐    	: char→sym(hk,ch␞('Dash'       	),&Ch,'DashLab')
      ;case  p⃣  	: char→sym(hk,ch␞('XSymbols'   	),&Ch,'XSymbolsLab',false) ;InStr(lbl🖰hide,''))
      case  r⃣   	: char→sym(hk,ch␞('Checks'     	),&Ch,'ChecksLab',false) ;InStr(lbl🖰hide,'r'))
      case  w⃣   	: char→sym(hk,ch␞('Arrows'     	),&Ch,'ArrowsLab',false) ;InStr(lbl🖰hide,'w'))
      case v‘    	: char→sym(hk,ch␞('QuotesS'    	),unset,'a')
      case ⇧‘    	: char→sym(hk,ch␞('QuotesD'    	),unset,'a',false) ;InStr(lbl🖰hide,'`'') & is∗)
      case ⇧ˋ    	: char→sym(hk,ch␞('Para'       	),unset,unset,false) ;InStr(lbl🖰hide,'``') & is∗)
      case ⇧5    	: char→sym(hk,ch␞('Percent'    	),unset,"1",false) ;InStr(lbl🖰hide,'5') & is∗)
      case ⇧4    	: char→sym(hk,ch␞('Currency'   	),unset,"1",false) ;InStr(lbl🖰hide,'4') & is∗)
      case ⎈›⎇›␠⃣	: char→sym(hk,ch␞('Space'      	),&Ch,'SpaceLab2',false,false,false) ;
    }
  }
  hkChar↓(hk_dirty) {
    hk := StrReplace(StrReplace(hk_dirty,'~'),'$') ; other hotkeys may register first without ＄ ˜
    (dbg<5)?'':dbgTT(0,hk_dirty ' → ' hk,t:=1)
    ; flag := s.getKeyPrefixFlag(hk)
    ; is∗ := flag & f∗ ; any modifier allowed, so match both ‘a’ and ‘⇧a’
    ; is∗ := cfg🖰h['modiHide'] ; any modifier allowed, so match both ‘a’ and ‘⇧a’a
    global Ch
    Switch hk, 0 {
      default  : return ; dbgtt(0,'nothing matched setChar🠿 hk=' . hk, 4) ;
      ; Hotkey created → key name and ordering of its modifier symbols gets fixed
      ; —————————— Alt symbols (math, currency etc.)
      ;          	           hk  c  key_list  	 lblMap lblKey 🖰hide
      case ⎈›⎇›␠⃣	: char→sym(hk,Ch['Space'	],&Ch,'SpaceLab2',false,false,false) ;
      ;
    }
  }
}

ch␞(lbl) { ; remove ␞ from the list
  arr_in := Ch[lbl]
  arr_out := []
  arr_out.Capacity := arr_in.Length
  for val in arr_in {
    if val != ␞ {
      arr_out.push(val)
    }
  }
  return arr_out
}
global keyOnHold := ''
char→sym(hk,key_list,&lblMap:=unset,lblKey:=unset,🖰hide:=0,pis␈:=true,can␠ins:=true,blind_:=true) {
  ; lblKey: when no Map given, used as the starting key in automatic label list so you can start from Qwe instead of `123
  global keyOnHold ; store info on which key is being held to avoid repeating it
  static k	:= keyConstant._map, lbl := keyConstant._labels ; various key name constants, gets vk code to avoid issues with another layout
   , get⎀ 	:= win.get⎀.Bind(win), get⎀GUI	:= win.get⎀GUI.Bind(win), get⎀Acc := win.get⎀Acc.Bind(win)
   , s    	:= helperString
   , _d3  	:= 3 ;
  ; if 🖰hide { ; hide a pointer if the same key is registered twice since only this function will be called
  ;   hk🖰PointerHide('') ; use hk function instead of 🖰PointerHide due to a bug in '🖰hide on 🖮'?
  ; }
  static lbl_translit     	:= Map()
  if lbl_translit.Count   	= 0 { ; can set case only on empty maps
    lbl_translit.CaseSense	:= 0
  }

  modi_f := s.ahk→modi_f(&hk)
  s.parseKeyCombo(hk,&armod,&vkC)
  c := GetKeyName(vkC)
  ; dbgtt(0,'got char→sym hk`t=' hk ' `nkeyOnHold`t=' keyOnHold '`nvkC`t=' vkC, 3) ;
  ; vkC := s.key→ahk(c) ; vkC := Format("vk{:X}",GetKeyVK(c)) bugs with locale
  ; dbgtt(0,"c = " c " vkC=" vkC " f=" modi_f,2) ;
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
        c⇧⸮ := (f⇧ & modi_f) ? s.ch→⇧(&c) : c ; get shifted char if ⇧X combo triggered
        (dbg<_d3)?'':(dbgtt(_d3,c ((f⇧ & modi_f)?" ⇧" c⇧⸮:""),🕐:=5,,x:=0,y:=0))
        if    IsSet(lblMap)         	; Ch
          and IsSet(lblKey)         	; 'ArrowsLab'
          and   lblMap.Has(lblKey) {	; 1a arguments are set and map has labels
          local curlayout := lyt.GetCurLayout(&lytPhys, &idLang)
          sLng	:= lyt.getLocaleInfo('en',idLang) ; en/ru/... format
          if lbl.Has(sLng)
            and not sLng = 'en' { ; 2a keyboard non-en labels (qwerty...) exist for the target layout
            c_lbl_pos := InStr(lbl[lyt_from],c⇧⸮) ; c=w, pos=2
            c_to := c_lbl_pos ? SubStr(lbl[sLng],c_lbl_pos,1) : c⇧⸮
            dbgTT(2,'c=' c ' c_to =‘' c_to '’ c_lbl_pos' c_lbl_pos, t:=2) ;
            if lblMap.Has(lblKey sLng) { ; 3a map has labels for the target layout, use them
                PressH_ChPick(key_list,lblMap[lblKey sLng],c_to,'',[⎀←,⎀↑],pis␈,can␠ins) ; Ch['ArrowsLab' 'Ru']	:= [ф,ц,в
            } else { ; 3b no user labels, transliterate english ones and store in a static map for later retrieval
              if lbl_translit.Has(sLng) { ; 4a map contains cache of transliterated labels, use them
                PressH_ChPick(key_list,lbl_translit[sLng]   ,c_to,'',[⎀←,⎀↑],pis␈,can␠ins)
              } else { ; 4b
                arrout := s.convert_lyt_arr(lblMap[lblKey],sLng,&ℯ:="") ;
                lbl_translit[sLng] := arrout
                PressH_ChPick(key_list,arrout               ,c_to,'',[⎀←,⎀↑],pis␈,can␠ins)
              }
            }
          } else { ; 2b return the original (en) labels
                PressH_ChPick(key_list,lblMap[lblKey     ],c⇧⸮,'',[⎀←,⎀↑],pis␈,can␠ins) ; Ch['ArrowsLab']	:= [a,w,d
          }
        } else { ; 1b arguments not set or no labels in the map, return the original
          if IsSet(lblKey) && (Type(lblKey)="String") {
                PressH_ChPick(key_list,lblKey               ,c⇧⸮,'',[⎀←,⎀↑],pis␈,can␠ins)
          } else {
                PressH_ChPick(key_list,                     ,c⇧⸮,'',[⎀←,⎀↑],pis␈,can␠ins)
          }
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
