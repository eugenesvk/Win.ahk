#Requires AutoHotkey v2.0
; v0.3@23-12 Design overview and limitations @ github.com/eugenesvk/Win.ahk/blob/modtap/ReadMe.md
; —————————— User configuration ——————————
global ucfg⌂mod := Map(
  ; Key       	 Value	 |Default|Alternative¦
   'tooltip⎀'  	, true	;|true|	show a tooltip with activated modtaps near text caret (position isn't updated as the caret moves)
  ,'tt⎀delay' 	, 0   	;|0|   	seconds before a `tooltip⎀` is shown, helpful if you don't like tooltip flashes on using modtap only once for a single key (like ⇧), but would still like to have it to understand when `holdTimer` has been exceeded. If you release a modtap within this delay, `tooltip⎀` will be cancelled and not flash
  , 'holdTimer'	, 0.5 	;|.5|  	seconds of holding a modtap key after which it becomes a hold modifier
  , 'ignored'  	, Map(	;      	ignore specific key combos to avoid typing mistakes from doing something annoying (like ◆l locking your computer)
    ; key      	      	modifier bitflag (can be combined with bitwise and symbol ‘&’, alternative/or ‘|’ is not supported to make lookup easier)
    ;          	value 	list of alphanumeric key labels
     f‹⇧      	, 'qwertzxcvb␠'
    ,f⇧›      	, 'yuiopnm,./[]'
    ) ;
  ,'ignore🛑' 	, true  	;|true|	force stop the modtap after encountering an ignored key even if the physical key is being held, so if 'f' is ‹⇧ and 'e' is 'ignored':
    ;        	   true 	  f🠿e↕ will print 'fe' right away
    ;        	   false	  f🠿e↕ will print nothing, 'f↑' will print 'fe'
  ; Debugging	        	        	;
  , 'ttdbg'  	, false 	;|false|	show an empty (but visible) tooltip when modtap is deactivated
  , 'sndlvl' 	, 1     	;|1|    	register hotkeys with this sendlevel
  )
class udbg⌂mod { ; various debug constants like indices for tooltips
  static i↗	:= 19 ; dbgTT index, top right position of the empty status of our home row mod
  ,i↘t     	:=  8 ; dbgTT index, top down position of the key and modtap status (title)
  ,i↘      	:=  9 ; ... value
  ,i1↓     	:= 10 ; dbgTT index, bottom position for inputhooks on messages
  ,i0↓     	:= 11 ; ... off
  ,ik      	:= 13 ; dbgTT index for Key↓↑_⌂ functions
  ,dt      	:=  5 ; min debug level for the bottom-right status of all the keys
  ,ds      	:=  3 ; min debug level for Send events
}

; getKeyLabels_forVK(kvk:='vk20') ; ␠ ␣
getKeyLabels_forVK(kvk){
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
; ‹
⌂a := {k:'a',token:'a',mod:'LControl'} ; token can be used in function names
⌂s := {k:'s',token:'s',mod:'LWin'    }
⌂d := {k:'d',token:'d',mod:'LAlt'    }
⌂f := {k:'f',token:'f',mod:'LShift'  }
; ›
⌂j := {k:'j',token:'j',mod:'RShift'   }
⌂k := {k:'k',token:'k',mod:'RAlt'     }
⌂︔ := {k:';',token:'︔',mod:'RControl'}
⌂l := {k:'l',token:'l',mod:'RWin'     }

map⌂ := Map()
gen_map⌂() ; setup info and status fields for all the homerow mods
gen_map⌂(){
  static K  	:= keyConstant, vk:=K._map, vkr:=K._mapr, vkl:=K._maplng, vkrl:=K._maprlng, sc:=K._mapsc  ; various key name constants, gets vk code to avoid issues with another layout
    , ⌂tHold	:= ucfg⌂mod.Get('holdTimer',0.5) ;
  global map⌂
  map⌂['vk→⌂'] := Map()
  map⌂['flag→vk'] := Map()
   cb⌂a_K↑:=0,cb⌂s_K↑:=0,cb⌂d_K↑:=0,cb⌂f_K↑:=0,cb⌂j_K↑:=0,cb⌂k_K↑:=0,cb⌂l_K↑:=0,cb⌂︔_K↑:=0
  ,cb⌂a_K↓:=0,cb⌂s_K↓:=0,cb⌂d_K↓:=0,cb⌂f_K↓:=0,cb⌂j_K↓:=0,cb⌂k_K↓:=0,cb⌂l_K↓:=0,cb⌂︔_K↓:=0
  for i⌂ in [⌂a,⌂s,⌂d,⌂f,⌂j,⌂k,⌂l,⌂︔] {
    i⌂.t    	:= A_TickCount
    i⌂.vk   	:= vk[i⌂.k] ; vk21 for f
    i⌂.pos  	:= '↑'
    i⌂.is   	:= false ; is down
    i⌂.force↑	:= false ; this is set to true if we need to manually reset the status while the key is physically ↓
    i⌂.send↓	:= '{' i⌂.mod ' Down' '}'
    i⌂.send↑	:= '{' i⌂.mod ' Up'   '}'
    i⌂.🔣    	:= helperString.modi_ahk→sym(    i⌂.mod) ; ‹⇧
    i⌂.🔣ahk 	:= helperString.modi_ahk→sym_ahk(i⌂.mod) ; <+
    i⌂.flag 	:= f%i⌂.🔣%
    i⌂.dbg  	:= '⌂' i⌂.k i⌂.🔣 ;
    ; Track 	which keys have been pressed
    i⌂.prio↓	:= '' ; before a given modtap is down
    i⌂.prio↑	:= '' ;                          up
    ;       	while a given modtap is down
    i⌂.K↓   	:=  Array() ; key down events (track K↑ for a111 K↓ that happened before modtap)
    i⌂.K↑   	:=  Array() ; ... up
    ; Setup inputhook to manually handle input when modtap key is pressed
    ih              	:= InputHook("T" ⌂tHold) ; minSendLevel set within setup⌂mod depending on the stack order of a given modtap
    ih.KeyOpt(      	'{All}','N')  ; N: Notify. OnKeyDown/OnKeyUp callbacks to be called each time the key is pressed
    cb⌂%i⌂.token%_K↑	:= cb⌂_K↑.Bind(i⌂) ; ih,vk,sc will be added automatically by OnKeyUp
    cb⌂%i⌂.token%_K↓	:= cb⌂_K↓.Bind(i⌂) ; ...                                     OnKeyDown
    ih.OnKeyUp      	:= cb⌂%i⌂.token%_K↑	;
    ih.OnKeyDown    	:= cb⌂%i⌂.token%_K↓	; ;;;or cbkeys? and '{Left}{Up}{Right}{Down}' separately???
    i⌂.ih           	:= ih

    map⌂['vk→⌂'   ][i⌂.vk]  	:= i⌂
    map⌂['flag→vk'][i⌂.flag]	:= i⌂.vk
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
  key_actual := map⌂['vk→⌂']
  for i⌂ in [⌂a,⌂s,⌂d,⌂f,⌂j,⌂k,⌂l,⌂︔] {
    i⌂_act := key_actual[i⌂.vk]
    if i⌂_act.is {
      modtap_status	.= i⌂.🔣
    } else {
      modtap_status	.= '  '
    }
    if GetKeyState(i⌂.vk,"P") {
      iskeydown	.= ' ' i⌂.k
    } else { ;
      iskeydown	.= '  '
    }
  }
  dbg_val := (StrReplace(modtap_status,' ') = '' ? '' : modtap_status) '`n' (StrReplace(iskeydown,' ') = '' ? '' : iskeydown)
  if dbg_pre and not dbg_val = '`n' {
    dbg_title := dbg_pre '🕐' preciseTΔ()
  }
  return {dbgt:dbg_title,dbgv:dbg_val,modtap:modtap_status,key:iskeydown}
}

get⌂Status() {
  static bin→dec	:= numFunc.bin→dec.Bind(numFunc), dec→bin := numFunc.dec→bin.Bind(numFunc), nbase := numFunc.nbase.Bind(numFunc)
  bitflags := 0
  for modtap in [⌂a,⌂s,⌂d,⌂f,⌂j,⌂k,⌂l,⌂︔] {
    bitflags |= GetKeyState(modtap.vk,"P") ? modtap.flag : 0 ; modtap.is ? modtap.flag : 0
  } ; dbgTT(0,'bitflags ' dec→bin(bitflags) ' ‹' isAny‹ ' ›' isAny›,t:=5)
  return {isAny‹:bitflags & bit‹, isAny›:bitflags & bit›, bit:bitflags}
}

preciseTΔ() ; start timer for debugging

reg⌂map := Map() ; store registered keypairs 'vk46'='f'
register⌂()
register⌂() {
  static K	:= keyConstant, vk:=K._map, vkr:=K._mapr, vkl:=K._maplng, vkrl:=K._maprlng, sc:=K._mapsc  ; various key name constants, gets vk code to avoid issues with another layout
   , s    	:= helperString
  global reg⌂map
  loop parse 'fj' {
    kvk := vk[A_LoopField]
    hkreg1	:= ＄ kvk
    hkreg2	:= ＄ kvk ' UP' ; $kbd hook
    HotKey(hkreg1, hkModTap,'I1') ;
    HotKey(hkreg2, hkModTap,'I1') ;
    reg⌂map[hkreg1]     	:= {lbl:A_LoopField, is↓:1}
    reg⌂map[hkreg2]     	:= {lbl:A_LoopField, is↓:0}
    reg⌂map[A_LoopField]	:= {down:hkreg1, up:hkreg2}
  }
  ; HotKey(＄ f⃣	     , hkModTap) ;
  ; HotKey(＄ f⃣	' UP', hkModTap) ;
}
hkModTap(ThisHotkey) {
  static _ := 0
  , 🖥️w←,🖥️w↑,🖥️w→,🖥️w↓,🖥️w↔,🖥️w↕
  , _ := win.getMonWork(&🖥️w←,&🖥️w↑,&🖥️w→,&🖥️w↓,&🖥️w↔,&🖥️w↕) ; Get Monitor working area ;;; static, ignores monitor changes
  hk := ThisHotkey
  dbgTT(3,ThisHotkey ' lvl' A_SendLevel ' ThisHotkey@hkModTap',t:=2,,🖥️w↔,🖥️w↕*0.3) ;
  if reg⌂map.Has(ThisHotkey) {
    hk_reg := reg⌂map[ThisHotkey] ; f,↓or↑ for $vk46
    setup⌂mod(hk,hk_reg.lbl,hk_reg.is↓)
  } else {
    return ; msgbox('nothing matched setChar🠿 ThisHotkey=' . ThisHotkey)
  }
}
unregister⌂()
unregister⌂() {
  static k	:= keyConstant._map ; various key name constants, gets vk code to avoid issues with another layout
   , s    	:= helperString
   ; , k := helperString.key→token.Bind(helperString)
  static ⌂tHold := ucfg⌂mod.Get('holdTimer',0.5), ⌂ΔH := ⌂tHold * 1000, ttdbg := ucfg⌂mod.Get('ttdbg',0), sndlvl := ucfg⌂mod.Get('sndlvl',0)
  global  reg⌂map
  loop parse 'fj' {
    pre_ahk := ⌂%A_LoopField%.🔣ahk ; <+ for f and >+ for j
    hk_reg := reg⌂map[A_LoopField]
    , hkreg1  	:= pre_ahk hk_reg.down ; >+ ＄ vk       for j
    , hkreg2  	:= pre_ahk hk_reg.up   ; >+ ＄ vk ' UP'
    , token   	:= s.key→token(A_LoopField)
    , cbHotIf_	:= cbHotIf.Bind(token)
    HotIf cbHotIf_
    HotKey(hkreg1, hkDoNothing , "I" sndlvl) ; do nothing while home row mod is active _1)
    HotKey(hkreg2, hkModTap_off, "I" sndlvl) ; reset home row mod _2)
    HotIf
    reg⌂map[hkreg1]     	:= {lbl:A_LoopField, is↓:1}
    reg⌂map[hkreg2]     	:= {lbl:A_LoopField, is↓:0}
    reg⌂map[A_LoopField]	:= {down:hkreg1, up:hkreg2}
  }
}
cbHotIf(_token, HotkeyName) { ; callback for unregister⌂
  return ⌂%_token%.is ; token is ︔ for ; to be used in var names
}
hkModTap_off(ThisHotkey) {
  static D	:= udbg⌂mod, C := ucfg⌂mod
  hk_reg := reg⌂map[ThisHotkey]
  ⌂_ := ⌂%hk_reg.lbl%
  dbg⌂ := ⌂_.k ' ' ⌂_.🔣 ;
  static ⌂tHold := C.Get('holdTimer',0.5), ⌂ΔH := ⌂tHold * 1000, ttdbg := C.Get('ttdbg',0), sndlvl := C.Get('sndlvl',0)
    , 🖥️w←,🖥️w↑,🖥️w→,🖥️w↓,🖥️w↔,🖥️w↕
    , _ := win.getMonWork(&🖥️w←,&🖥️w↑,&🖥️w→,&🖥️w↓,&🖥️w↔,&🖥️w↕) ; Get Monitor working area ;;; static, ignores monitor changes
    , tooltip⎀ := C.Get('tooltip⎀',1), tt⎀delay := C.Get('tt⎀delay',0) * 1000
    , ttdbg := C.Get('ttdbg',0)
  t⌂_ := A_TickCount - ⌂f.t
  dbgTT(3,'🠿1bb) ⌂↓ >ΔH •⌂↑ 🕐' preciseTΔ() ' (hkModTap_off)`n' dbg⌂ ' ¦ ' hk_reg.lbl ' ¦ ' ThisHotkey ' (' t⌂_ (t⌂_<⌂ΔH?'<':'>') ⌂ΔH ') `n' ⌂_.send↑,t:=4,i:=13,0,🖥️w↕//2) ;
  SendInput(⌂_.send↑), ⌂_.is  := false, ⌂_.pos := '↑', ⌂_.t := A_TickCount ; 🠿1bb)
  , dbgTT(ttdbg?0:5,ttdbg?'`n':'',t:='∞',D.i↗,🖥️w↔ - 40, 20)
  if tooltip⎀ { ;
    win.get⎀(&⎀←,&⎀↑,&⎀↔:=0,&⎀↕:=0)
    if tt⎀delay { ; cancel a potential delayed timer
      set⎀TT(0)
    }
    dbgTT(0,'',t:='∞',D.i↗,⎀←-9,⎀↑-30) ; and remove a non-timer tooltip regardless of the timed one
  }
  dbgTT_isMod('🠿1bb')
}
hkDoNothing(ThisHotkey) {
  dbgTT(4,'hkDoNothing 🕐' preciseTΔ())
  return
}
get⌂dbg(⌂_) {
  static bin→dec	:= numFunc.bin→dec.Bind(numFunc), dec→bin := numFunc.dec→bin.Bind(numFunc), nbase := numFunc.nbase.Bind(numFunc)
   return ⌂_.dbg ⌂_.pos (⌂_.is ? '🠿' : '') ' send‘' ⌂_.send%(⌂_.pos)% '’ flag' dec→bin(⌂_.flag)
}

cb⌂_K↓(⌂_,  ih,vk,sc) { ;
  Key↓_⌂(ih,vk,sc,   &⌂_)
}
cb⌂_K↑(⌂_,  ih,vk,sc) {
  Key↑_⌂(ih,vk,sc,   &⌂_)
}

kvk→label(arr) { ; convert an array of decimal VK codes into an tring of English-based key names
  static K	:= keyConstant, vk:=K._map, vkr:=K._mapr, vkl:=K._maplng, vkrl:=K._maprlng, sc:=K._mapsc  ; various key name constants, gets vk code to avoid issues with another layout
  labels := ''
  ; labels := Array()
  ; dbgtxt := ''
  for kvk in arr {
    ; dbgtxt .= kvk '(' 'vk' hex(kvk) '→' vkrl['en'].Get('vk' hex(kvk),'✗') ')'
    ; labels.push(vkrl['en'].Get('vk' hex(kvk),'✗'))
    labels .= vkrl['en'].Get('vk' hex(kvk),'✗')
  }
  ; dbgTT(0, dbgtxt, t:=3) ;
  return labels
}

Key↓_⌂(ih,kvk,ksc,  &⌂_, dbgsrc:='') {
  static K	:= keyConstant, vk:=K._map, vkr:=K._mapr, vkl:=K._maplng, vkrl:=K._maprlng, vkrlen:=vkrl['en'], sc:=K._mapsc  ; various key name constants, gets vk code to avoid issues with another layout
    , s   	:= helperString
    , D   	:= udbg⌂mod
    , 🖥️w←,🖥️w↑,🖥️w→,🖥️w↓,🖥️w↔,🖥️w↕
    , _ := win.getMonWork(&🖥️w←,&🖥️w↑,&🖥️w→,&🖥️w↓,&🖥️w↔,&🖥️w↕) ; Get Monitor working area ;;; static, ignores monitor changes
    , ignored := getCfgIgnored()
    , dbl := 2
  dbg⌂ := ⌂_.k ' ' ⌂_.🔣 ⌂_.pos ;
  kvk_s := 'vk' hex(kvk), sc_s := 'sc' hex(ksc)
  ⌂_.K↓.push(kvk)
  ; keynm	:= vkrlen.Get('vk' hex(kvk),'✗')
  ; dbgTT(0,⌂_.dbg ' ' keynm '↓' kvk '_' hex(kvk),t:=5,16,0,0) ;
  variant	:= ''
  if ⌂_.pos = '↓' { ; should always be true? otherwise we won't get a callback
    if ignored.Has(⌂_.flag) and ;
       ignored[⌂_.flag].Has(kvk_s) { ; this modtap+key combo should be ignored
      variant	:= '✗✗✗↓ ignore'
    } else {
      variant	:= '✗ ?0b)'
    }
    if dbg >= dbl {
      keynm 	:= vkrl['en'].Get('vk' hex(kvk),'✗')
      prionm	:= vkrl['en'].Get(vk[A_PriorKey],'✗')
      t⌂_   	:= A_TickCount - ⌂_.t
      dbgTT(dbl,variant ' ' dbg⌂ '(' t⌂_ ') ' keynm '↓ prio ‘' prionm '’ ' kvk_s ' ' sc_s,t:=5,D.ik,🖥️w↔ - 40,🖥️w↕*.86) ; vk57 sc11
    }
  } else { ; should never get here?
    dbgMsg(0,dbg⌂ ' ↓' kvk_s ' ' sc_s ' 🕐' preciseTΔ()) ;
  }
}
Key↑_⌂(ih,kvk,ksc,  &⌂_, dbgsrc:='') { ;
  static K	:= keyConstant, vk:=K._map, vkr:=K._mapr, vkl:=K._maplng, vkrl:=K._maprlng, sc:=K._mapsc  ; various key name constants, gets vk code to avoid issues with another layout
    , s   	:= helperString
    , C   	:= ucfg⌂mod, D	:= udbg⌂mod
    , 🖥️w←,🖥️w↑,🖥️w→,🖥️w↓,🖥️w↔,🖥️w↕
    , _ := win.getMonWork(&🖥️w←,&🖥️w↑,&🖥️w→,&🖥️w↓,&🖥️w↔,&🖥️w↕) ; Get Monitor working area ;;; static, ignores monitor changes
    , tooltip⎀ := C.Get('tooltip⎀',1), tt⎀delay := C.Get('tt⎀delay',0) * 1000
    , ttdbg := C.Get('ttdbg',0)
    , ignored := getCfgIgnored()
    , ignore🛑 := C.Get('ignore🛑','true')
    , dbl := 3 ;
  global ⌂a,⌂s,⌂d,⌂f,⌂j,⌂k,⌂l,⌂︔
  dbg⌂ := ⌂_.k ' ' ⌂_.🔣 ⌂_.pos ;
  kvk_s := 'vk' hex(kvk), sc_s := 'sc' hex(ksc)
  ⌂_.K↑.push(kvk)
  if ⌂_.pos = '↓' { ; 1a)f
    dbg_min := min(D.ds,dbl)
    variant := '', pri₌ := '', 🕐 := (dbg >= dbg_min) ? preciseTΔ() : ''
    if A_PriorKey and ⌂_.vk = vk[A_PriorKey] {
      variant   :=  'xx) a↓ ⌂↓ •a↑ ⌂↑'      , pri₌ := '='
    } else if not HasValue(⌂_.K↓,kvk) { ;
      variant   := 'x_x) a↓ ⌂↓ b↓ •a↑ ⌂↑ ↕', pri₌ := '≠'
    } else {
      if ignored.Has(⌂_.flag) and
         ignored[⌂_.flag].Has(kvk_s) { ;       ignore this modtap+key combo
        variant := '✗ 1aa) ⌂↓ a↓ <ΔH•a↑ ⌂↑'
        if ignore🛑 { ; force-cancel modtap
          _SendLevel := A_SendLevel
          SendLevel ih.MinSendLevel ; tweak sendlevel to allow the script to accept the generated Up event
          SendEvent('{' ⌂_.vk ' UP}') ;
          SendLevel _SendLevel
          ; setup⌂mod(＄ ⌂_.vk ' UP',⌂_.k,is↓:='0') ; alternative way to cancel by calling the function directly
        }
      } else {                         ; don't ignore this modtap+key combo
        variant :=  '🠿1aa) ⌂↓ a↓ <ΔH•a↑ ⌂↑'
        SendInput(⌂_.send↓), ⌂_.is := true
        if tooltip⎀ {
          if tt⎀delay { ; delay showing tooltip
            set⎀TT(1, ⌂_.🔣)
          } else {
            win.get⎀(&⎀←,&⎀↑,&⎀↔:=0,&⎀↕:=0), dbgTT(0,⌂_.🔣,t:='∞',D.i↗,⎀←-9,⎀↑-30)
          }
        }
        SendInput('{' Format("vk{:x}sc{:x}",kvk,ksc) '}')
        dbgTT_isMod('🠿1aa')
        ; dbgTT(0,ih.Input '`n' (ih=⌂_.ih) ' 🕐' 🕐 '`n' ⌂_.ih.Input,t:=1) ;
        ; ih.Stop() ;
      }
    }
    if dbg >= dbg_min {
      keynm  	:= vkrl['en'].Get('vk' hex(kvk),'✗')
      ,prionm	:= vkrl['en'].Get(vk[A_PriorKey],'✗')
      ,prio↓ 	:= vkrl['en'].Get(vk.Get(⌂_.prio↓,''),'✗')
      ,t⌂_   	:= A_TickCount - ⌂_.t
      ; ,⌂K↓ 	:= Object2Str(kvk→label(⌂_.K↓))
      ; ,⌂K↑ 	:= Object2Str(kvk→label(⌂_.K↑))
      ,⌂K↓   	:= kvk→label(⌂_.K↓)
      ,⌂K↑   	:= kvk→label(⌂_.K↑)
    }
    if dbg >= dbl {
      dbgTT(dbl,variant ' (' dbgsrc ') 🕐' 🕐
        '`n' dbg⌂ ' ↑(' kvk_s ' ' sc_s ') prio ‘' prionm '’ ' pri₌ ⌂_.k ' prio⌂↓‘' prio↓ '’`nK↓' ⌂K↓ '`nK↑' ⌂K↑ '`nsend↓: ' ⌂_.send↓ keynm ' ¦ih: ' ih.input,t:=4,D.ik,A_ScreenWidth - 40) ;
    }
    if dbg >= D.ds {
      dbgTT(D.ds,variant ' 🕐' 🕐
        '`n' dbg⌂ '(' t⌂_ ') ' keynm '↑(' kvk_s ' ' sc_s ') prio ‘' prionm '’ ≠' ⌂_.k ' prio⌂↓‘' prio↓ '’`nK↓' ⌂K↓ '`nK↑' ⌂K↑ '`nsend↓: ' ⌂_.send↓ keynm ' ¦ih: ' ih.input,t:=4,D.ik+1,0,🖥️w↕//2) ;
    }
  } else { ; 2b) ⌂↓ a↓ ⌂↑ •a↑ ??? unreachable since ⌂_↑ cancels input hook and resets ⌂_.pos
    if dbg >= dbl { ;
      keynm 	:= vkrl['en'].Get('vk' hex(kvk),'✗')
      prionm	:= vkrl['en'].Get(vk[A_PriorKey],'✗') ;
      t⌂_   	:= A_TickCount - ⌂_.t
      dbgMsg(dbl,'✗do nothing`n 2b) ⌂↓ a↓ ⌂↑ •a↑ ⌂↑ 🕐' preciseTΔ() '`n' dbg⌂ ' 🕐' t⌂_ ' ' keynm '↑(' kvk_s ' ' sc_s ') prio ‘' prionm '’ ≠' ⌂_.k,'Key↑⌂')
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
  win.get⎀(&⎀←,&⎀↑,&⎀↔:=0,&⎀↕:=0), dbgTT(0,set⎀TT_txt,t:='∞',D.i↗,⎀←-9,⎀↑-30)
}

vk→token(kvk) {
  static K    	:= keyConstant, vk:=K._map, vkr:=K._mapr, vkl:=K._maplng, vkrl:=K._maprlng, sc:=K._mapsc  ; various key name constants, gets vk code to avoid issues with another layout
   , s        	:= helperString
   , kvk→token	:= Map()
   , isInit   	:= false
  if not isInit {
    for i⌂ in [⌂a,⌂s,⌂d,⌂f,⌂j,⌂k,⌂l,⌂︔] {
      kvk→token[i⌂.vk]	:= i⌂.token
    }
    isInit := true
  }
  return kvk→token[kvk]
}

setup⌂mod(hk,c,is↓) { ; hk=$vk46 or $vk46 UP   c=f   is↓=0 or 1
  static K  	:= keyConstant, vk:=K._map, vkr:=K._mapr, vkl:=K._maplng, vkrl:=K._maprlng, sc:=K._mapsc  ; various key name constants, gets vk code to avoid issues with another layout
   , bin→dec	:= numFunc.bin→dec.Bind(numFunc), dec→bin := numFunc.dec→bin.Bind(numFunc), nbase := numFunc.nbase.Bind(numFunc)
   , get⎀   	:= win.get⎀.Bind(win), get⎀GUI	:= win.get⎀GUI.Bind(win), get⎀Acc := win.get⎀Acc.Bind(win)
   , s      	:= helperString
   , D      	:= udbg⌂mod, cfg := ucfg⌂mod
   , breaks 	:= '' ; break ↑ with these keys
   , 🖥️w←,🖥️w↑,🖥️w→,🖥️w↓,🖥️w↔,🖥️w↕
   , _       	:= win.getMonWork(&🖥️w←,&🖥️w↑,&🖥️w→,&🖥️w↓,&🖥️w↔,&🖥️w↕) ; Get Monitor working area ;;; static, ignores monitor changes
   , ⌂tHold  	:= cfg.Get('holdTimer',0.5) ;
   , ⌂ΔH     	:= ⌂tHold * 1000
   , tooltip⎀	:= cfg.Get('tooltip⎀',1), tt⎀delay := cfg.Get('tt⎀delay',0) * 1000
   , ttdbg   	:= cfg.Get('ttdbg',0) ;
   , d3      	:= 3 ; custom dbg level for testing selected commands
   , d4      	:= 4 ;
   , d5      	:= 5 ;
   , isInit  	:= false ;
   , dbg⌂ih  	:= ''
      ; I1 sendlevel (ignore regular keys sent at level 0)
      ; L1024 def don't need many since after a short hold timer a permanent mode will set, the hoook will reset
   , stack⌂	:= [] ; track the level of a modtap key's inputhook in the stack (also used to set minsendlevel to allow sending keys to only the most recent hook)
  ; dbgTT(0,hk ' ' c ' ' is↓,t:='∞',i:=7,0,0) ;


  if not isInit {
    isInit	:= true
  }

  global ⌂a,⌂s,⌂d,⌂f,⌂j,⌂k,⌂l,⌂︔

  vkC := vk[c] ; c=f, vkC=vk46
  this⌂ := map⌂['vk→⌂'].Get(vkC, '')
  if not this⌂ { ;
    throw ValueError("Unknow modtap key!", -1, c ' ' vkC)
  }
  ih⌂ 	:= this⌂.ih
  dbg⌂	:= '⌂' this⌂.k this⌂.🔣 ;
  dbgorder := Map('a',[1,4], 's',[1,3], 'd',[1,2], 'f',[1,1]
                 ,';',[0,4], 'l',[0,3], 'k',[0,2], 'j',[0,1])
  modtapflags	:= get⌂Status() ; {isAny‹,isAny›,bit}
  bit⌂       	:= modtapflags.bit
  isAny‹     	:= modtapflags.isAny‹
  isAny›     	:= modtapflags.isAny›
  isThis‹    	:= this⌂.flag & bit‹
  isThis›    	:= this⌂.flag & bit›
  isOpp      	:= (isThis‹ and isAny›)
    or     (isThis› and isAny‹)
    ; dbgTT(d4,isOpp ' isOpp`n' isThis‹ ' ' isAny› '`n' isThis› ' ' isAny‹,3)
  static tmpid := 2
  if tmpid > 5 {
    tmpid := 2
  }
  dbgTT(d3, c ' ' vkC ' is' (is↓ ? '↓' : '↑') this⌂.pos (this⌂.is ? '🠿' : '') ' isOpp' isOpp ' stack' stack⌂.Length ' 🕐' preciseTΔ() '`n@setup⌂',t:='∞',tmpid
   ,🖥️w↔*(1  - dbgorder.Get(c,0)[1]*.24)
   ,🖥️w↕*(.5 + dbgorder.Get(c,0)[2]*.05 + is↓ * .06) ) ;
  tmpid += 1 ;

  is↑ := not is↓ ;

  handle⌂↑(&this⌂,&ih,&ihID,this⌂t) { ; allows calling called either when a single ⌂ or combined
    if this⌂.force↑ { ; already handled ⌂↑ via an artifical send in ignore🛑 condition, so reset it and return without printing an extra ⌂.k
      this⌂.force↑ := false
      return
    }
    if (is↓phys := GetKeyState(this⌂.k,'P')) {
      this⌂.force↑ := true
    }
    this⌂.prio↓ := '', this⌂.prio↑ := A_PriorKey, this⌂.K↓ := Array(), this⌂.K↑ := Array()
    ih_input := ''
    if ih⌂.InProgress { ;
      ih_input	:= ih⌂.Input
      dbgTT(d5,'×IH handle⌂↑, input=' ih_input ' stack' stack⌂.Length ' 🕐' preciseTΔ(),t:=4,7) ; I
      ih⌂.Stop() ; stack cleaned up when handling ih.reason so that it's possible to stop at Key↓↑ functions
    }
    ; dbgTT(0,'✗post stop stack' stack⌂.Length ' 🕐' preciseTΔ(),'∞',8,0,0) ; II (stop III)
    if this⌂.is { ; 🠿1ba)
      SendInput(this⌂.send↑)
      if tooltip⎀ {
        if tt⎀delay { ; hide the caret tooltip before it's shown if delay hasn't expired yet
          set⎀TT(0)
        }
        win.get⎀(&⎀←,&⎀↑,&⎀↔:=0,&⎀↕:=0), dbgTT(0,'',t:='∞',D.i↗,⎀←-9,⎀↑-30) ; and hide a non-delayed one
      }
      this⌂.pos := '↑', this⌂.t := A_TickCount, this⌂.is := false, dbgTT(tooltip⎀?0:1,ttdbg?'`n':'',t:='∞',D.i↗,🖥️w↔ - 40, 20)
      dbgTT(D.ds,'🠿1ba) this⌂↑ after sequenced this⌂🠿(' this⌂t (this⌂t<⌂ΔH?'<':'>') ⌂ΔH ') 🕐' preciseTΔ() ' input=‘' ih_input '’',t:=2,,x:=🖥️w↔,y:=850)
      dbgTT_isMod('🠿1ba')
    } else {
      if (prio := vk[A_PriorKey]) = vkC {
        if this⌂.pos = '↓' { ; ↕xz) ↕01)
          this⌂.pos := '↑', this⌂.t := A_TickCount, this⌂.is := false, dbgTT(tooltip⎀?0:5,ttdbg?'`n':'',t:='∞',D.i↗,🖥️w↔ - 40, 20)
          if stack⌂.Length > 1 { ; another modtap key is active, send this modtap as a regular key to the top active callback
            alt⌂ := stack⌂[-2], alt⌂ih := alt⌂.ih
            vk_d := GetKeyVK(vkC), sc_d := GetKeySC(vkC) ; decimal value
            Key↑_⌂(alt⌂ih, vk_d, sc_d, &alt⌂, '↕xz') ; invoke callback directly, but use another modtap's inputhook (ours is already disabled)
            dbgTT(d3,'✗ _↕01) ⌂↓ <ΔH •⌂↑`n' dbg⌂ '↑ alone while ' alt⌂.dbg '↓`n🕐' this⌂t '<' ⌂ΔH ' PreKey ‘' A_PriorKey '’ prio=‘' prio '’ 🕐' preciseTΔ() ' input=‘' ih_input '’ this⌂.is=' this⌂.is ' this⌂.pos=' this⌂.pos,t:=2,,0,🖥️w↕*.86) ;
          } else { ;
            SendInput('{blind}' '{' . vkC . ' down}{' . vkC . ' up}') ; (~ does this) type the char right away to avoid delays (to be deleted later on match), use {blind} to retain ⇧◆⎇⎈ positions)
            dbgTT(D.ds,'↕xz) ↕01) ⌂↓ <ΔH •⌂↑`n' dbg⌂ '↑ alone`n🕐' this⌂t '<' ⌂ΔH ' PreKey ‘' A_PriorKey '’ prio=‘' prio '’ 🕐' preciseTΔ() ' input=‘' ih_input '’ this⌂.is=' this⌂.is ' this⌂.pos=' this⌂.pos,t:=2,,0,🖥️w↕*.86)
          } ;
        } else { ; 00) haven't been activated, no need to send self
          this⌂.pos := '↑', this⌂.t := A_TickCount, this⌂.is := false, dbgTT(tooltip⎀?0:5,ttdbg?'`n':'',t:='∞',D.i↗,🖥️w↔ - 40, 20)
          dbgTT(d3,'✗ 00) this⌂↑ alone this⌂↓(' this⌂t ' < ' ⌂ΔH ') PreKey ‘' A_PriorKey '’ prio=‘' prio '’ 🕐' preciseTΔ() ' input=‘' ih_input '’ this⌂.is=' this⌂.is ' this⌂.pos=' this⌂.pos,t:=2,,x:=🖥️w↔,y:=850)
          dbgTT_isMod('00)')
        }
      } else { ; ↕2a) ⌂↓ a↓ •⌂↑ a↑   fast typing ⌂,a
        this⌂.pos := '↑', this⌂.t := A_TickCount, this⌂.is := false, dbgTT(tooltip⎀?0:5,ttdbg?'`n':'',t:='∞',D.i↗,🖥️w↔ - 40, 20)
        keynm := vkrl['en'].Get(prio,'✗')
        dbgTT(D.ds,'↕2a) ⌂↓ a↓ •⌂↑ a↑ (typing)`n' keynm ' (' A_PriorKey ') PriK, print self+input ‘' c '’+‘' ih_input '’',t:=4,,x:=0)  ;
        dbgTT_isMod('↕2a)')
        SendLevel 1 ; main ⌂'s hook is monitoring at level 1, let it catch our sends to properly test whether ⌂ should be activate
        SendInput('{blind}' '{' . vkC . ' down}{' . vkC . ' up}') ; (~ does this) type the char right away to avoid delays (to be deleted later on match), use {blind} to retain ⇧◆⎇⎈ positions)
        SendInput(ih_input) ;
        SendLevel 0 ;
      }
    }
  }

  if is↑ { ;
    this⌂t := A_TickCount - this⌂.t
    handle⌂↑(&this⌂,&ih,&ihID,this⌂t) ;
    dbgTT_isMod('↑')
  } else { ; is↓
    ; dbgTT(d4,'is↓' is↓ ' 🕐' preciseTΔ(),t:=3,i:=13,x:=🖥️w↔,y:=300) ;
    this⌂.pos := '↓', this⌂.t := A_TickCount, this⌂.prio↓ := A_PriorKey, this⌂.prio↑ := ''
    dbgTT_isMod('↓')
    for i⌂ in stack⌂ { ; since the setup⌂mod has a higher priority that active inputhooks, the is↑ event that triggers the Key↑_⌂ callback will not print this mod key by confusing it with the 'x_x) a↓ ⌂↓ b↓ •a↑ ⌂↑ ↕' variant (it checks whether there are key↓ events that match the key↑ event, and there would be now key↓). So we need to manually add a modtap key↓ record to each of the active modtaps
      i⌂.K↓.push(GetKeyVK(vkC)) ; GetKeyVK = same integer format as kvk in Key↓_⌂ callbacks
    }
    stack⌂.Push(this⌂)
    ih⌂.MinSendLevel	:= stack⌂.Length + 1
    ih⌂.Start()     	       	; 0a) •⌂↓ do nothing yet, just activate inputhook
    dbg⌂ih          	:= dbg⌂	;
    dbgTT(d5,dbg⌂ '¦' dbg⌂ih '`nIH with callback cb⌂' this⌂.k '_K↓ ↑ stack' stack⌂.Length ' 🕐' preciseTΔ(),t:=2,D.i1↓,🖥️w↔//2,🖥️w↕*.89) ;
    ih⌂.Wait()		; Waits until the Input is terminated (InProgress is false)

    if (ih⌂.EndReason  = "Timeout") { ;0t) Timed out after ⌂tHold
      SendInput(this⌂.send↓), this⌂.is := true ;, dbgTT(d4,this⌂.🔣,t:='∞',D.i↗,🖥️w↔ - 40, 20)
      if tooltip⎀ {
        win.get⎀(&⎀←,&⎀↑,&⎀↔:=0,&⎀↕:=0), dbgTT(0,this⌂.🔣,t:='∞',D.i↗,⎀←-9,⎀↑-30)
      }
      dbgTT_isMod('0t')
      _ := stack⌂.Pop() ;
      dbgTT(d5,dbg⌂ ' ¦ ' dbg⌂ih '`n×IH ‘' ih⌂.EndReason '’ Input=' ih⌂.Input '  stack' stack⌂.Length ' ',t:=4,D.i0↓,🖥️w↔//2,🖥️w↕)
    } else if (ih⌂.EndReason = "Stopped") {
      dbg⌂ih:='', ihID := {⌂:'',dbg:''}, _ := stack⌂.Pop() ; cleanup after handle⌂↑ or early ⌂🠿 in Key↑⌂
      dbgTT(d5,dbg⌂ ' ¦ ' dbg⌂ih '`n×IH ‘' ih⌂.EndReason '’ Input=' ih⌂.Input '  stack' stack⌂.Length ' 🕐' preciseTΔ(),t:=4,D.i0↓,🖥️w↔//2,🖥️w↕)
    ; } else if (ih⌂.EndReason = "Match") { ; Input matches one of the items in MatchList
    ; } else if (ih⌂.EndReason = "Max") { ; Input reached max length and it does not match any of the items in MatchList
    ; } else if (ih⌂.EndReason = "EndKey") { ; One of the EndKeys was pressed to terminate the Input
    } else { ;
      _ := stack⌂.Pop() ;???
      dbgTT(d5,dbg⌂ ' ¦ ' dbg⌂ih '`n×IH else, Input=' ih⌂.Input '  stack' stack⌂.Length ' ',t:=4,D.i0↓,🖥️w↔//2,🖥️w↕)
      ; return ih⌂.Input ; Returns any text collected since the last time Input was started
    }
  }
}
