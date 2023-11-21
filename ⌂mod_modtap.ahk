#Requires AutoHotkey v2.0

/*
Can't rely just on timings to determine the ⌂ key status since it's impossible to get right, so
2 variants to set the HOLD status of a ⌂ key:
  1) time     definitely a HOLD if held longer than LongH (a↓ should type ⇧A right away without waiting for a↑) (A_TickCount stored in ⌂ to compare to A_TickCount at key press)
  2) sequence maybe      a HOLD depending on the following key sequence (whether you get a↓a↑ or a↓⌂↑a↑). When it's determined (a↓a↑), ⌂.mod is set
Legend:
  ↓ key down
  ↑ key up
  ↕ key tap
  🠿 key hold
  • perform action at this point
  •>ΔH perform action at this point only after ⌂tHold seconds
  ⌂ home row modtap key (e.g., f⃣ types ‘f’ with a single tap, but becomes ⇧ on hold)
  a any regular key (not modtap)
⌂↓ always activates our modtap input handler, so won't be marked as •
Key sequences and how to treat them (labels are also added to the script in linecomments):
Sequence    Label Comment
a↓ ⌂↓ a↑ ⌂↑ ↕     modtap starts after another key, should let the prior key finish
      •      xx)  print nothing (a is printed outside of this script)
         •  ↕xz)  print ⌂
⎈↓ ⌂↓ ⎈↑⌂↑       not a tap, swallowed by the modifier
         •   00)  print nothing
⌂↓       ⌂↑ ↕     single standalone tap, not hold
     <ΔH •  ↕01)  print ⌂
    •>ΔH    🠿0t)  enable ⌂ (⇧⌂ enabled on timer via input hook's timeout)
⌂↓ a↓ ⌂↑ a↑ ↕     should be ⌂,a as that's just fast typing
•            0a)  print nothing, don't know the future yet, just activate input hook
<ΔH•         ?0b) print nothing, don't know whether to print ⇧A or ⌂,a, the hold depends on the next key sequence
      •     ↕2a)  print ⌂,a
         •  ↕2b)  print nothing, 2a handle it
>ΔH•        🠿0c) print ⇧A (⇧⌂ enabled on timer 🠿0t), A is printed outside of the scripts purview)
⌂↓ a↓ a↑ ⌂↑ 🠿    should be ⇧A, not ⌂
   •              same as above
   <ΔH•     🠿1aa) print ⇧A, also set ⌂ var as a modifier since we know it's not quick typing
   <ΔH   •  🠿1ba) print nothing, 1a handles key, ⌂ is a mod
   >ΔH•     🠿1ab) print nothing, 0c handled key↓ (⇧⌂ enabled on timer 🠿0t)
   >ΔH   •  🠿1bb) print nothing, 1a handles key, ⌂ is a mod

if ⌂🠿
  a↓...      __)  not tracked, regular typing with modtap enabled
  ⌂↓   ⌂↑
  •          _1)  do nothing, block repeat of the
       •     _2)  reset
if alt⌂↓          another modtap key is active (but not switched to a hold yet, so inputhook is in progress)
⌂↓       ⌂↑ ↕     single standalone tap, not hold
     <ΔH •  _↕01)  print ⌂
    •>ΔH    _🠿0t)  enable ⌂ (⇧⌂ enabled on timer via input hook's timeout of the alt⌂)

Tests:

f↓j↓f↑w fW (f while another modtap is being held should count as a regular f key, the next W quick tap should work just like regular j↓w↓↑ quick W tap)
f↓j↕f↑ J, not jfjfjjf
hold f+j ~.5sec and release was bugging with unreachable 2b), though seems to be resolved with moving dbg tooltips to fire after the keypresses
f↓j↓w↕↑f↑ W (with ⇧› enabled since j was the last activated inputhook so it has a priority over f's ‹⇧
*/

; —————————— User configuration ——————————
global ucfg⌂mod := Map(
   'tooltip⎀'  	, true 	;|true| 	show a tooltip with activated modtaps near text caret (position isn't updated as the caret moves)
  , 'holdTimer'	, 0.5  	;|.5|   	seconds of holding a modtap key after which it becomes a hold modifier
  ; Debugging  	       	        	;
  , 'ttdbg'    	, false	;|false|	show an empty (but visible) tooltip when modtap is deactivated
  , 'sndlvl'   	, 1    	;|1|    	register hotkeys with this sendlevel
  )
i↗ 	:= 19 ; dbgTT index, top right position of the empty status of our home row mod
i↘t	:=  8 ; dbgTT index, top down position of the key and modtap status (title)
i↘ 	:=  9 ; ... value
i1↓	:= 10 ; dbgTT index, bottom position for inputhooks on messages
i0↓	:= 11 ; ... off
_dt	:=  5 ; min debug level for the bottom-right status of all the keys

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
  global map⌂
  map⌂['vk→⌂'] := Map()
  map⌂['flag→vk'] := Map()
  for i⌂ in [⌂a,⌂s,⌂d,⌂f,⌂j,⌂k,⌂l,⌂︔] {
    i⌂.t                    	:= A_TickCount
    i⌂.vk                   	:= helperString.key→ahk(i⌂.k) ; vk21 for f
    i⌂.pos                  	:= '↑'
    i⌂.is                   	:= false ; is down
    i⌂.send↓                	:= '{' i⌂.mod ' Down' '}'
    i⌂.send↑                	:= '{' i⌂.mod ' Up'   '}'
    i⌂.🔣                    	:= helperString.modi_ahk→sym(    i⌂.mod) ; ‹⇧
    i⌂.🔣ahk                 	:= helperString.modi_ahk→sym_ahk(i⌂.mod) ; <+
    i⌂.flag                 	:= f%i⌂.🔣%
    i⌂.dbg                  	:= '⌂' i⌂.k i⌂.🔣 ;
    map⌂['vk→⌂'][i⌂.vk]     	:= i⌂
    map⌂['flag→vk'][i⌂.flag]	:= i⌂.vk
  }
}
dbgtt_ismod(dbg_pre:='') { ;
  static _ := 0
    , 🖥️w←,🖥️w↑,🖥️w→,🖥️w↓,🖥️w↔,🖥️w↕
    , _ := win.getMonWork(&🖥️w←,&🖥️w↑,&🖥️w→,&🖥️w↓,&🖥️w↔,&🖥️w↕) ; Get Monitor working area ;;; static, ignores monitor changes
  if dbg >= _dt {
    ismod := getDbgKeyStatusS(dbg_pre)
    , dbgtt(_dt,ismod.dbgt,t:='∞',i↘t,🖥️w↔,🖥️w↕*.91) ; title message
    , dbgtt(_dt,ismod.dbgv,t:='∞',i↘ ,🖥️w↔,🖥️w↕) ; ↑/↓ status of all the asdfjkl; keys and their ⌂mod
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
  } ; dbgtt(0,'bitflags ' dec→bin(bitflags) ' ‹' isAny‹ ' ›' isAny›,t:=5)
  return {isAny‹:bitflags & bit‹, isAny›:bitflags & bit›, bit:bitflags}
}

preciseTΔ() ; start timer for debugging

reg⌂map := Map() ; store registered keypairs 'vk46'='f'
register⌂()
register⌂() {
  static k	:= keyConstant._map, kr	:= keyConstant._mapr ; various key name constants, gets vk code to avoid issues with another layout
   , s    	:= helperString
  global reg⌂map
  loop parse 'fj' {
    vk := s.key→ahk(A_LoopField)
    hkreg1	:= ＄ vk
    hkreg2	:= ＄ vk ' UP' ; $kbd hook
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
  dbgtt(3,ThisHotkey ' lvl' A_SendLevel ' ThisHotkey@hkModTap',t:=2,,🖥️w↔,🖥️w↕*0.3) ;
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
  hk_reg := reg⌂map[ThisHotkey]
  ⌂_ := ⌂%hk_reg.lbl%
  dbg⌂ := ⌂_.k ' ' ⌂_.🔣 ;
  static ⌂tHold := ucfg⌂mod.Get('holdTimer',0.5), ⌂ΔH := ⌂tHold * 1000, ttdbg := ucfg⌂mod.Get('ttdbg',0), sndlvl := ucfg⌂mod.Get('sndlvl',0)
    , 🖥️w←,🖥️w↑,🖥️w→,🖥️w↓,🖥️w↔,🖥️w↕
    , _ := win.getMonWork(&🖥️w←,&🖥️w↑,&🖥️w→,&🖥️w↓,&🖥️w↔,&🖥️w↕) ; Get Monitor working area ;;; static, ignores monitor changes
    , tooltip⎀ := ucfg⌂mod.Get('tooltip⎀',1), ttdbg := ucfg⌂mod.Get('ttdbg',0)
  t⌂_ := A_TickCount - ⌂f.t
  dbgtt(3,'🠿1bb) ⌂↓ >ΔH •⌂↑ ' preciseTΔ() ' (hkModTap_off)`n' dbg⌂ ' ¦ ' hk_reg.lbl ' ¦ ' ThisHotkey ' (' t⌂_ (t⌂_<⌂ΔH?'<':'>') ⌂ΔH ') `n' ⌂_.send↑,t:=4,i:=13,0,🖥️w↕//2) ;
  SendInput(⌂_.send↑), ⌂_.is  := false, ⌂_.pos := '↑', ⌂_.t := A_TickCount ; 🠿1bb)
  , dbgTT(ttdbg?0:5,ttdbg?'`n':'',t:='∞',i↗,🖥️w↔ - 40, 20)
  if tooltip⎀ { ;
    win.get⎀(&⎀←,&⎀↑,&⎀↔:=0,&⎀↕:=0), dbgtt(0,'',t:='∞',i↗,⎀←-9,⎀↑-30)
  }
  dbgtt_ismod('🠿1bb')
}
hkDoNothing(ThisHotkey) {
  dbgtt(4,'hkDoNothing ' preciseTΔ())
  return
}
get⌂dbg(⌂_) {
  static bin→dec	:= numFunc.bin→dec.Bind(numFunc), dec→bin := numFunc.dec→bin.Bind(numFunc), nbase := numFunc.nbase.Bind(numFunc)
   return ⌂_.dbg ⌂_.pos (⌂_.is ? '🠿' : '') ' send‘' ⌂_.send%(⌂_.pos)% '’ flag' dec→bin(⌂_.flag)
}

cb⌂_Key↓(⌂_,  ih,vk,sc) { ;
  Key↓_⌂(ih,vk,sc,   &⌂_)
}
cb⌂_Key↑(⌂_,  ih,vk,sc) {
  Key↑_⌂(ih,vk,sc,   &⌂_)
}

Key↓_⌂(ih,kvk,ksc,  &⌂_, dbgsrc:='') {
  static K	:= keyConstant, vk:=K._map, vkr:=K._mapr, vkl:=K._maplng, vkrl:=K._maprlng, sc:=K._mapsc  ; various key name constants, gets vk code to avoid issues with another layout
    , s   	:= helperString
    , 🖥️w←,🖥️w↑,🖥️w→,🖥️w↓,🖥️w↔,🖥️w↕
    , _ := win.getMonWork(&🖥️w←,&🖥️w↑,&🖥️w→,&🖥️w↓,&🖥️w↔,&🖥️w↕) ; Get Monitor working area ;;; static, ignores monitor changes
    , dbl := 2
  dbg⌂ := ⌂_.k ' ' ⌂_.🔣 ⌂_.pos ;
  kvk_s := 'vk' hex(kvk), sc_s := 'sc' hex(ksc)
  if ⌂_.pos = '↓' { ; ?0b) should always be true? otherwise we won't get a callback
    if dbg >= 2 {
      keynm 	:= kr['en'].Get('vk' hex(vk),'✗')
      prionm	:= kr['en'].Get(s.key→ahk(A_PriorKey),'✗')
      ⌂_    	:= A_TickCount - ⌂_.t
      dbgtt(2,'✗ ?0b) ' dbg⌂ '(' ⌂_ ') ' keynm '↓ prio ‘' prionm '’ vk' hex(vk) ' sc' hex(sc),t:=5,,🖥️w↔ - 40,🖥️w↕*.86) ; vk57 sc11
    }
  } else { ; should never get here?f
    dbgMsg(0,dbg⌂ ' ↓' kvk_s ' ' sc_s ' ' preciseTΔ()) ;
  }
}
Key↑_⌂(ih,kvk,ksc,  &⌂_, dbgsrc:='') { ;
  static k	:= keyConstant._map, lbl := keyConstant._labels, kr	:= keyConstant._mapr ; various key name constants, gets vk code to avoid issues with another layout
   , s    	:= helperString
    , 🖥️w←,🖥️w↑,🖥️w→,🖥️w↓,🖥️w↔,🖥️w↕
    , _ := win.getMonWork(&🖥️w←,&🖥️w↑,&🖥️w→,&🖥️w↓,&🖥️w↔,&🖥️w↕) ; Get Monitor working area ;;; static, ignores monitor changes
   , tooltip⎀ := ucfg⌂mod.Get('tooltip⎀',1), ttdbg := ucfg⌂mod.Get('ttdbg',0)
  global ⌂a,⌂s,⌂d,⌂f,⌂j,⌂k,⌂l,⌂︔
  dbg⌂ := ⌂_.k ' ' ⌂_.🔣 ⌂_.pos ;
  if ⌂_.pos = '↓' { ; 1a)
    if ⌂_.vk = s.key→ahk(A_PriorKey) { ; xx) a↓ ⌂↓ •a↑ ⌂↑
      dbgtt(2,'xx) a↓ ⌂↓ •a↑ ⌂↑ (' dbgsrc ')`n' dbg⌂ ' vk↑' hex(kvk) ' sc' hex(ksc) ' PreK=' A_PriorKey '=' ⌂_.k ' ' preciseTΔ(),t:=4,i:=12,A_ScreenWidth - 40) ;
    } else { ; 🠿1aa) ⌂↓ a↓ <ΔH•a↑ ⌂↑
      if dbg >= 2 { ;
        keynm 	:= kr['en'].Get('vk' hex(kvk),'✗')
        prionm	:= kr['en'].Get(s.key→ahk(A_PriorKey),'✗')
        t⌂_   	:= A_TickCount - ⌂_.t
        dbgtt(2,'🠿1aa) ⌂↓ a↓ <ΔH•a↑ ⌂↑ ' preciseTΔ() '`n' dbg⌂ '(' t⌂_ ') ' keynm '↑(vk' hex(kvk) 'sc' hex(ksc) ') prio ‘' prionm '’ ≠' ⌂_.k '`n' ⌂_.send↓ ' ' keynm,t:=4,i:=13,0,🖥️w↕//2) ;
      }
      SendInput(⌂_.send↓), ⌂_.is := true
      if tooltip⎀ {
        win.get⎀(&⎀←,&⎀↑,&⎀↔:=0,&⎀↕:=0), dbgTT(0,⌂_.🔣,t:='∞',i↗,⎀←-9,⎀↑-30)
      }
      SendInput('{' Format("vk{:x}sc{:x}",kvk,ksc) '}')
      dbgtt_ismod('🠿1aa')
      ih.Stop()
    }
  } else { ; 2b) ⌂↓ a↓ ⌂↑ •a↑ ??? unreachable since ⌂_↑ cancels input hook and resets ⌂_.pos
    if dbg >= 2 { ;
      keynm 	:= kr['en'].Get('vk' hex(kvk),'✗')
      prionm	:= kr['en'].Get(s.key→ahk(A_PriorKey),'✗') ;
      t⌂_   	:= A_TickCount - ⌂_.t
      dbgMsg(2,'✗do nothing`n 2b) ⌂↓ a↓ ⌂↑ •a↑ ⌂↑ ' preciseTΔ() '`n' dbg⌂ ' 🕐' t⌂_ ' ' keynm '↑(vk' hex(kvk) ' sc' hex(ksc) ') prio ‘' prionm '’ ≠' ⌂_.k,'Key↑⌂')
    }
  }
}

setup⌂mod(hk,c,is↓) { ;
  static K  	:= keyConstant, vk:=K._map, vkr:=K._mapr, vkl:=K._maplng, vkrl:=K._maprlng, sc:=K._mapsc  ; various key name constants, gets vk code to avoid issues with another layout
   , bin→dec	:= numFunc.bin→dec.Bind(numFunc), dec→bin := numFunc.dec→bin.Bind(numFunc), nbase := numFunc.nbase.Bind(numFunc)
   , get⎀   	:= win.get⎀.Bind(win), get⎀GUI	:= win.get⎀GUI.Bind(win), get⎀Acc := win.get⎀Acc.Bind(win)
   , s      	:= helperString
   , breaks 	:= '' ; break ↑ with these keys
   , 🖥️w←,🖥️w↑,🖥️w→,🖥️w↓,🖥️w↔,🖥️w↕
   , _       	:= win.getMonWork(&🖥️w←,&🖥️w↑,&🖥️w→,&🖥️w↓,&🖥️w↔,&🖥️w↕) ; Get Monitor working area ;;; static, ignores monitor changes
   , ⌂tHold  	:= ucfg⌂mod.Get('holdTimer',0.5) ;
   , ⌂ΔH     	:= ⌂tHold * 1000
   , tooltip⎀	:= ucfg⌂mod.Get('tooltip⎀',1) ;
   , ttdbg   	:= ucfg⌂mod.Get('ttdbg',0) ;
   , d3      	:= 3 ; custom dbg level for testing selected commands
   , d4      	:= 4 ;
   , d5      	:= 5 ;
   , isInit  	:= false ;
   , dbg⌂ih  	:= ''
      ; I1 sendlevel (ignore regular keys sent at level 0)
      ; L1024 def don't need many since after a short hold timer a permanent mode will set, the hoook will reset
   , map⌂hook	:= Map()
   , stack⌂  	:= [] ; track the level of a modtap key's inputhook in the stack (also used to set minsendlevel to allow sending keys to only the most recent hook)
  ; dbgtt(0,hk ' ' c ' ' is↓,t:='∞',i:=7,0,0) ;


   cb⌂a_Key↑:=0,cb⌂s_Key↑:=0,cb⌂d_Key↑:=0,cb⌂f_Key↑:=0,cb⌂j_Key↑:=0,cb⌂k_Key↑:=0,cb⌂l_Key↑:=0,cb⌂︔_Key↑:=0
  ,cb⌂a_Key↓:=0,cb⌂s_Key↓:=0,cb⌂d_Key↓:=0,cb⌂f_Key↓:=0,cb⌂j_Key↓:=0,cb⌂k_Key↓:=0,cb⌂l_Key↓:=0,cb⌂︔_Key↓:=0
  if not isInit {
    for i⌂ in [⌂a,⌂s,⌂d,⌂f,⌂j,⌂k,⌂l,⌂︔] { ; create inputhook objects for later use
      ih⌂	:= InputHook("T" ⌂tHold) ; I2 set minsendlevel individually depending on the stack order of modtap
      ih⌂.KeyOpt('{All}','N')  ; N: Notify. OnKeyDown/OnKeyUp callbacks to be called each time the key is pressed
      cb⌂%i⌂.token%_Key↑	:= cb⌂_Key↑.Bind(i⌂) ; ih,vk,sc will be added automatically by OnKeyUp
      cb⌂%i⌂.token%_Key↓	:= cb⌂_Key↓.Bind(i⌂) ; ...                                     OnKeyDown
      ih⌂.OnKeyUp       	:= cb⌂%i⌂.token%_Key↑	;
      ih⌂.OnKeyDown     	:= cb⌂%i⌂.token%_Key↓	; ;;;or cbkeys? and '{Left}{Up}{Right}{Down}' separately???
      map⌂hook[i⌂.vk]   	:= ih⌂
    }
    isInit	:= true
  }

  global ⌂a,⌂s,⌂d,⌂f,⌂j,⌂k,⌂l,⌂︔

  vkC := s.key→ahk(c)
  this⌂ := map⌂['vk→⌂'].Get(vkC, '')
  if not this⌂ { ;
    throw ValueError("Unknow modtap key!", -1, c ' ' vkC)
  }
  ih⌂ 	:= map⌂hook[vkC]
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
    ; dbgtt(d4,isOpp ' isOpp`n' isThis‹ ' ' isAny› '`n' isThis› ' ' isAny‹,3)
  static tmpid := 2
  if tmpid > 5 {
    tmpid := 2
  }
  dbgtt(d3, c ' ' vkC ' is' (is↓ ? '↓' : '↑') this⌂.pos (this⌂.is ? '🠿' : '') ' isOpp' isOpp ' stack' stack⌂.Length ' ' preciseTΔ() '`n@setup⌂',t:='∞',tmpid
   ,🖥️w↔*(1  - dbgorder.Get(c,0)[1]*.24)
   ,🖥️w↕*(.5 + dbgorder.Get(c,0)[2]*.05 + is↓ * .06) ) ;
  tmpid += 1 ;

  is↑ := not is↓ ;

  handle⌂↑(&this⌂,&ih,&ihID,this⌂t) { ; allows calling called either when a single ⌂ or combined
    _tprio := A_PriorKey
    ih_input := ''
    if ih⌂.InProgress { ;
      ih_input	:= ih⌂.Input
      dbgtt(d5,'×IH handle⌂↑, input=' ih_input ' stack' stack⌂.Length ' 🕐' preciseTΔ(),t:=4,7) ; I
      ih⌂.Stop() ; stack cleaned up when handling ih.reason so that it's possible to stop at Key↓↑ functions
    }
    ; dbgtt(0,'✗post stop stack' stack⌂.Length ' 🕐' preciseTΔ(),'∞',8,0,0) ; II (stop III)
    if this⌂.is { ; 🠿1ba)
      SendInput(this⌂.send↑)
      if tooltip⎀ { ;
        win.get⎀(&⎀←,&⎀↑,&⎀↔:=0,&⎀↕:=0), dbgtt(0,'',t:='∞',i↗,⎀←-9,⎀↑-30)
      }
      this⌂.pos := '↑', this⌂.t := A_TickCount, this⌂.is := false, dbgTT(tooltip⎀?0:1,ttdbg?'`n':'',t:='∞',i↗,🖥️w↔ - 40, 20)
      dbgtt(d3,'🠿1ba) this⌂↑ after sequenced this⌂🠿(' this⌂t (this⌂t<⌂ΔH?'<':'>') ⌂ΔH ') ' preciseTΔ() ' input=‘' ih_input '’',t:=2,,x:=🖥️w↔,y:=850)
      dbgtt_ismod('🠿1ba')
    } else {
      if (prio := s.key→ahk(A_PriorKey)) = vkC {
        if this⌂.pos = '↓' { ; ↕xz) ↕01)
          this⌂.pos := '↑', this⌂.t := A_TickCount, this⌂.is := false, dbgTT(tooltip⎀?0:5,ttdbg?'`n':'',t:='∞',i↗,🖥️w↔ - 40, 20)
          if stack⌂.Length > 1 { ; another modtap key is active, send this modtap as a regular key to the top active callback
            alt⌂ := stack⌂[-2], alt⌂ih := map⌂hook[alt⌂.vk]
            vk_d := GetKeyVK(vkC), sc_d := GetKeySC(vkC) ; decimal value
            Key↑_⌂(alt⌂ih, vk_d, sc_d, &alt⌂, '↕xz') ; invoke callback directly, but use another modtap's inputhook (ours is already disabled)
            dbgtt(d3,'✗ _↕01) ⌂↓ <ΔH •⌂↑`n' dbg⌂ '↑ alone while ' alt⌂.dbg '↓`n🕐' this⌂t '<' ⌂ΔH ' PreKey ‘' A_PriorKey '’ prio=‘' prio '’ 🕐' preciseTΔ() ' input=‘' ih_input '’ this⌂.is=' this⌂.is ' this⌂.pos=' this⌂.pos,t:=2,,0,🖥️w↕*.86) ;
          } else { ;
            SendInput('{blind}' '{' . vkC . ' down}{' . vkC . ' up}') ; (~ does this) type the char right away to avoid delays (to be deleted later on match), use {blind} to retain ⇧◆⎇⎈ positions)
            dbgtt(d3,'↕xz) ↕01) ⌂↓ <ΔH •⌂↑`n' dbg⌂ '↑ alone`n🕐' this⌂t '<' ⌂ΔH ' PreKey ‘' A_PriorKey '’ prio=‘' prio '’ 🕐' preciseTΔ() ' input=‘' ih_input '’ this⌂.is=' this⌂.is ' this⌂.pos=' this⌂.pos,t:=2,,0,🖥️w↕*.86)
          } ;
        } else { ; 00) haven't been activated, no need to send self
          this⌂.pos := '↑', this⌂.t := A_TickCount, this⌂.is := false, dbgTT(tooltip⎀?0:5,ttdbg?'`n':'',t:='∞',i↗,🖥️w↔ - 40, 20)
          dbgtt(d3,'✗ 00) this⌂↑ alone this⌂↓(' this⌂t ' < ' ⌂ΔH ') PreKey ‘' A_PriorKey '’ prio=‘' prio '’ 🕐' preciseTΔ() ' input=‘' ih_input '’ this⌂.is=' this⌂.is ' this⌂.pos=' this⌂.pos,t:=2,,x:=🖥️w↔,y:=850)
          dbgtt_ismod('00)')
        }
      } else { ; ↕2a) ⌂↓ a↓ •⌂↑ a↑   fast typing ⌂,a
        this⌂.pos := '↑', this⌂.t := A_TickCount, this⌂.is := false, dbgTT(tooltip⎀?0:5,ttdbg?'`n':'',t:='∞',i↗,🖥️w↔ - 40, 20)
        keynm := vkrl['en'].Get(prio,'✗')
        dbgtt(d3,'↕2a) ⌂↓ a↓ •⌂↑ a↑ (typing)`n' keynm ' (' A_PriorKey ') A_PriorKey, print self ‘' c '’‘' ih_input '’=input',t:=4,,x:=0)  ;
        dbgtt_ismod('↕2a)')
        SendLevel 1 ; main ⌂'s hook is monitoring at level 1, let it catch our sends to properly test whether ⌂ should be activated
        SendInput('{blind}' '{' . vkC . ' down}{' . vkC . ' up}') ; (~ does this) type the char right away to avoid delays (to be deleted later on match), use {blind} to retain ⇧◆⎇⎈ positions)
        SendInput(ih_input) ;
        SendLevel 0 ;
      }
    }
  }

  if is↑ { ;
    this⌂t := A_TickCount - this⌂.t
    handle⌂↑(&this⌂,&ih,&ihID,this⌂t) ;
    dbgtt_ismod('↑')
  } else { ; is↓
    ; dbgtt(d4,'is↓' is↓ ' ' preciseTΔ(),t:=3,i:=13,x:=🖥️w↔,y:=300) ;
    this⌂.pos := '↓', this⌂.t := A_TickCount
    dbgtt_ismod('↓')
    stack⌂.Push(this⌂)
    ih⌂.MinSendLevel	:= stack⌂.Length + 1
    ih⌂.Start()     	       	; 0a) •⌂↓ do nothing yet, just activate inputhook
    dbg⌂ih          	:= dbg⌂	;
    dbgtt(d5,dbg⌂ '¦' dbg⌂ih '`nIH with callback cb⌂' this⌂.k '_Key↓ ↑ stack' stack⌂.Length ' ' preciseTΔ(),t:=2,i1↓,🖥️w↔//2,🖥️w↕*.89) ;
    ih⌂.Wait()		; Waits until the Input is terminated (InProgress is false)

    if (ih⌂.EndReason  = "Timeout") { ;0t) Timed out after ⌂tHold
      SendInput(this⌂.send↓), this⌂.is := true ;, dbgtt(d4,this⌂.🔣,t:='∞',i↗,🖥️w↔ - 40, 20)
      if tooltip⎀ { ;
        win.get⎀(&⎀←,&⎀↑,&⎀↔:=0,&⎀↕:=0), dbgtt(0,this⌂.🔣,t:='∞',i↗,⎀←-9,⎀↑-30)
      }
      dbgtt_ismod('0t')
      _ := stack⌂.Pop() ;
      dbgtt(d5,dbg⌂ ' ¦ ' dbg⌂ih '`n×IH ‘' ih⌂.EndReason '’ Input=' ih⌂.Input '  stack' stack⌂.Length ' ',t:=4,i0↓,🖥️w↔//2,🖥️w↕)
    } else if (ih⌂.EndReason = "Stopped") {
      dbg⌂ih:='', ihID := {⌂:'',dbg:''}, _ := stack⌂.Pop() ; cleanup after handle⌂↑ or early ⌂🠿 in Key↑⌂
      dbgtt(d5,dbg⌂ ' ¦ ' dbg⌂ih '`n×IH ‘' ih⌂.EndReason '’ Input=' ih⌂.Input '  stack' stack⌂.Length ' 🕐' preciseTΔ(),t:=4,i0↓,🖥️w↔//2,🖥️w↕)
    ; } else if (ih⌂.EndReason = "Match") { ; Input matches one of the items in MatchList
    ; } else if (ih⌂.EndReason = "Max") { ; Input reached max length and it does not match any of the items in MatchList
    ; } else if (ih⌂.EndReason = "EndKey") { ; One of the EndKeys was pressed to terminate the Input
    } else { ;
      _ := stack⌂.Pop() ;???
      dbgtt(d5,dbg⌂ ' ¦ ' dbg⌂ih '`n×IH else, Input=' ih⌂.Input '  stack' stack⌂.Length ' ',t:=4,i0↓,🖥️w↔//2,🖥️w↕)
      ; return ih⌂.Input ; Returns any text collected since the last time Input was started
    }
  }
}
