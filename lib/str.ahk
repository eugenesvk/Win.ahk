#Requires AutoHotKey 2.1-alpha.4
#Include %A_scriptDir%\gVar\symbol.ahk	; Global vars (diacritic symbols and custom chars)
#Include <constKey>                   	; various key constants
; —————————— String functions ——————————
class helperPath { ; basic, not properly tested, e.g., \\c paths don't work
  static file_full(&s) {
    ; if RegExMatch(s, "^(\w:)\\(.+\\)*(.+)\.(.+)$" , &G) { ; fails with folders only
      ; dbgtt(0,G[0] "`n1=" G[1] "`n2=" G[2] "`n3=" G[3] "`n4=" G[4],5)
      ; 1 drive 2 Dir 3 File 4 Ext
    if RegExMatch(s, "[^\/\\]+$" , &G) {
      return G[0]
    } else {
      return ""
    }
  }
  static file_name_(s) {
    return helperPath.file_name(&s)
  }
  static fname_(s) {
    return helperPath.file_name(&s)
  }
  static file_name(&s) {
    return RegExReplace(helperPath.file_full(&s), "\.\w*$", "")
  }
  static fname(&s) {
    return helperPath.file_name(&s)
  }
  static file_ext(&s) {
    if RegExMatch(s, "(\.)(\w*)$" , &G) {
      return G[1]
    } else {
      return ""
    }
  }
  static ext(&s) {
    return helperPath.file_ext(&s)
  }
}

class helperString {
  static __new() { ; fill the map
    this.fillKeyList()
  }
  static lstrip(&s) {
    return NewStr := RegExReplace(s, "^\s*", "")
  }
  static remove_at_start(&where, what) {
    if what =  SubStr(where, 1,  StrLen(what)) { ; beginning matches
      where := SubStr(where, 1 + StrLen(what))   ; replace the beginning
      return true
    }
  }
  static replace_at_start(&where, &replace_map) {
    if type(replace_map) = "Map" {
      for  s_from, s_to in replace_map {
        if s_from =       SubStr(where, 1,  StrLen(s_from)) { ; beginning matches
          where := s_to . SubStr(where, 1 + StrLen(s_from))   ; replace the beginning
          return true
        }
      }
    }
  }
  static replace_anywhere(&where, &replace_map) {
    static replaceAll := -1
    if type(replace_map) = "Map" {
      for  s_from, s_to in replace_map {
        where := StrReplace(where, s_from, s_to, isCase:=1,,replaceAll)
        return true
      }
    }
  }
  static get_last_match_backwards(s_in, &match_map) { ; iterates from the back of the string and returns the Map with longest match from a map of matches (also includes match position and substitute from match_map)
    ; abcd → cd if map(d,r1  , cd,r2)
    s_len         	:= StrLen(s_in)
    isMatched     	:= false
    pos_match_last	:= 0
    pre := "", pos := "", sub := ""
    set_ret_vars() {
      pre	:= SubStr(s_in,1             ,pos_match_last - 1)
      pos	:= SubStr(s_in,pos_match_last)
      sub	:= match_map[pos]
    }
    loop s_len {
      pos	:= s_len - A_Index + 1
      s_back := SubStr(s_in, pos)
      if match_map.Has(s_back) { ; matched, record position
        isMatched     	:= true
        pos_match_last	:= pos
        if A_Index = s_len { ; last iteration, set ret vars
          set_ret_vars()
        }
        continue
      } else if not isMatched  { ; never found, continue searching
        continue
      } else if pos_match_last { ; no match, but there was one earlier, so record it and break to return
        set_ret_vars()
        break
      }
    }
    return Map('i',pos_match_last ,'pre',pre ,'pos',pos ,'sub',sub)
  }
  static replace_illegal_id(s_in) { ; replaces illegal identifiers (function names) with unicode alternatives like ; →︔
    static repl_map := Map(';','︔', ',','⸴' ,'.','．'  ,'/','⁄' ,'\','⧵')
    for from,to in repl_map {
      s_in := StrReplace(s_in, from,to)
    }
    return s_in
  }


  static getKeyPrefixFlag(hk) { ; get prefix bitflags for a key combo (~$vk41 → f＄|f˜ = 6)
    flag := 0
    flag	|= InStr(hk,'$') ? f＄ : 0	; keyboard hook on
    flag	|= InStr(hk,'~') ? f˜ : 0	; passthru native key
    flag	|= InStr(hk,'*') ? f∗ : 0	; any modifiers allowed
    return flag
  }
  static modi_ahk→sym_ahk(modi) { ; get ahk symbolic string for a modifier: LShift → <+
    return helperString.modi_ahk→sym_any(modi,'ahk')
  }
  static modi_ahk→sym(modi) { ; get symbolic string for a modifier: LShift → ‹⇧
    return helperString.modi_ahk→sym_any(modi)
  }
  static modi_ahk→sym_any(modi,fmt:='') { ; get symbolic string for a modifier: LShift → ‹⇧
    static modiSym := Map( ; helps generating the full map
      'Shift'  	,{sym:'⇧'	,ahk:'+'},
      'Ctrl'   	,{sym:'⎈'	,ahk:'^'},
      'Control'	,{sym:'⎈'	,ahk:'^'},
      'Win'    	,{sym:'◆'	,ahk:'#'},
      'Alt'    	,{sym:'⎇'	,ahk:'!'},
      )
    if not type(modi) = 'String'
      or not modi
      or StrLen(modi) < 2 {
      throw ValueError("Input modifier should be a string of 2+ chars", -1, modi)
    }
    side_in    	:= SubStr(modi,1,1)
    , mod_in   	:= SubStr(modi,2)
    , side_outL	:= ''
    , side_outR	:= ''
    , mod_out  	:= ''
    if        side_in = 'L' {
      side_outL	.= fmt = 'ahk' ? '<' : '‹'
    } else if side_in = 'R' {
      side_outL	.= fmt = 'ahk' ? '>' : ''
      side_outR	.= fmt = 'ahk' ? '' : '›'
    }
    mod_out_arr	:= modiSym.Get(mod_in,['',''])
    mod_out    	:= fmt = 'ahk' ? mod_out_arr.ahk : mod_out_arr.sym
    if (side_outL || side_outR) && mod_out {
      return side_outL . mod_out . side_outR
    } else {
      return ''
    }
  }
  static modis→ahk(key_combo) { ; get ahk string with the last modifier considered a non-mod key: ⎇›‹⎈ → >!LCtrl
    static vk	:= keyConstant._map ; various key name constants, gets vk code to avoid issues with another layout
    modi_ahk_arr_full := this.parseKeyCombo(key_combo,&modi_ahk_arr_short:=[],&nonmod:="") ; ⎇›‹⎈ → >! >^
    if modi_ahk_arr_full.Length = 0 {
      return ""
    }
    modi_ahk_s := ""
    loop modi_ahk_arr_short.Length -1 {
      modi_ahk_s .= modi_ahk_arr_short[A_Index] ; ⎇›‹⎈ → >!, skipping the last
    }
    modi_ahk_s .= modi_ahk_arr_full[-1] ; last ‹⎈ → LCtrl
    return modi_ahk_s
  }
  static key→ahk(key_combo,kT:='vk',sep:='',lng:='en',isSend:=false) { ; get ahk string ⎇›‹⎈a → >!<^vk41 (or if no alpha, ⎇›‹⎈ → >!LCtrl ), isSend encloses the ending chars in {} to allow using the result in Send()
    ; sep like & is added before the last key
    static vk	:= keyConstant._map ; various key name constants, gets vk code to avoid issues with another layout
     , sc    	:= keyConstant._mapsc
    if not ((kT="sc") or (kT="vk")) {
      throw ValueError("Parameter #2 invalid, key type should be either ‘vk’ or ‘sc’", -1)
    }
    modi_ahk_arr_full := this.parseKeyCombo(key_combo,&modi_ahk_arr_short:=[],&nonmod:="")
    modi_ahk_s := ""
    for modi in modi_ahk_arr_short {
      modi_ahk_s .= modi
    }
    sep := (sep = '&') ? ' & ' : sep ; add spaces
    if        SubStr(nonmod,1,2) = kT { ; key already passed in its ahk form, passthru
      return modi_ahk_s . sep .      nonmod
    } else if StrLen(nonmod) > 0 {
      if not lng = 'en'
        and %kT%.Has(lng)
        and %kT%[lng].Has(nonmod) { ; localize last key if a local map exists not to treat . as always english
        key_ahk := %kT%[lng].Get(nonmod,'')
      } else {
        key_ahk := %kT%.Get(     nonmod,'')
      }
      if isSend {
        return key_ahk='' ? '' : modi_ahk_s . '{' . key_ahk . '}'
      } else {
        return key_ahk='' ? '' : modi_ahk_s . sep . key_ahk
      }
    } else {
        return modi_ahk_s
    }
  }
  static key→send(key_combo,kT:='vk',sep:='',lng:='en',isSend:=true) {
    return this.key→ahk(key_combo,kT,sep,lng,isSend)
  }
  static parseModifierList(modlist) { ; convert a string of modifiers into an array list of AHK key names: ‹⇧⇧ → [LShift,Shift]
    return this.parseKeyCombo(modlist,&_s:=[],&_:=0)
  }

  static ch→⇧(&c_in) { ; get shifted char, e.g., 1→!
    return helperString.get_char(&c_in, f⇧)
  }
  static ch→name(&c_in) { ; get locale-specific char, e.g., q→q or q→й if Russian is active
    return helperString.get_char(&c_in)
  }
  static get_char(&c_in, flag:=0) { ; get locale-specific char, e.g., q→q or q→й if Russian is active, ⇧Shifted is f⇧ is passed
    static vk⇧ := 0x10 ; learn.microsoft.com/en-us/windows/win32/inputdev/virtual-key-codes
      , key↓ := 0x80 ; 0b10000000 most-significant bit of a byte
    lpKeyState := Buffer(256,0), pwszBuff := Buffer(4)
    if flag = f⇧ {
      NumPut("char",key↓, lpKeyState,vk⇧)
    }
    HKL := lyt.GetCurLayout()
    len := DllCall("ToUnicodeEx" ; learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-tounicode
      ,"uint",GetKeyVK(c_in) ;←
      ,"uint",GetKeySC(c_in) ;←
      , "ptr",lpKeyState     ;←? ptr to 256-byte array that contains the current keyboard state
        ; Each element (byte) in the array contains the state of 1 key
        ; high-order bit of a byte if set: ↓key is down
        ; low -order bit           if set:  key is toggled on (only relevant for ⇪ CAPS LOCK, Num/Scroll are ignored, see GetKeyboardState)
      , "ptr",pwszBuff     	;→
      , "int",pwszBuff.size	;←
      ,"uint",0            	;← wFlags
      , "ptr",HKL          	;←? dwhkl
    )
    if len <= 0 { ;<0 virtual key is a dead key character (accent or diacritic) 0=no translation
      return c_in
      ; throw Error("There was a problem converting the character")
    }
    return StrGet(pwszBuff, len, "UTF-16")
  }

  static key→token(key_lbl) { ; key ; → ︔ token to be used in var names, leave other home row modes intact
    static K     	:= keyConstant , lbl := K._labels, token := K._ahk_token  ; various key name constants, gets vk code to avoid issues with another layout
      , lbl_token	:= Map()
      , isInit   	:= false
    if not isInit {
      lbl_token.CaseSense := 0 ; make key matching case insensitive
      loop Parse lbl['en'] {
        lbl_token[A_LoopField]  := SubStr(token['en'],A_Index,1)
      }
      isInit := true
    }
    return lbl_token.Get(key_lbl,key_lbl)
  }
  static convert_lyt_arr(arrIn, lyt_to, &ℯ, lyt_from:="en") { ;→array convert an array from one layout to anouther
    static k              	:= keyConstant._map, lbl := keyConstant._labels ; various key name constants, gets vk code to avoid issues with another layout
    static lbl_translit   	:= Map()
    lbl_translit.CaseSense	:= 0

    if lyt_from = lyt_to {
      return arrIn
    }
    if not Type(arrIn) = "Array" {
      throw ValueError('Argument #1 (arrIn) is not an ‘Array’!', -1)
    }
    if not Type(ℯ) = "String" {
      throw ValueError('Argument #3 (error) is not an ‘Array’!', -1)
    }
    if not lbl.Has(lyt_from) {
      throw ValueError('Layout ‘' lyt_from '’ is not supported!', -1)
    }
    if not lbl.Has(lyt_to) {
      throw ValueError('Layout ‘' lyt_to '’ is not supported!', -1)
    }
    arrOut := Array()
    arrOut.Capacity := arrIn.Length
    for c in arrIn {
      if (c_lbl_pos := InStr(lbl[lyt_from], c)) {
        c_to := SubStr(lbl[lyt_to],c_lbl_pos,1)
        arrOut.push(c_to)
      } else { ; symbol not found, return self, but also add it to the error array
        arrOut.push(c)
        ℯ .= c
      }
    }
    return arrOut
  }

  static _ttt:=0
     , modiArr := [] ; array [‹⇧ , LShift] (preserves insertion order)
     , modiMap := Map() ; map of ‹⇧ : LShift (NOT ordered, but useful for .Has method)
     , modi_ahk_map := Map() ; map of ahk full names to abbreviated names: LShift → <!
     , modi_f_map := Map() ; map of ahk modi symbols to flags: <! → f‹⎇
     , modiMapTemplate := Map( ; helps generating the full map
      'Shift'	,['Shift', '⇧', 'Shift'    	,'+']   	, ; last values should be AHK abbreviations!
      'Ctrl' 	,['Ctrl' , '⎈' , '⌃'       	,'^' ]  	,
      'Win'  	,['Win'  , '◆'  , '❖' , '⌘'	,'#']   	,
      'Alt'  	,['Alt'  , '⎇'  , '⌥'      	, '!'  ]	,
      )
     , sideIndicTemplate	:= [Map('@L',Map('prefix','L', 'symbol',['‹','<'])) ; last values should be AHK abbreviations!
       ,                	    Map('@R',Map('prefix','R', 'symbol',['›'])
       ,                	        '@L',Map('prefix','R', 'symbol',[    '>'])) ; Autohotkey places right modifiers at the left side >!
       ]
     , all_whitespace := '[\p{Cf}\p{Z}\h\v]' ; remove whitespace and allow & in function names (cf-invisible formatting Z-ws or invis separator \h\v horizontal/vertical whitespace)
  static fillKeyList() {
    static isInit := false
    if not isInit {
      this.modiMap.CaseSense := 0 ; make modifier matching case insensitive
    }
    if not isInit { ; Generate full map with sides
      for modi in  this.modiMapTemplate {    	; Shift
        arrModi := this.modiMapTemplate[modi]	; [Shift,⇧ ... +
        for i, modiNm in arrModi { ; ⇧
          ; add side-aware keys
          for mAtSide in this.sideIndicTemplate {	; side indicator map:      Left or Right
            for sideLoc, mIndic in mAtSide {      ;      indicator location @L    or @R side
              arLsideR	:= mIndic['prefix']  ; L or R
              ar‹side›	:= mIndic['symbol']
              for sym‹› in ar‹side› {
                if        (sideLoc = '@L') { ;‹⇧             LShift                               <+
                  ahk_full := [sym‹› . modiNm        , arLsideR . modi, ar‹side›[-1]               . arrModi[-1]]
                } else if (sideLoc = '@R') { ; ⇧›            RShift                               >+
                  ahk_full := [        modiNm . sym‹›, arLsideR . modi, mAtSide['@L']['symbol'][-1] . arrModi[-1]]
                }
                this.modiArr.Push(  ahk_full)                  	; ‹⇧    → LShift (also <+)
                this.modiMap[       ahk_full[1]] := ahk_full[2]	; ‹⇧    → LShift
                this.modi_ahk_map[  ahk_full[1]] := ahk_full[3]	; ‹⇧    → <+
                this.modi_ahk_map[  ahk_full[2]] := ahk_full[3]	; LShift → <+
              }
            }
          }
          ; add anyside keys
          arLsideR	:= (modi="Win") ? "L" : "" ; Win has no generic button, always use LWin
          sym‹›   	:= (modi="Win") ? "<" : "" ; Win has no generic button, always use LWin
          this.modiArr.Push(  [        modiNm        ,  arLsideR . modi])   ; ⇧    → Shift
          this.modiMap[                modiNm]       := arLsideR . modi	    ; ⇧    → Shift
          this.modi_ahk_map[           modiNm]       := sym‹› . arrModi[-1] ; ⇧    → +
          this.modi_ahk_map[arLsideR . modi  ]       := sym‹› . arrModi[-1] ; Shift → +
        }
        ; add flags
        key  	:= arrModi[-1]
        fvar 	:= 'f' .       arrModi[2]
        f‹var	:= 'f' . '‹' . arrModi[2]
        fvar›	:= 'f'       . arrModi[2] . '›'
        this.modi_f_map[    key] := %fvar%
        this.modi_f_map['<' key] := %f‹var%
        this.modi_f_map['>' key] := %fvar›%
      }
      isInit := true
    }
  }

  static parseKeyCombo(key_combo,&modi_ahk_arr_short,&nonmod) { ; convert a key combo string into an array/string of modifiers and returns the unparsed string remainder
    ; converts the last modifier to full format LCtrl if only modifiers are passed (matches string from the end, so non-mods break match)
      ; ⇧⎈›   +RControl
      ; ⇧⎈›a  >^+ vk41
    arrOut := []
    static isInit := false
    this.fillKeyList()

    key_combo := RegExReplace(key_combo,this.all_whitespace,'')
    ; key_combo_clean := key_combo ; save to later find the last modifier

    ; Now parse the input key_combo
    modi_last_map	:= this.get_last_match_backwards(key_combo,&this.modiMap)
    isLastMod    	:= modi_last_map['i']
    lastMod      	:= ""
    if isLastMod {
      key_combo	:= modi_last_map['pre'] ; cut off the last modifier key ⎈› ...
      lastMod  	:= modi_last_map['sub'] ; add it later, but always as a full substitute RCtrl
    }

    ; outModi_ahk_arr_user := [] ; ‹⇧
    outModi_ahk_arr_full := [] ; LShift
    findModi(where) {
      for i, arr in this.modiArr {
      modi_user    	:= arr[1] ; ‹⇧
      modi_ahk_full	:= arr[2] ; LShift
        if InStr(key_combo, modi_user) { ; found user modi
          return [modi_user, modi_ahk_full]
        }
      }
      return false
    }
    modi2_ahk_arr(mod_arr) {
      mod_arr_short := []
      for modi in mod_arr {
        mod_arr_short.Push(this.modi_ahk_map[modi]) ; ^+ instead of LShift
      }
      return mod_arr_short
    }
    move_last_modi_to_end(&mod_arr_full,mod_arr_user, nonmod, original) {
      mods_parseable := StrReplace(original,nonmod,"") ; remove unparsed part
      for modi in mod_arr_user {
        ; dbgTT(0,mods_parseable,t:=3)
        if (foundLast := RegExMatch(mods_parseable, modi . "$")) {
          modi_last_full := mod_arr_full[A_Index]
          mod_arr_full.RemoveAt(A_Index) ; move found modifier to the end
          mod_arr_full.Push(modi_last_full) ;
          return
        }
      }
    }

    loop StrLen(key_combo) {	; loop at most the number of chars in the string
      if  (got_modi := findModi(key_combo)) {
        modi_user    	:= got_modi[1]  ; ‹⇧
        modi_ahk_full	:= got_modi[2]  ; LShift
        ; outModi_ahk_arr_user.Push(modi_user)
        outModi_ahk_arr_full.Push(modi_ahk_full)
        key_combo := StrReplace(key_combo, modi_user,'',,,1)
      } else {
        break
      }
    }
    nonmod := key_combo
    ;;;move_last_modi_to_end(&outModi_ahk_arr_full,outModi_ahk_arr_user,nonmod,key_combo_clean)
    modi_ahk_arr_short := modi2_ahk_arr(outModi_ahk_arr_full)
    modi_ahk_arr_short  .Push(lastMod)
    outModi_ahk_arr_full.Push(lastMod)
    return outModi_ahk_arr_full
  }


  static symSp(s) { ; convert a symbol to it's approximate space width using variable-width spaces
    static isInit := false
     ,ch2sp := Map()
    if not isInit {
      isInit := true
      ch2sp.CaseSense := 0
      ch2sp['‹'] := (
            ' ') ; [    ]
      ch2sp['›'] := (
            ' ')
      ch2sp['⇧'] := (
            '   ')
      ch2sp['◆'] := (
            '   ')
      ch2sp['⎇'] := (
            '   ')
      ch2sp['⎈'] := (
            '   ')
      ch2sp['⇪'] := (
            ' ')
      ch2sp['⇭'] := (
            ' ')
      ch2sp['⇳🔒'] := (
            '  ')
    }
    outtxt := ''
    loop parse s {
      outtxt .= ch2sp.Get(A_LoopField, ' ')
    }
    return outtxt
  }
  static whichModStatus() { ; convert mod flags into a string with both hook ("physical") and logical views
    static K  	:= keyConstant , vk := K._map, sc := K._mapsc  ; various key name constants, gets vk code to avoid issues with another layout
     , s      	:= helperString ; K.▼ = vk['▼']
     , →␠     	:= s.symSp.Bind(s)
     , modi   	:= ['⇧','◆','⎇','⎈'] ; todo replace with constkey symbols
     , toggles	:= ['⇪','⇭','⇳🔒','c⎉','⭾']
     , combo⎈ 	:= ['c⎉']
    dbglogic:='logic`t', dbghook:='hook`t', dbgcount := 1
    ; 'P' state isn't really physical (it's impossible to track at AHK level), but what Keyboard Hook reports and AHK records (so another hook from another app may interfere)
    for i,m in modi { ; left modifiers
      l        	:= '‹' m
      l_ahk    	:= s.modis→ahk(l)
      dbglogic 	.= (GetKeyState(l_ahk    ) ? (l ' '):(→␠(l) ' '))
      dbghook  	.= (GetKeyState(l_ahk,"P") ? (l ' '):(→␠(l) ' '))
      ;dbglogic	.= (GetKeyState(l_ahk    ) ? (l ' '):'  ' ' ')
      ;dbghook 	.= (GetKeyState(l_ahk,"P") ? (l ' '):'  ' ' ')
    }
    for i,m in modi { ; right modifiers
      m       	:= modi[modi.length - i + 1] ; reverse
      r       	:=     m '›',
      r_ahk   	:= s.modis→ahk(r)
      dbglogic	.= (GetKeyState(r_ahk    ) ? (r ' '):'   ')
      dbghook 	.= (GetKeyState(r_ahk,"P") ? (r ' '):'   ')
      dbghook 	.= (Mod(dbgcount,8)=0) ? '`n' : ''
    }
    for m in toggles {
      l       	:= m
      l_ahk   	:= s.key→ahk(l)
      dbglogic	.= (GetKeyState(l_ahk    ) ? (l ' '):'   ')
      dbghook 	.= (GetKeyState(l_ahk,"P") ? (l ' '):'   ')
    }
    return {h:dbghook,p:dbghook, l:dbglogic}
  }

  static ahk→modi_f(&k) { ; ahk combo to modifier flag
    modi_f := 0
    l:=1,r:=1 ; only check either if both explicit sides are missing
    InStr(k,"<+"	) ? modi_f |= f‹⇧	: l:=0
    InStr(k,">+"	) ? modi_f |= f⇧›	: r:=0
    if !(l+r)   	{
    InStr(k,"+" 	) ? modi_f |= f⇧	: ''
    }
    l:=1,r:=1
    InStr(k,"<^"	) ? modi_f |= f‹⎈	: l:=0
    InStr(k,">^"	) ? modi_f |= f⎈›	: r:=0
    if !(l+r)   	{
    InStr(k,"^" 	) ? modi_f |= f⎈	: ''
    }
    l:=1,r:=1
    InStr(k,"<#"	) ? modi_f |= f‹◆	: l:=0
    InStr(k,">#"	) ? modi_f |= f◆›	: r:=0
    if !(l+r)   	{
    InStr(k,"#" 	) ? modi_f |= f◆	: ''
    }
    l:=1,r:=1
    InStr(k,"<!"	) ? modi_f |= f‹⎇	: l:=0
    InStr(k,">!"	) ? modi_f |= f⎇›	: r:=0
    if !(l+r)   	{
    InStr(k,"!" 	) ? modi_f |= f⎇	: ''
    }
    return modi_f
  }
  static whichModText(fm) { ; convert mod flags into a string with 2 rows for left/right variants
    sm := '‹'
    sm .= (fm & f‹⇧  	) ? '⇧'   	: '  ' ;left shift
    sm .= (fm & f‹⎈  	) ? '⎈'   	: '  ' ;left ctrl
    sm .= (fm & f‹◆  	) ? '◆'   	: '  ' ;left super ❖◆ (win ⊞)
    sm .= (fm & f‹⎇  	) ? '⎇'   	: '  ' ;left alt
    sm .= (fm & f‹👍  	) ? '👍'   	: '  ' ;left Oyayubi 親指
    sm .= (fm & f⇪   	) ? '⇪'   	: ' ' ;caps lock
    sm .= (fm & fkana	) ? 'kana'	: ' ' ;kana fかな
    sm               	.= '`n '  	;
    sm .= (fm & f⇧›  	) ? '⇧'   	: '  ' ;right shift
    sm .= (fm & f⎈›  	) ? '⎈'   	: '  ' ;right ctrl
    sm .= (fm & f◆›  	) ? '◆'   	: '  ' ;right super ❖◆ (win ⊞)
    sm .= (fm & f⎇›  	) ? '⎇'   	: '  ' ;right alt
    sm .= (fm & f👍›  	) ? '👍'   	: '  ' ;right Oyayubi 親指
    sm               	.= '›'    	;
    sm .= (fm & f⇪   	) ? '⇪'   	: ' ' ;caps   lock
    sm .= (fm & f🔢   	) ? '🔢'   	: ' ' ;num  lock
    sm .= (fm & f⇳🔒  	) ? '⇳🔒'  	: '' ;  scroll lock
    sm .= (fm & fkana	) ? 'kana'	: '' ;  kana fかな
    return sm
  }
  static modf→str(&fm) { ; convert mod flags into a condensed side-aware string: ‹⇧› for left+right shift
    am := helperString.modf→arr(&fm)
    return am.Join(delim:="")
  }
  static modf→arr(&fm) { ; convert mod flags into an ordered array of strings ⇧⎈◆⎇👍 ⇪ 🔢 ⇳🔒 kana
    am := []
    sm := ''
    if (fm & f⇧) {       	 ;some shift
      if (fm & f⇧) = f⇧ {	 ;any  = to exclude ⇧∀ matches any, including both (which ‹⇧›)
        sm := '⇧'        	;
      } else {           	; doesn't match any, so safe to add ‹› sides if they exist (any=⇧ without sides)
        sm := (fm & f‹⇧  	) ? '‹'	: '' ;left
        sm .= '⇧'        	;
        sm .= (fm & f⇧›  	) ? '›'	: '' ;right
      }
    }
    am.push(sm)
    sm := ''
    if (fm & f⎈) {       	 ;some ctrl
      if (fm & f⎈) = f⎈ {	 ;any
        sm := '⎈'        	;
      } else {
        sm := (fm & f‹⎈	) ? '‹'	: '' ;left
        sm .= '⎈'      	;
        sm .= (fm & f⎈›	) ? '›'	: '' ;right
      }
    }
    am.push(sm)
    sm := ''
    if (fm & f◆) {       	 ;some super ❖◆ (win ⊞)
      if (fm & f◆) = f◆ {	 ;any
        sm := '◆'        	;
      } else {
        sm := (fm & f‹◆	) ? '‹'	: '' ;left
        sm .= '◆'      	;
        sm .= (fm & f◆›	) ? '›'	: '' ;right
      }
    }
    am.push(sm)
    sm := ''
    if (fm & f⎇) {       	 ;some alt
      if (fm & f⎇) = f⎇ {	 ;any
        sm := '⎇'        	;
      } else {
        sm := (fm & f‹⎇	) ? '‹'	: '' ;left
        sm .= '⎇'      	;
        sm .= (fm & f⎇›	) ? '›'	: '' ;right
      }
    }
    am.push(sm)
    sm := ''
    if (fm & f👍) {       	 ;some Oyayubi 親指
      if (fm & f👍) = f👍 {	 ;any
        sm := '👍'        	;
      } else {
        sm := (fm & f‹👍	) ? '‹'	: '' ;left
        sm .= '👍'      	;
        sm .= (fm & f👍›	) ? '›'	: '' ;right
      }
    }
    am.push(sm)
    am.push((fm & f⇪   ) ? '⇪' : '')   	;  caps   lock
    am.push((fm & f🔢  ) ? '🔢' : '')    	;num    lock
    am.push((fm & f⇳🔒  ) ? '⇳🔒' : '')  	;  scroll lock
    am.push((fm & fkana) ? 'kana' : '')	;  kana fかな
    return am
  }
  static ahk→modi_arr(&k) { ; ahk combo to modifier array of strings
    modi_f := helperString.ahk→modi_f(&k)
    return helperString.modf→arr(&modi_f)
  }
}

hexx(num) { ; returns hex in 0xABab
  if IsNumber(num) {
    return format("{:#0x}",num) ; lower case prefixed 0x no padding
  } else {
    return ""
  }
}
hex(num) {
  if IsNumber(num) {
    return format("{:0x}",num) ; lower case no prefix no padding
  } else {
    return ""
  }
}
