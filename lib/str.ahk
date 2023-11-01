#Requires AutoHotKey 2.0.10
#Include <constKey>	; various key constants
; —————————— String functions ——————————
class helperString {
  static __new() { ; fill the map
    this.fillKeyList()
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


  static getKeyFlag(hk) { ; get prefix bitflags for a key combo (~$vk41 → f＄|f˜ = 6)
    flag := 0
    flag	|= InStr(hk,'$') ? f＄ : 0	; keyboard hook on
    flag	|= InStr(hk,'~') ? f˜ : 0	; passthru native key
    flag	|= InStr(hk,'*') ? f∗ : 0	; any modifiers allowed
    return flag
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
    key_combo := RegExReplace(key_combo,this.all_whitespace,'')
    this.fillKeyList()

    key_combo_clean := key_combo ; save to later find the last modifier
    ; Now parse the input key_combo

    match_map    	:= this.modiMap
    modi_last_map	:= this.get_last_match_backwards(key_combo,&match_map)
    isLastMod    	:= modi_last_map['i']
    lastMod      	:= ""
    if isLastMod {
      key_combo	:= modi_last_map['pre'] ; cut off the last modifier key ⎈› ...
      lastMod  	:= modi_last_map['sub'] ; add it later, but always as a full substitute RCtrl
    }

    outModi_ahk_arr_user := [] ; ‹⇧
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
        outModi_ahk_arr_user.Push(modi_user)
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
