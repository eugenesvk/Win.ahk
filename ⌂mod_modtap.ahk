#Requires AutoHotkey v2.0
; v0.4@24-03 Design overview and limitations @ github.com/eugenesvk/Win.ahk/blob/modtap/ReadMe.md
; —————————— User configuration ——————————
global ucfg⌂mod := Map(
  ; Key        	 Value	 |Default|Alternative¦
   'tooltip⎀'  	, true	;|true|	show a tooltip with activated modtaps near text caret (position isn't updated as the caret moves)
  ,'tt⎀delay'  	, 0   	;|0|   	seconds before a `tooltip⎀` is shown, helpful if you don't like tooltip flashes on using modtap only once for a single key (like ⇧), but would still like to have it to understand when `holdTimer` has been exceeded. If you release a modtap within this delay, `tooltip⎀` will be cancelled and not flash
  , 'holdTimer'	, 0.5 	;|.5|  	seconds of holding a modtap key after which it becomes a hold modifier
  , 'ignored'  	, Map(	;      	ignore specific key combos to avoid typing mistakes from doing something annoying (like ◆l locking your computer)
    ; key      	      	modifier bitflag (can be combined with bitwise and symbol ‘&’, alternative/or ‘|’ is not supported to make lookup easier)
    ;          	value 	list of alphanumeric key labels
     f‹⇧       	, 'qwertzxcvb␠'
    ,f⇧›       	, 'yuiopnm,./[]'
    ) ;
  ,'ignore🛑'	, true 	;|true|	force stop the modtap after encountering an ignored key even if the physical key is being held, so if 'f' is ‹⇧ and 'e' is 'ignored':
    ;       	  true 	  f🠿e↕ will print 'fe' right away
    ;       	  false	  f🠿e↕ will print nothing, 'f↑' will print 'fe' (unless hold time > holdTimer, then ‹⇧ will toggle and no 'fe' or 'e' is printed)
  , 'keymap'	, Map( 	;	Modtap key:mod pairs (only fjh actually set manually @ register🠿↕ below)
    ; ⌂ Home Row mods, set a modifier on hold
    'a',‹⎈, 's',‹◆ ,'d',‹⎇ ,'f',‹⇧,  ; 'a','LControl' , 's','LWin' , 'd','LAlt' , 'f','LShift',
    'l',⎈›, ';',◆› ,'k',⎇› ,'j',⇧›,  ; 'l','RControl' , ';','RWin' , 'k','RAlt' , 'j','RShift',
    ; regular ModTaps (not home row mods, don't set modifiers on hold)
    'h','Escape','i','Escape'
   ) ;
  ; Debugging	       	        	;
  , 'ttdbg'  	, false	;|false|	show an empty (but visible) tooltip when modtap is deactivated
  , 'sndlvl' 	, 1    	;|1|    	register hotkeys with this sendlevel
  )
class udbg⌂mod { ; various debug constants like indices for tooltips
  static i↗	:= 19 ; dbgTT index, top right position of the empty status of our home row mod
  ,i↘t     	:=  8 ; dbgTT index, top down position of the key and modtap status (title)
  ,i↘      	:=  9 ; ... value
  ,i1↓     	:= 10 ; dbgTT index, bottom position for IHookss on messages
  ,i0↓     	:= 11 ; ... off
  ,ik      	:= 13 ; dbgTT index for Key↓↑_⌂ functions
  ,dt      	:=  5 ; min debug level for the bottom-right status of all the keys
  ,ds      	:=  3 ; min debug level for Send events
  ,dsl     	:=  3 ; min debug log level for Send events
  ,dihl    	:=  4 ; min debug log level for IHook
  ,init    	:=  4 ; min debug log level for IHook
  ,ttl     	:=  1 ; min debug level for Itooltip
}

⌂mod_init()
⌂mod_init() { ; Prepare key objects that store info for initializing and using modtaps
  local mod
  for key,mod in ucfg⌂mod['keymap'] {
    ⌂(key,mod)
  }
  ⌂.gen_map⌂()
}

; Assign functions that will handle modtap keys
⌂.register🠿↕('fj','')
⌂.register🠿↕('i' ,cbHotIfVar) ; conditional modtap
⌂.unregister🠿↕('fji') ; block repeats on 🠿, reset on ↑
cbHotIfVar(HotkeyName) { ; callback for register🠿↕
  if nv_mode = 2 and WinActive("ahk_exe sublime_text.exe") { ; Insert mode in Sublime Text passed via winmsg
    return true
  } else {
    return false
  }
}

; getKeyLabels_forVK(kvk:='vk20') ; ␠ ␣
getKeyLabels_forVK(kvk) {
  static K	:= keyConstant, vk:=K._map, vkr:=K._mapr, vkl:=K._maplng, vkrl:=K._maprlng, sc:=K._mapsc  ; various key name constants, gets vk code to avoid issues with another layout
  key_labels := ''
  for keyNm, vkCode in vk {
    if vkCode = kvk and strlen(keyNm) = 1 { ;
      key_labels .= keyNm ' '
    }
  }
  msgbox(key_labels '`n (copied to clipboard)','Key labels for ‘' kvk '’') ;
  A_Clipboard := key_labels
}
getCfgIgnored() {
  static K	:= keyConstant, vk:=K._map, vkr:=K._mapr, vkl:=K._maplng, vkrl:=K._maprlng, sc:=K._mapsc  ; various key name constants, gets vk code to avoid issues with another layout
    , isInit := false
    , ignored := Map()
    , cfgignored := ucfg⌂mod.Get('ignored',Map())
  if isInit = true {
    return ignored
  } else { ; convert cfgignored into a map of vk codes to make later matches easier
    for keyFlag, keyNm in cfgignored { ; f‹⇧ 'qwerty␠\'
      vkCode := Map()
      vkCode.CaseSense	:= 0
      loop parse keyNm {
        vkCode[vk[A_LoopField]] := A_LoopField
      }
      ignored[keyFlag] := vkCode
    }
    isInit := true
    return ignored
  }
}

class ⌂ { ; 🠿
  static keys     	:= []
  static tokens   	:= []
  static key2token	:= Map(';','︔')
  static cb↑      	:= Map()
  static cb↓      	:= Map()
  static map      	:= Map()

  static Call(key,mod) {
    token := this.key2token.get(key,key)
    ⌂.keys  .push(key  )
    ⌂.tokens.push(token)
    this.DefineProp(token,{Call:{k:key,token:token,mod:mod} })
  }

  static gen_map⌂() {
    static K  	:= keyConstant, vk:=K._map, vkr:=K._mapr, vkl:=K._maplng, vkrl:=K._maprlng, sc:=K._mapsc  ; various key name constants, gets vk code to avoid issues with another layout
      , ⌂tHold	:= ucfg⌂mod.Get('holdTimer',0.5) ;
    ⌂.map['vk→token'] := Map()
    ⌂.map['flag→vk' ] := Map()

    for i in ⌂.tokens {
      i⌂       	:= ⌂.%i%
      i⌂.t     	:= A_TickCount
      i⌂.vk    	:= vk[i⌂.k] ; vk21 for f
      ⌂.map[   	'vk→token'][i⌂.vk] := i
      i⌂.pos   	:= ↑
      i⌂.is    	:= false ; is activated
      i⌂.force↑	:= false ; this is set to true if we need to manually reset the status while the key is physically ↓
      i⌂.send↓ 	:= '{' i⌂.mod ' Down' '}' ; ahk formatted key to be sent on down/up
      i⌂.send↑ 	:= '{' i⌂.mod ' Up'   '}'
      try {
        i⌂.🔣        	:= helperString.modi_ahk→sym(    i⌂.mod) ; ‹⇧
        i⌂.🔣ahk     	:= helperString.modi_ahk→sym_ahk(i⌂.mod) ; <+
        i⌂.flag     	:= f%i⌂.🔣% ; f‹⇧ = 1
      } catch       	Error as err { ; not a home row mod, so doesn't have mod prefixex/flags
        i⌂.🔣        	:= ''
        i⌂.🔣ahk     	:= ''
        i⌂.flag     	:= 0
        i⌂.ignoreall	:= 1 ; ignore all keys, so K+X sequences always type kx
      }
      i⌂.dbg  	:= '⌂' i⌂.k i⌂.🔣 ;
      ; Track 	which keys have been pressed
      i⌂.prio↓	:= '' ; before a given modtap is down
      i⌂.prio↑	:= '' ;                          up
      ;       	while a given modtap is down
      i⌂.K↓   	:=  Array() ; key down events (track K↑ for all K↓ that happened before modtap)
      i⌂.K↑   	:=  Array() ; ... up
      ; Setup IHooks to manually handle input when modtap key is pressed
      ih          	:= InputHook("T" ⌂tHold) ; minSendLevel set within setup⌂mo depending on the stack order of a given modtap
      ih.KeyOpt(  	'{All}','NS')  ; N: Notify. OnKeyDown/OnKeyUp callbacks to be called each time the key is pressed
      ; S         	: blocks key after processing it otherwise NonText (default non-suppressed) ⌂◀ will double ◀
      ih.OnKeyUp  	:= cb⌂_K↑.Bind(i)	;
      ih.OnKeyDown	:= cb⌂_K↓.Bind(i)	; ;;;or cbkeys? and '{Left}{Up}{Right}{Down}' separately???
      i⌂.ih       	:= ih

      ⌂.map['flag→vk'][i⌂.flag]	:= i⌂.vk
    }
  }

  static register🠿↕(keys,cb) {
    static K	:= keyConstant, vk:=K._map, vkr:=K._mapr, vkl:=K._maplng, vkrl:=K._maprlng, sc:=K._mapsc  ; various key name constants, gets vk code to avoid issues with another layout
     , s    	:= helperString
    loop parse keys {
      kvk  	:= vk[A_LoopField]
      hk↓  	:= ＄ kvk       ;f → $vk46
      hk↑  	:= ＄ kvk ' UP' ;f → $vk46 UP   $=kbd hook
      hk↓fn	:= hkModTap.bind(A_LoopField,kvk,is↓:=1) ; allows passing key and is↓ direction to the hk callback
      hk↑fn	:= hkModTap.bind(A_LoopField,kvk,is↓:=0) ; instead of parsing it inside and worrying about hotkey prefixes registered by other scripts
      if cb { ; turn hotkey context sensitivity if a callback is passed
        HotIf cb
      }
      HotKey(hk↓, hk↓fn,'I1')
      HotKey(hk↑, hk↑fn,'I1')
      if cb {
        HotIf
      }
    }
  }
  static unregister🠿↕(keys) {
    static K	:= keyConstant, vk:=K._map, vkr:=K._mapr, vkl:=K._maplng, vkrl:=K._maprlng, sc:=K._mapsc  ; various key name constants, gets vk code to avoid issues with another layout
     , s    	:= helperString
     ; , k := helperString.key→token.Bind(helperString)
    static ⌂tHold := ucfg⌂mod.Get('holdTimer',0.5), ⌂ΔH := ⌂tHold * 1000, ttdbg := ucfg⌂mod.Get('ttdbg',0), sndlvl := ucfg⌂mod.Get('sndlvl',0)
    loop parse keys { ;
      mod_ahk 	:= ⌂.%A_LoopField%.🔣ahk ; <+ for f and >+ for j
      kvk     	:= vk[A_LoopField]
      hk↓     	:= ＄ mod_ahk kvk      	;f → >+ $vk46
      hk↑     	:= ＄ mod_ahk kvk ' UP'	;f → >+ $vk46 UP $=kbd hook
      hk↓fn   	:= hkDoNothing ; allows passing key and is↓ direction to the hk callback
      hk↑fn   	:= hkModTap_off.bind(A_LoopField,kvk,is↓:=0) ; instead of parsing it inside and worrying about hotkey prefixes registered by other scripts
      token   	:= s.key→token(A_LoopField) ;f for f
      cbHotIf_	:= cbHotIf.Bind(token)
      HotIf cbHotIf_ ; filter down/up events for
      HotKey(hk↓, hk↓fn, "I" sndlvl) ; do nothing while home row mod is active _1)
      HotKey(hk↑, hk↑fn, "I" sndlvl) ; reset home row mod if it's active on UP _2)
      HotIf
      ; dbgtt(0,Obj2Str(⌂.hk_map[A_LoopField]),5)
    }
  }
}

dbgTT_isMod(dbg_pre:='') { ;
  static _ := 0
    , 🖥️w←,🖥️w↑,🖥️w→,🖥️w↓,🖥️w↔,🖥️w↕
    , _ := win.getMonWork(&🖥️w←,&🖥️w↑,&🖥️w→,&🖥️w↓,&🖥️w↔,&🖥️w↕) ; Get Monitor working area ;;; static, ignores monitor changes
    , D	:= udbg⌂mod
  if dbg >= D.dt {
    ismod := getDbgKeyStatusS(dbg_pre)
    , dbgTT(D.dt,ismod.dbgt,t:='∞',D.i↘t,🖥️w↔,🖥️w↕*.91) ; title message
    , dbgTT(D.dt,ismod.dbgv,t:='∞',D.i↘ ,🖥️w↔,🖥️w↕) ; ↑/↓ status of all the asdfjkl; keys and their ⌂mod
  }
}
getDbgKeyStatusS(dbg_pre:='') { ; get left to right debug string of which modtap keys are active (held)
  modtap_status := ''
  , iskeydown := ''
  , dbg_title := ''
  for i in ⌂.tokens {
    i⌂	:= ⌂.%i%
    i⌂_act := ⌂.%⌂.map['vk→token'][i⌂.vk]%
    modtap_status		.= (i⌂_act.is ? i⌂.🔣 : '  ')
    iskeydown    		.= ' ' (GetKeyState(i⌂.vk,"P") ? i⌂.k : ' ')
  }
  dbg_val := (StrReplace(modtap_status,' ') = '' ? '' : modtap_status) '`n' (StrReplace(iskeydown,' ') = ''?'':iskeydown)
  if dbg_pre and not dbg_val = '`n' {
    dbg_title := dbg_pre '🕐' preciseTΔ()
  }
  return {dbgt:dbg_title,dbgv:dbg_val,modtap:modtap_status,key:iskeydown}
}

get⌂Status() {
  static bin→dec	:= numFunc.bin→dec.Bind(numFunc), dec→bin := numFunc.dec→bin.Bind(numFunc), nbase := numFunc.nbase.Bind(numFunc)
  bitflags := 0
  for i in ⌂.tokens {
    ⌂i := ⌂.%i%
    bitflags |= GetKeyState(⌂i.vk,"P") ? ⌂i.flag : 0
  } ; dbgTT(0,'bitflags ' dec→bin(bitflags) ' ‹' isAny‹ ' ›' isAny›,t:=5)
  return {isAny‹:bitflags & bit‹, isAny›:bitflags & bit›, bit:bitflags}
}

preciseTΔ() ; start timer for debugging

hkModTap(k_,kvk,is↓,hk_dirty) {
  static _ := 0
  , 🖥️w←,🖥️w↑,🖥️w→,🖥️w↓,🖥️w↔,🖥️w↕
  , _ := win.getMonWork(&🖥️w←,&🖥️w↑,&🖥️w→,&🖥️w↓,&🖥️w↔,&🖥️w↕) ; Get Monitor working area ;;; static, ignores monitor changes
  static K	:= keyConstant, vk:=K._map, vkr:=K._mapr, vkl:=K._maplng, vkrl:=K._maprlng, vk→k:=vkrl['en'], sc:=K._mapsc  ; various key name constants, gets vk code to avoid issues with another layout
  static _d := 1, _dl:=1
  (dbg<min(_d,_dl))?'':(m:='‘' k_ '’(' kvk ')' (is↓?'↓':'↑') ' L' A_SendLevel ' preK=' k→en(A_PriorKey) ' hk@hkModTap', dbgTT(_d,m,2,,🖥️w↔,🖥️w↕*0.3), log(_dl,m))
  ; 🕐1 := preciseTΔ()
  setup⌂mod(k_,kvk,is↓) ; k_=f kvk=vk46 is↓=0 or 1
  ; 🕐2 := preciseTΔ()
  ; log(0,'post setup⌂mo ' m format(" 🕐Δ{:.3f}",🕐2-🕐1),A_ThisFunc,'h⃣k⃣⌂')
}

cbHotIf(_token, HotkeyName) { ; callback for unregister🠿↕ ;f <+$vk46 and f <+$vk46 UP
  return ⌂.%_token%.is ; token is ︔ for ; to be used in var names
}
hkModTap_off(k_,kvk,is↓,hk_dirty) {
  static D	:= udbg⌂mod, C := ucfg⌂mod
  ⌂_ := ⌂.%k_%
  dbg⌂ := ⌂_.k ' ' ⌂_.🔣
  static ⌂tHold := C.Get('holdTimer',0.5), ⌂ΔH := ⌂tHold * 1000, ttdbg := C.Get('ttdbg',0), sndlvl := C.Get('sndlvl',0)
    , 🖥️w←,🖥️w↑,🖥️w→,🖥️w↓,🖥️w↔,🖥️w↕
    , _ := win.getMonWork(&🖥️w←,&🖥️w↑,&🖥️w→,&🖥️w↓,&🖥️w↔,&🖥️w↕) ; Get Monitor working area ;;; static, ignores monitor changes
    , tooltip⎀ := C.Get('tooltip⎀',1), tt⎀delay := C.Get('tt⎀delay',0) * 1000
    , ttdbg := C.Get('ttdbg',0)
  t⌂_ := A_TickCount - ⌂_.t
  dbgTT(3,'🠿1bb) ⌂↓ >ΔH •⌂↑ 🕐' preciseTΔ() ' (hkModTap_off)`n' dbg⌂ ' ¦ ' k_ ' ¦ ' kvk ' (' t⌂_ (t⌂_<⌂ΔH?'<':'>') ⌂ΔH ') `n' ⌂_.send↑,t:=4,i:=13,0,🖥️w↕//2) ;
  ; log(D.dsl,'⌂↑',,'✗🖮¦' ⌂_.send↑ '¦————— @hkModTap_off')
  SendInput(⌂_.send↑), ⌂_.is  := false, ⌂_.pos := ↑, ⌂_.t := A_TickCount ; 🠿1bb)
  , dbgTT(ttdbg?0:5,ttdbg?'`n':'',t:='∞',D.i↗,🖥️w↔ - 40, 20)
  if tooltip⎀ { ;
    win.get⎀(&⎀←,&⎀↑,&⎀↔:=0,&⎀↕:=0)
    tt⎀delay?set⎀TT(0):'' ; cancel a potential delayed timer
    ttdbg?'':dbgTT(0,'',t:='∞',D.i↗,⎀←-9,⎀↑-30) ; and remove a non-timer tooltip regardless of the timed one unless ttdbg mandates we use a blank tooltip
  }
  dbgTT_isMod('🠿1bb')
}
hkDoNothing(hk) {
  dbgTT(4,'hkDoNothing 🕐' preciseTΔ(),,14,0,50) ;
  return
}
get⌂dbg(⌂_) {
  static bin→dec	:= numFunc.bin→dec.Bind(numFunc), dec→bin := numFunc.dec→bin.Bind(numFunc), nbase := numFunc.nbase.Bind(numFunc)
   return ⌂_.dbg (⌂_.pos=↓?'↓':'↑') (⌂_.is?'🠿':'') ' send‘' ⌂_.send%(⌂_.pos=↓?'↓':'↑')% '’ flag' dec→bin(⌂_.flag)
}

cb⌂_K↓(token,  ih,vk,sc) {
  Key↓_⌂(ih,&vk,&sc,   &token)
}
cb⌂_K↑(token,  ih,vk,sc) {
  Key↑_⌂(ih,&vk,&sc,   &token)
}

kvk→label(arr) { ; convert an array of decimal VK codes into an tring of English-based key names
  static K  	:= keyConstant, vk:=K._map, vkr:=K._mapr, vkl:=K._maplng, vkrl:=K._maprlng, vk→k:=vkrl['en'], sc:=K._mapsc  ; various key name constants, gets vk code to avoid issues with another layout
  labels := ''
  ; labels := Array()
  ; dbgtxt := ''
  for kvk in arr {
    ; dbgtxt .= kvk '(' 'vk' hex(kvk) '→' vk→k.Get('vk' hex(kvk),'✗') ')'
    ; labels.push(vk→k.Get('vk' hex(kvk),'✗'))
    labels .= vk→k.Get('vk' hex(kvk),'✗')
  }
  ; dbgTT(0, dbgtxt, t:=3) ;
  return labels
}

Key↓_⌂(ih,&kvk,&ksc,  &token, dbgsrc:='') {
  static K	:= keyConstant, vk:=K._map, vkr:=K._mapr, vkl:=K._maplng, vkrl:=K._maprlng, vk→k:=vkrl['en'], sc:=K._mapsc  ; various key name constants, gets vk code to avoid issues with another layout
    , s   	:= helperString
    , D   	:= udbg⌂mod
    , 🖥️w←,🖥️w↑,🖥️w→,🖥️w↓,🖥️w↔,🖥️w↕
    , _ := win.getMonWork(&🖥️w←,&🖥️w↑,&🖥️w→,&🖥️w↓,&🖥️w↔,&🖥️w↕) ; Get Monitor working area ;;; static, ignores monitor changes
    , ignored := getCfgIgnored()
    , dbl := 2
  ⌂_ := ⌂.%token%
  ⌂_.K↓.push(kvk)
  if ⌂_.pos = ↓ { ; should always be true? otherwise we won't get a callback
    if dbg >= dbl {
      dbg⌂ := ⌂_.dbg (⌂_.pos=↓?'↓':'↑') ;
      kvk_s := 'vk' hex(kvk), sc_s := 'sc' hex(ksc)
      ; keynm	:= vk→k.Get('vk' hex(kvk),'✗')
      ; dbgTT(0,⌂_.dbg ' ' keynm '↓' kvk '_' hex(kvk),t:=5,16,0,0) ;
      variant	:= ''
      if ⌂_.HasOwnProp('ignoreall') {
        variant	:= '✗✗✗↓ ignore all'
      } else if ignored.Has(⌂_.flag) and
         ignored[⌂_.flag].Has(kvk_s) { ; this modtap+key combo should be ignored
        variant	:= '✗✗✗↓ ignore'
      } else {
        variant	:= '✗ ?0b)'
      }
      keynm 	:= vk→k.Get('vk' hex(kvk),'✗')
      prionm	:= vk→k.Get(vk.get(A_PriorKey,''),'✗')
      t⌂_   	:= A_TickCount - ⌂_.t
      dbgTT(dbl,variant ' ' dbg⌂ '(' t⌂_ ') ' keynm '↓ prio ‘' prionm '’ ' kvk_s ' ' sc_s,t:=5,D.ik,🖥️w↔ - 40,🖥️w↕*.86) ; vk57 sc11
    }
  } else { ; should never get here? or maybe can get here due to a delay and something else set an ↑ position?
    dbg⌂ := ⌂_.dbg (⌂_.pos=↑?'↑':'↓')
    , kvk_s := 'vk' hex(kvk), sc_s := 'sc' hex(ksc)
    if dbg >= dbl {
      ; keynm	:= vk→k.Get('vk' hex(kvk),'✗')
      ; dbgTT(0,⌂_.dbg ' ' keynm '↓' kvk '_' hex(kvk),t:=5,16,0,0) ;
      variant	:= ''
      keynm  	:= vk→k.Get('vk' hex(kvk),'✗')
      prionm 	:= vk→k.Get(vk.get(A_PriorKey,''),'✗')
      t⌂_    	:= A_TickCount - ⌂_.t
      dbgTT(0,variant ' ' dbg⌂ '(' t⌂_ ') ' keynm '↓ prio ‘' prionm '’ ' kvk_s ' ' sc_s,t:=10,D.ik,🖥️w↔ - 40,🖥️w↕*.86) ; vk57 sc11
    }
    dbgTT(0,dbg⌂ ' ↓' GetKeyName(kvk_s) ' ' kvk_s ' ' sc_s ' 🕐' preciseTΔ() " Unknown state @Key↓_⌂?",t:=10) ;
  }
}
Key↑_⌂(ih,&kvk,&ksc,  &token, dbgsrc:='') { ;
  static K	:= keyConstant, vk:=K._map, vkr:=K._mapr, vkl:=K._maplng, vkrl:=K._maprlng, vk→k:=vkrl['en'], sc:=K._mapsc  ; various key name constants, gets vk code to avoid issues with another layout
    , s   	:= helperString
    , C   	:= ucfg⌂mod, D	:= udbg⌂mod
    , 🖥️w←,🖥️w↑,🖥️w→,🖥️w↓,🖥️w↔,🖥️w↕
    , _ := win.getMonWork(&🖥️w←,&🖥️w↑,&🖥️w→,&🖥️w↓,&🖥️w↔,&🖥️w↕) ; Get Monitor working area ;;; static, ignores monitor changes
    , tooltip⎀ := C.Get('tooltip⎀',1), tt⎀delay := C.Get('tt⎀delay',0) * 1000
    , ttdbg := C.Get('ttdbg',0)
    , ignored := getCfgIgnored()
    , ignore🛑 := C.Get('ignore🛑','true')
    , dbl := 3 ;
    , dbb := 6 ; bug
  ⌂_ := ⌂.%token% ;
  dbg⌂ := ⌂_.k ' ' ⌂_.🔣 (⌂_.pos=↓?'↓':'↑') ;
  kvk_s := 'vk' hex(kvk), sc_s := 'sc' hex(ksc)
  ⌂_.K↑.push(kvk)
  if ⌂_.pos = ↓ { ; 1a)
    dbg_min := min(D.ds,dbl)
    variant := '', pri₌ := '', 🕐 := (dbg >= dbg_min) ? preciseTΔ() : ''
    if dbg >= dbg_min { ; get debug values early otherwise ⌂_.K↓ can get reset on slow tooltip ops
      keynm  	:= vk→k.Get(kvk_s,'✗')
      ,prionm	:= vk→k.Get(vk.get(A_PriorKey,''),'✗')
      ,prio↓ 	:= vk→k.Get(vk.Get(⌂_.prio↓,''),'✗')
      ,t⌂_   	:= A_TickCount - ⌂_.t
      ; ,⌂K↓ 	:= Obj→Str(kvk→label(⌂_.K↓))
      ; ,⌂K↑ 	:= Obj→Str(kvk→label(⌂_.K↑))
      ,⌂K↓   	:= kvk→label(⌂_.K↓)
      ,⌂K↑   	:= kvk→label(⌂_.K↑)
    }

    if A_PriorKey and ⌂_.vk = (prio := vk.get(A_PriorKey,'')) {
      variant   :=  'xx) a↓ ⌂↓ •a↑ ⌂↑'     , pri₌ := '='
    } else if not HasValue(⌂_.K↓,kvk) { ;
      variant   := 'x_x) a↓ ⌂↓ b↓ •a↑ ⌂↑ ↕', pri₌ := '≠'
    } else {
      if ⌂_.HasOwnProp('ignoreall')             { ;       ignore this modtap+key combo
        variant := '✗all 1aa) ⌂↓ a↓ <ΔH•a↑ ⌂↑'
        if ignore🛑 { ; force-cancel modtap, tweak sendlevel to allow the script to accept the generated Up event
          _sl:=A_SendLevel, SendLevel(ih.MinSendLevel), SendEvent('{' ⌂_.vk ' UP}'), SendLevel(_sl)
          (dbg<D.dsl)?'':(log(D.dsl,'🖮‘' ⌂_.k '’↑@L' ih.MinSendLevel '_' _sl '————— ignore🛑all',A_ThisFunc))
          ; setup⌂mod(⌂_.vk ' UP',⌂_.k,is↓:='0') ; alternative way to cancel by calling the function directly
        }
      } else if ignored.Has(⌂_.flag) and
         ignored[           ⌂_.flag].Has(kvk_s) { ;       ignore this modtap+key combo
        variant := '✗ 1aa) ⌂↓ a↓ <ΔH•a↑ ⌂↑'
        if ignore🛑 { ; force-cancel modtap
          _sl:=A_SendLevel, SendLevel(ih.MinSendLevel), SendEvent('{' ⌂_.vk ' UP}'), SendLevel(_sl)
          (dbg<D.dsl)?'':(log(D.dsl,'🖮‘' ⌂_.k '’↑@L' ih.MinSendLevel '_' _sl '————— ignore🛑',A_ThisFunc))
          ; setup⌂mod(⌂_.vk ' UP',⌂_.k,is↓:='0') ; alternative way to cancel by calling the function directly
        }
      } else {                         ; don't ignore this modtap+key combo
        variant :=  '🠿1aa) ⌂↓ a↓ <ΔH•a↑ ⌂↑'
        ; log(D.dsl,'prio≠⌂.k ✓HasVal⌂.K↓ ⌂↓=' vkrl['en'].Get(kvk_s,'✗') '¦',A_ThisFunc,'✓🖮¦' ⌂_.send↓ '¦—————')
        SendInput(⌂_.send↓ '{' kvk_s sc_s '}'), ⌂_.is := true ; splitting send↓ and key bugs due to slow tooltip⎀
        if tooltip⎀ {
          ; (dbg<dbb)?'':(🕐1:=preciseTΔ(), dbg_ih:=ih.input, dbg_k↓:=Obj2Str(kvk→label(⌂_.K↓)))
          if tt⎀delay { ; delay showing tooltip
            set⎀TT(1, ⌂_.🔣)
          } else {
            win.get⎀(&⎀←,&⎀↑,&⎀↔,&⎀↕), dbgTT(0,⌂_.🔣,t:='∞',D.i↗,⎀←-9,⎀↑-30)
          }
          ; (dbg<dbb)?'':(🕐2:=preciseTΔ())
          ⌂_.is?'':dbgTT(0,'','∞',D.i↗) ; hide a slowpoke tooltip that doesn't reflect modtap key status whic was reset while win.get⎀ was trying to get the cursor
          ; (dbg<dbb)?'':(m:='send HK↓=' ⌂_.k ' ' ⌂_.mod ' K↓=' GetKeyName(kvk_s) ' ⌂_is=' ⌂_.is '`nih=' dbg_ih '`n _=' ih.input '`nK↓=' dbg_k↓ '`n  _=' Obj2Str(kvk→label(⌂_.K↓)) '`n🕐' 🕐2-🕐1 '`n' 🕐1 '`n' 🕐2, dbgtt(dbb,m,'∞',18,0,0), log(dbb)m,,18))
        }
        dbgTT_isMod('🠿1aa')
        ; dbgTT(0,ih.Input '`n' (ih=⌂_.ih) ' 🕐' 🕐 '`n' ⌂_.ih.Input,t:=1) ;
        ; ih.Stop() ;
      }
    }
    if dbg >= dbl {
      dbgTL(dbl,variant ' (' dbgsrc ') 🕐' 🕐
        '`n' dbg⌂ ' ↑(' kvk_s ' ' sc_s ') prio ‘' prionm '’ ' pri₌ ⌂_.k ' prio⌂↓‘' prio↓ '’`nK↓' ⌂K↓ '`nK↑' ⌂K↑ '`nsend↓: ' ⌂_.send↓ keynm ' ¦ih: ' ih.input,{t:4,idTT:D.ik,x:A_ScreenWidth - 40}) ;i
    }
    if dbg >= D.ds {
      dbgTT(D.ds,variant ' 🕐' 🕐
        '`n' dbg⌂ '(' t⌂_ ') ' keynm '↑(' kvk_s ' ' sc_s ') prio ‘' prionm '’ ≠' ⌂_.k ' prio⌂↓‘' prio↓ '’`nK↓' ⌂K↓ '`nK↑' ⌂K↑ '`nsend↓: ' ⌂_.send↓ keynm ' ¦ih: ' ih.input,t:=4,D.ik+1,0,🖥️w↕//2) ;
    }
  } else { ; 2b) ⌂↓ a↓ ⌂↑ •a↑ ??? unreachable since ⌂_↑ cancels input hook and resets ⌂_.pos
    if dbg >= dbl { ;
      keynm 	:= vk→k.Get('vk' hex(kvk),'✗')
      prionm	:= vk→k.Get(vk.get(A_PriorKey,''),'✗') ;
      t⌂_   	:= A_TickCount - ⌂_.t
      dbgtxt :='✗do nothing`n 2b) ⌂↓ a↓ ⌂↑ •a↑' '`n' dbg⌂p(&⌂_) dbg⌂ ' 🕐' t⌂_ ' ' keynm '↑(' kvk_s ' ' sc_s ') prio ‘' prionm '’ ≠' ⌂_.k
      dbgMsg(dbl,dbgtxt),log(dbl,dbgtxt,dbgsrc '→' A_ThisFunc)
    }
  }
}

global set⎀TT_txt
set⎀TT(OnOff, ttText:='') { ;
  static K   	:= keyConstant, vk:=K._map, vkr:=K._mapr, vkl:=K._maplng, vkrl:=K._maprlng, sc:=K._mapsc  ; various key name constants, gets vk code to avoid issues with another layout
    ,tt⎀delay	:= ucfg⌂mod.Get('tt⎀delay',0) * 1000
  global set⎀TT_txt
  set⎀TT_txt := ttText
  SetTimer(timer⎀TT, OnOff ? -tt⎀delay : 0) ; start a timer after a delay or delete
}
timer⎀TT() { ; show a tooltip near text caret with a text set via a global var (;;; don't know how to make a func object with a dynamic argument so that you could cancel the same timer⎀TT you started earlier)
  static D	:= udbg⌂mod
  win.get⎀(&⎀←,&⎀↑,&⎀↔,&⎀↕), dbgTT(0,set⎀TT_txt,t:='∞',D.i↗,⎀←-9,⎀↑-30)
}

vk→token(kvk) {
  static K    	:= keyConstant, vk:=K._map, vkr:=K._mapr, vkl:=K._maplng, vkrl:=K._maprlng, sc:=K._mapsc  ; various key name constants, gets vk code to avoid issues with another layout
   , s        	:= helperString
   , kvk→token	:= Map()
   , isInit   	:= false
  if not isInit {
    for i in ⌂.tokens {
      i⌂              	:= ⌂.%i%
      kvk→token[i⌂.vk]	:= i⌂.token
    }
    isInit := true
  }
  return kvk→token[kvk]
}

k→en(key) { ; ф → a
  static K	:= keyConstant, vk:=K._map, vkr:=K._mapr, vkl:=K._maplng, vkrl:=K._maprlng, vk→k:=vkrl['en'], sc:=K._mapsc  ; various key name constants, gets vk code to avoid issues with another layout
  return vk→k.Get(vk.get(key,''),key)
}
dbg⌂p(&⌂_) { ; common debug info for a ⌂ key
  return (
    (⌂_.pos=↓?'↓':'↑') '⌂' ⌂_.k ' ' (⌂_.is?'✓':'✗') '⌂' ⌂_.🔣 ' L' A_SendLevel '¦' ⌂_.ih.MinSendLevel
    ' preK=‘' k→en(A_PriorKey) '’ pre↓=‘' k→en(⌂_.prio↓) '’ pre↑=‘' k→en(⌂_.prio↑) '’'
    ' input=‘' ⌂_.ih.input '’' ' 🕐' preciseTΔ()
  )
}

setup⌂mod(c,vkC,is↓) { ; hk=$vk46 or $vk46 UP   c=f   is↓=0 or 1
  static K  	:= keyConstant, vk:=K._map, vkr:=K._mapr, vkl:=K._maplng, vkrl:=K._maprlng, vk→k:=vkrl['en'], sc:=K._mapsc  ; various key name constants, gets vk code to avoid issues with another layout
   , bin→dec	:= numFunc.bin→dec.Bind(numFunc), dec→bin := numFunc.dec→bin.Bind(numFunc), nbase := numFunc.nbase.Bind(numFunc)
   , s      	:= helperString
   , D      	:= udbg⌂mod, cfg := ucfg⌂mod
   , breaks 	:= '' ; break ↑ with these keys
   , 🖥️w←,🖥️w↑,🖥️w→,🖥️w↓,🖥️w↔,🖥️w↕
   , _       	:= win.getMonWork(&🖥️w←,&🖥️w↑,&🖥️w→,&🖥️w↓,&🖥️w↔,&🖥️w↕) ; Get Monitor working area ;;; static, ignores monitor changes
   , ⌂tHold  	:= cfg.Get('holdTimer',0.5) ;
   , ⌂ΔH     	:= ⌂tHold * 1000
   , ignored 	:= getCfgIgnored()
   , ignore🛑 	:= cfg.Get('ignore🛑','true')
   , tooltip⎀	:= cfg.Get('tooltip⎀',1), tt⎀delay := cfg.Get('tt⎀delay',0) * 1000
   , ttdbg   	:= cfg.Get('ttdbg',0) ;
   , d3      	:= 3 , l3	:= 3 ; custom dbg tooltip/log levels for testing commands
   , d4      	:= 4 , l4	:= 4 ;
   , d5      	:= 5 , l5	:= 5 ;
   , isInit  	:= false ;
   , dbg⌂ih  	:= ''
      ; I1 sendlevel (ignore regular keys sent at level 0)
      ; L1024 def don't need many since after a short hold timer a permanent mode will set, the hoook will reset
   , stack⌂  	:= [] ; track the level of a modtap key's IHooks in the stack (also used to set minsendlevel to allow sending keys to only the most recent hook)
   , dbgorder	:= Map()
  ;🕐1 := preciseTΔ()

  if not isInit {
    dbgorder := Map('a',[1,4], 's',[1,3], 'd',[1,2], 'f',[1,1]
                   ,';',[0,4], 'l',[0,3], 'k',[0,2], 'j',[0,1],  'i',[2,1],'h',[2,2])
    isInit	:= true
  }

  this_token := ⌂.map['vk→token'].Get(vkC, '')
  if not this_token { ;
    throw ValueError("Unknown modtap key!", -1, c ' ' vkC)
  }
  ⌂_ := ⌂.%this_token%
  ih⌂        	:= ⌂_.ih
  dbg⌂       	:= '⌂' ⌂_.k ⌂_.🔣 ;
  modtapflags	:= get⌂Status() ; {isAny‹,isAny›,bit}
  bit⌂       	:= modtapflags.bit
  isAny‹     	:= modtapflags.isAny‹
  isAny›     	:= modtapflags.isAny›
  isThis‹    	:= ⌂_.flag & bit‹
  isThis›    	:= ⌂_.flag & bit›
  isOpp      	:= (isThis‹ and isAny›)
    or       	   (isThis› and isAny‹)
  if dbg >= min(d4,l4) {
    static tmpid := 2
    (tmpid > 5)?(tmpid := 2):''
    (dbg<min(d3,l3))?'':(m:=c (is↓?'↓':'↑') ' ' dbg⌂p(&⌂_) ' isOpp' isOpp ' stack' stack⌂.Length
      ,dbgTT(d3,m,3,tmpid,🖥️w↔*(1  - dbgorder.Get(c,0)[1]*.24)
      ,                   🖥️w↕*(.5 + dbgorder.Get(c,0)[2]*.05 + is↓ * .06)),log(l3,m,A_ThisFunc '•2',tmpid))
    tmpid += 1
  }

  handle⌂↑(&⌂_,&ih,&ihID,⌂_t) { ; allows calling called either when a single ⌂ or combined
    if ⌂_.force↑ { ; already handled ⌂↑ via an artifical send in ignore🛑 condition, so reset it and return without printing an extra ⌂.k
      ⌂_.force↑ := false
      (dbg<min(d5,l5))?'':(m:='⎋ ⌂_.force↑ already handled ⌂↑ via an artifical send in ignore🛑 condition, so reset it', dbgTT(d5,m,4,6), log(D.l5,m,A_ThisFunc '•3'))
      ⌂_.pos := ↑, ⌂_.t := A_TickCount, ⌂_.is := false
      return
    }
    if (is↓phys := GetKeyState(⌂_.k,'P')) {
      ⌂_.force↑ := true
    }
    ; dbgtt(0,'K↓ reset=' Obj2Str(kvk→label(⌂_.K↓)) ' 🕐' preciseTΔ(),10,16,0,250)
    ⌂_.prio↓ := '', ⌂_.prio↑ := A_PriorKey, ⌂_.K↓ := Array(), ⌂_.K↑ := Array()
    ih_input := ''
    if ih⌂.InProgress { ;
      ih_input	:= ih⌂.Input
      ih⌂.Stop() ; stack cleaned up when handling ih.reason so that it's possible to stop at Key↓↑ functions
      (dbg<min(d5,l5,D.dihl))?'':(m:='×IH input=' ih_input ' stack' stack⌂.Length ' 🕐' preciseTΔ(), dbgTT(d5,m,4,7), log(l5,m,7), log(D.dihl,'✗ih—————•⌂↑ force stop↑' dbg⌂ ' with ih¦' ih_input '¦',A_ThisFunc '•4'))
    }
    if ⌂_.is { ; 🠿1ba)
      ⌂_.pos := ↑, ⌂_.t := A_TickCount, ⌂_.is := false
      SendInput(⌂_.send↑)
      if tooltip⎀ {
        if tt⎀delay { ; hide the caret tooltip before it's shown if delay hasn't expired yet
          set⎀TT(0)
        }
        win.get⎀(&⎀←,&⎀↑,&⎀↔,&⎀↕), dbgTT(0,'',t:='∞',D.i↗,⎀←-9,⎀↑-30) ; and hide a non-delayed one
        ; dbgtt(0,'⎀ reset 🕐' preciseTΔ(),10,15,0,285) ;
      }
      (dbg<min(D.ds,D.dsl))?'':(m:='🠿1ba) ⌂↑ after sequenced ⌂🠿(' ⌂_t (⌂_t<⌂ΔH?'<':'>') ⌂ΔH ') ' dbg⌂p(&⌂_) '`n🖮¦' ⌂_.send↑ '¦—————', dbgTT(d5,m,2,,🖥️w↔,850), log(D.dsl,m ' ✓⌂is, send↑=',A_ThisFunc '•6'))
      dbgTT_isMod('🠿1ba')
    } else { ; not ⌂_.is
      if (prio := vk.get(A_PriorKey,'')) = vkC {
        if ⌂_.pos = ↓ { ; ↕xz) ↕01) _↕2a)
          ⌂_.pos := ↑, ⌂_.t := A_TickCount, ⌂_.is := false
          if stack⌂.Length > 1 { ; another modtap key exists
            alt⌂ := %stack⌂[-2]%, alt⌂ih := alt⌂.ih
            if alt⌂.pos = ↓ { ; and is active, send this modtap as a regular key to the top active callback
              vk_d := GetKeyVK(vkC), sc_d := GetKeySC(vkC), token := alt⌂.token ; decimal value
              Key↑_⌂(alt⌂ih, &vk_d, &sc_d, &token, '↕xz@' ⌂_.k) ; invoke callback directly, but use another modtap's IHooks (ours is already disabled)
              (dbg<min(d3,l3))?'':(m:='✗ _↕01) ⌂↓ <ΔH •⌂↑`n' dbg⌂ '↑ alone while ' alt⌂.dbg '↓`n🕐' ⌂_t '<' ⌂ΔH ' ' dbg⌂p(&⌂_), dbgTT(d3,m,2,,0,🖥️w↕*.86),log(l3,m,A_ThisFunc))
            } else { ; but was released, so ignore it ad act as usual
              SendInput('{blind}' '{' . vkC . ' down}{' . vkC . ' up}') ;
              (dbg<min(D.ds,D.dsl))?'':(m:='_↕2a) ⌂↓ <ΔH a⌂↓ •⌂↑`n' dbg⌂ '↑ alone after ' alt⌂.dbg '↑`n🕐' ⌂_t '<' ⌂ΔH ' ' dbg⌂p(&⌂_), dbgTT(d3,m,2,,0,🖥️w↕*.86),log(l3,m,A_ThisFunc))
            }
          } else {
            SendInput(  '{blind}' '{' . vkC . ' down}{' . vkC . ' up}') ; (~ does this) type the char right away to avoid delays (to be deleted later on match), use {blind} to retain ⇧◆⎇⎈ positions)
            (dbg<min(D.ds,D.dsl))?'':(m:='↕xz) ↕01) ⌂↓ <ΔH •⌂↑`n' dbg⌂ '↑ alone`n🕐' ⌂_t '<' ⌂ΔH ' prio=c' dbg⌂p(&⌂_) ' stack⌂<=1, c↕' '`n🖮↕¦' c '¦—————', dbgTT(D.ds,m,2,,0,🖥️w↕*.86),log(D.dsl,m,A_ThisFunc '•7'))
          }
        } else { ; 00) haven't been activated, but need to send self Up so other scripts can read it
          ⌂_.pos := ↑, ⌂_.t := A_TickCount, ⌂_.is := false
          SendInput('{blind}{' . vkC . ' up}') ; {blind} to retain ⇧◆⎇⎈ positions
          (dbg<min(d3,l3))?'':(m:='00) •⌂↑ alone ' dbg⌂p(&⌂_), dbgTT(d3,m,2,,🖥️w↔,850),log(l3,m))
          dbgTT_isMod('00)')
        }
      } else { ; ↕2a) ⌂↓ a↓ •⌂↑ a↑   fast typing ⌂,a
        ⌂_.pos := ↑, ⌂_.t := A_TickCount, ⌂_.is := false
        _sl:=A_SendLevel, SendLevel(1) ; main ⌂'s hook is monitoring at level 1, let it catch our sends to properly test whether ⌂ should be activate
        SendInput('{blind}' '{' . vkC . ' down}{' . vkC . ' up}') ; (~ does this) type the char right away to avoid delays (to be deleted later on match), use {blind} to retain ⇧◆⎇⎈ positions)
        SendInput(ih_input), SendLevel(_sl)
        (dbg<min(D.ds,D.dsl))?'':(m:='↕2a) ⌂↓ a↓ •⌂↑ a↑ (typing)`n' '🖮‘' c '’+‘' ih_input '’@L' 1 '_' _sl '—————(self+input) ' dbg⌂p(&⌂_), dbgTT(D.ds,m,4,,0),log(D.dsl,m,A_ThisFunc '•10'))
        dbgTT_isMod('↕2a)')
      }
    }
    ; log(0,'timings' format(" 🕐15Δ{:.3f}",🕐15-🕐14) format(" 🕐14Δ{:.3f}",🕐14-🕐13) format(" 🕐13Δ{:.3f}",🕐13-🕐12) format(" 🕐12Δ{:.3f}",🕐12-🕐11),A_ThisFunc) ;
  }

  if not is↓ { ;
    ;🕐2 := preciseTΔ()
    ⌂_t := A_TickCount - ⌂_.t
    handle⌂↑(&⌂_,&ih,&ihID,⌂_t) ;
    dbgTT_isMod('↑')
    ;🕐3 := preciseTΔ()
    ;🕐4 := preciseTΔ()
  } else { ; is↓
    ⌂_.pos := ↓, ⌂_.t := A_TickCount, ⌂_.prio↓ := A_PriorKey, ⌂_.prio↑ := ''
    dbgTT_isMod('↓')
    for ref⌂ in stack⌂ { ; since the setup⌂mo has a higher priority that active IHooks, the is↑ event that triggers the Key↑_⌂ callback will not print this mod key by confusing it with the 'x_x) a↓ ⌂↓ b↓ •a↑ ⌂↑ ↕' variant (it checks whether there are key↓ events that match the key↑ event, and there would be now key↓). So we need to manually add a modtap key↓ record to each of the active modtaps
      i⌂ := %ref⌂%
      if i⌂.HasOwnProp('ignoreall') { ; ignore modtap, treat as a regular key for an already active modtap
        variant := '✗all 1aa) ⌂↓ a↓ <ΔH•a↑ ⌂↑  (⌂ ignores a)'
        if ignore🛑 { ; force-cancel modtap, tweak sendlevel to allow the script to accept the generated Up event
          variant .= '🛑all'
          _sl:=A_SendLevel, SendLevel(i⌂.ih.MinSendLevel), SendEvent('{' i⌂.vk ' UP}'), SendLevel(_sl)
        }
        (dbg<D.dsl)?'':(log(D.dsl,variant '`n🖮‘' i⌂.k '’↑@L' i⌂.ih.MinSendLevel '_' _sl '—————',A_ThisFunc))
        return
      } else if ignored.Has(i⌂.flag) and
         ignored[           i⌂.flag].Has(vkC) { ; ignore modtap, treat as a regular key for an already active modtap
        variant := '✗ 1aa) ⌂↓ a↓ <ΔH•a↑ ⌂↑  (⌂ ignores a)'
        if ignore🛑 { ; force-cancel modtap, tweak sendlevel to allow the script to accept the generated Up event
          variant .= '🛑'
          _sl:=A_SendLevel, SendLevel(i⌂.ih.MinSendLevel), SendEvent('{' i⌂.vk ' UP}'), SendLevel(_sl)
        }
        (dbg<D.dsl)?'':(log(D.dsl,variant '`n🖮‘' i⌂.k '’↑@L' i⌂.ih.MinSendLevel '_' _sl '—————',A_ThisFunc))
        return ;
      }

      i⌂.K↓.push(GetKeyVK(vkC)) ; GetKeyVK = same integer format as kvk in Key↓_⌂ callbacks
    }
    stack⌂.Push(&⌂_)
    ih⌂.MinSendLevel	:= stack⌂.Length + 1
    ;🕐2 := preciseTΔ()
    ih⌂.Start()	       	; 0a) •⌂↓ do nothing yet, just activate IHooks
    dbg⌂ih     	:= dbg⌂	;
    (dbg<min(d5,D.dihl))?'':(m:=dbg⌂ '¦' dbg⌂ih '`nIH with callback cb⌂' ⌂_.k '_K↓ ↑ stack' stack⌂.Length ' +' ⌂_.k ' 🕐' preciseTΔ(), dbgTT(d5,m,2,D.i1↓,🖥️w↔//2,🖥️w↕*.89), log(D.dihl,'✓ih—————•⌂↓ ' m,A_ThisFunc '•12'))
    ;🕐3 := preciseTΔ()
    ih⌂.Wait()		; Waits until the Input is terminated (InProgress is false)
    ;🕐4 := preciseTΔ()

    if (ih⌂.EndReason  = "Timeout") { ;0t) Timed out after ⌂tHold
      SendInput(⌂_.send↓), ⌂_.is := true ;, dbgTT(d4,⌂_.🔣,t:='∞',D.i↗,🖥️w↔ - 40, 20)
      _ := stack⌂.Pop()
      tooltip⎀?(win.get⎀(&⎀←,&⎀↑,&⎀↔,&⎀↕), dbgTT(0,⌂_.🔣,'∞',D.i↗,⎀←-9,⎀↑-30)):''
      dbgTT_isMod('0t')
      (dbg<min(d5,D.dihl,D.dsl))?'':(m:=dbg⌂ ' ¦ ' dbg⌂ih '`n×IH ‘' ih⌂.EndReason '’ Input=¦' ih⌂.Input '¦  stack' stack⌂.Length ' −' %_%.k, dbgTT(d5,m,4,D.i0↓,🖥️w↔//2,🖥️w↕), log(D.dihl,m,A_ThisFunc,'✗ih—————🕐'), log(D.dsl,'🖮¦' ⌂_.send↓ '¦————— ⌂_↓ Timeout ⌂↓',A_ThisFunc '•13'))
    } else if (ih⌂.EndReason = "Stopped") {
      dbg⌂ih:='', ihID := {⌂:'',dbg:''}, _ := stack⌂.Pop() ; cleanup after handle⌂↑ or early ⌂🠿 in Key↑⌂
      (dbg<min(d5,D.dihl))?'':(m:=dbg⌂ ' ¦ ' dbg⌂ih '`n×IH ‘' ih⌂.EndReason '’ Input=¦' ih⌂.Input '¦  stack' stack⌂.Length ' −' %_%.k ' 🕐' preciseTΔ(), dbgTT(d5,m,4,D.i0↓,🖥️w↔//2,🖥️w↕), log(D.dihl,m,A_ThisFunc,'✗ih—————🛑'))
    ; } else if (ih⌂.EndReason = "Match") { ; Input matches one of the items in MatchList
    ; } else if (ih⌂.EndReason = "Max") { ; Input reached max length and it does not match any of the items in MatchList
    ; } else if (ih⌂.EndReason = "EndKey") { ; One of the EndKeys was pressed to terminate the Input
    } else { ;
      _ := stack⌂.Pop() ;???
      (dbg<min(d5,D.dihl))?'':(m:=dbg⌂ ' ¦ ' dbg⌂ih '`n×IH else, Input=' ih⌂.Input '  stack' stack⌂.Length ' −' %_%.k ' 🕐' preciseTΔ(), dbgTT(d5,m,4,D.i0↓,🖥️w↔//2,🖥️w↕), log(D.dihl,m,A_ThisFunc,'✗ih—————E'))
      ; return ih⌂.Input ; Returns any text collected since the last time Input was started
    }
  }
  ;🕐5 := preciseTΔ()
  ; log(0,'timings' format(" 🕐5Δ{:.3f}",🕐5-🕐4) format(" 🕐4Δ{:.3f}",🕐4-🕐3) format(" 🕐3Δ{:.3f}",🕐3-🕐2) format(" 🕐2Δ{:.3f}",🕐2-🕐1),A_ThisFunc) ;
}
