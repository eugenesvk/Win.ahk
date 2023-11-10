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
         •  🠿1ba) print nothing, 1a handles key, ⌂ is a mod
   >ΔH•     🠿1ab) print nothing, 0c handled key↓ (⇧⌂ enabled on timer 🠿0t)
         •  🠿1bb) print nothing, 1a handles key, ⌂ is a mod

if ⌂🠿
  a↓...      __)  not tracked, regular typing with modtap enabled
  ⌂↓   ⌂↑
  •          _1)  do nothing, block repeat of the
       •     _2)  reset
if alt⌂↓          another modtap key is active (but not switched to a hold yet, so inputhook is in progress)
⌂↓       ⌂↑ ↕     single standalone tap, not hold
     <ΔH •  _↕01)  print ⌂
    •>ΔH    _🠿0t)  enable ⌂ (⇧⌂ enabled on timer via input hook's timeout of the alt⌂)
*/

; —————————— User configuration ——————————
global ucfg⌂mod := Map(
   'tooltip⎀' 	, true 	;|true| 	show a tooltip with activated modtaps near text caret (position isn't updated as the caret moves)
 , 'holdTimer'	, 0.5  	;|.5|   	seconds of holding a modtap key after which it becomes a hold modifier
 ; Debugging  	       	        	;
 , 'ttdbg'    	, false	;|false|	show an empty (but visible) tooltip when modtap is deactivated
  )
i↗ := 19 ; ttdbg index, top right position of the empty status of our home row mod

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
  ; dbgtt(0,ThisHotkey ' lvl' A_SendLevel ' ThisHotkey@hkModTap',t:=2,,🖥️w↔,🖥️w↕*0.3)
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
  global  reg⌂map
  loop parse 'fj' {
    pre_ahk := ⌂%A_LoopField%.🔣ahk ; <+ for f and >+ for j
    hk_reg := reg⌂map[A_LoopField]
    , hkreg1  	:= pre_ahk hk_reg.down ; >+ ＄ vk       for j
    , hkreg2  	:= pre_ahk hk_reg.up   ; >+ ＄ vk ' UP'
    , token   	:= s.key→token(A_LoopField)
    , cbHotIf_	:= cbHotIf.Bind(token)
    HotIf cbHotIf_
    HotKey(hkreg1, hkDoNothing) ; do nothing while home row mod is active _1)
    HotKey(hkreg2, hkModTap_up) ; reset home row mod _2)
    HotIf
    reg⌂map[hkreg1]     	:= {lbl:A_LoopField, is↓:1}
    reg⌂map[hkreg2]     	:= {lbl:A_LoopField, is↓:0}
    reg⌂map[A_LoopField]	:= {down:hkreg1, up:hkreg2}
  }
}
cbHotIf(_token, HotkeyName) { ; callback for unregister⌂
  return ⌂%_token%.is ; token is ︔ for ; to be used in var names
}

hkModTap_up(ThisHotkey) {
  hk_reg := reg⌂map[ThisHotkey]
  ⌂_ := ⌂%hk_reg.lbl%
  dbgtt(3,ThisHotkey ' hk_reg' hk_reg.lbl ' @hkModTap_up',t:=5) ;
  static ⌂tHold := ucfg⌂mod.Get('holdTimer',0.5), ⌂ΔH := ⌂tHold * 1000, ttdbg := ucfg⌂mod.Get('ttdbg',0)
  , 🖥️w←,🖥️w↑,🖥️w→,🖥️w↓,🖥️w↔,🖥️w↕
  , _ := win.getMonWork(&🖥️w←,&🖥️w↑,&🖥️w→,&🖥️w↓,&🖥️w↔,&🖥️w↕) ; Get Monitor working area ;;; static, ignores monitor changes
  t⌂ := A_TickCount - ⌂f.t ;;; ←delete↓
  dbgtt(1,'🠿1bb) ⌂↑ after timed ⌂🠿(' t⌂ (t⌂<⌂ΔH?'<':'>') ⌂ΔH ') ' preciseTΔ(),t:=2,,x:=🖥️w↔,y:=900)
  SendInput(⌂_.send↑), ; 🠿1bb)
  ⌂_.pos := '↑', ⌂_.t := A_TickCount, ⌂_.is := false, dbgTT(0,ttdbg?'`n':'',t:='∞',i↗,🖥️w↔ - 40, 20)
}
hkDoNothing(ThisHotkey) {
  dbgtt(4,'hkDoNothing ' preciseTΔ())
  return
}

; callback for ↑
cb⌂a_Key↓(ih, vk, sc) {
  Key↓_⌂(ih, vk, sc, ⌂a)
}
cb⌂s_Key↓(ih, vk, sc) {
  Key↓_⌂(ih, vk, sc, ⌂s)
}
cb⌂d_Key↓(ih, vk, sc) {
  Key↓_⌂(ih, vk, sc, ⌂d)
}
cb⌂f_Key↓(ih, vk, sc) {
  dbgtt(4,'cb⌂f_Key↓',t:=1)
  Key↓_⌂(ih, vk, sc, ⌂f)
}
cb⌂j_Key↓(ih, vk, sc) {
  Key↓_⌂(ih, vk, sc, ⌂j)
}
cb⌂k_Key↓(ih, vk, sc) {
  Key↓_⌂(ih, vk, sc, ⌂k)
}
cb⌂l_Key↓(ih, vk, sc) {
  Key↓_⌂(ih, vk, sc, ⌂l)
}
cb⌂︔_Key↓(ih, vk, sc) {
  Key↓_⌂(ih, vk, sc, ⌂︔)
}
; callback for ↑
cb⌂a_Key↑(ih, vk, sc) {
  Key↑_⌂(ih, vk, sc, ⌂a)
}
cb⌂s_Key↑(ih, vk, sc) {
  Key↑_⌂(ih, vk, sc, ⌂s)
}
cb⌂d_Key↑(ih, vk, sc) {
  Key↑_⌂(ih, vk, sc, ⌂d)
}
cb⌂f_Key↑(ih, vk, sc) {
  dbgtt(4,'cb⌂f_Key↑',t:=1) ;
  Key↑_⌂(ih, vk, sc, ⌂f)
}
cb⌂j_Key↑(ih, vk, sc) {
  Key↑_⌂(ih, vk, sc, ⌂j)
}
cb⌂k_Key↑(ih, vk, sc) {
  Key↑_⌂(ih, vk, sc, ⌂k)
}
cb⌂l_Key↑(ih, vk, sc) {
  Key↑_⌂(ih, vk, sc, ⌂l)
}
cb⌂︔_Key↑(ih, vk, sc) {
  Key↑_⌂(ih, vk, sc, ⌂︔)
}

Key↓_⌂(ih, vk, sc, ⌂_) {
  static k	:= keyConstant._map, kr	:= keyConstant._mapr ; various key name constants, gets vk code to avoid issues with another layout
    , s   	:= helperString
    , 🖥️w←,🖥️w↑,🖥️w→,🖥️w↓,🖥️w↔,🖥️w↕
    , _ := win.getMonWork(&🖥️w←,&🖥️w↑,&🖥️w→,&🖥️w↓,&🖥️w↔,&🖥️w↕) ; Get Monitor working area ;;; static, ignores monitor changes
  dbg⌂ := ⌂_.k ' ' ⌂_.🔣 ;
  if ⌂_.pos = '↓' { ; ?0b) should always be true? otherwise we won't get a callback
    if dbg >= 2 {
      keynm 	:= kr['en'].Get('vk' hex(vk),'✗')
      prionm	:= kr['en'].Get(s.key→ahk(A_PriorKey),'✗')
      t⌂_   	:= A_TickCount - ⌂_.t
      dbgtt(2,'✗ ?0b) ' dbg⌂ '↓(' t⌂_ ') ' keynm '↓ prio ‘' prionm '’ vk' hex(vk) ' sc' hex(sc),t:=5,,🖥️w↔ - 40,🖥️w↕*.86) ; vk57 sc11
    }
  } else { ; should never get here?
    dbgMsg(0,dbg⌂ '↑ vk↓' hex(vk) ' sc' hex(sc) ' ' preciseTΔ()) ;
  }
}
Key↑_⌂(ih, vk, sc, ⌂_) { ;
  static k	:= keyConstant._map, lbl := keyConstant._labels, kr	:= keyConstant._mapr ; various key name constants, gets vk code to avoid issues with another layout
   , s    	:= helperString
    , 🖥️w←,🖥️w↑,🖥️w→,🖥️w↓,🖥️w↔,🖥️w↕
    , _ := win.getMonWork(&🖥️w←,&🖥️w↑,&🖥️w→,&🖥️w↓,&🖥️w↔,&🖥️w↕) ; Get Monitor working area ;;; static, ignores monitor changes
   , tooltip⎀ := ucfg⌂mod.Get('tooltip⎀',1), ttdbg := ucfg⌂mod.Get('ttdbg',0)
  global ⌂a,⌂s,⌂d,⌂f,⌂j,⌂k,⌂l,⌂︔
  dbg⌂ := ⌂_.k ' ' ⌂_.🔣 ;
  if ⌂_.pos = '↓' { ; 1a)
    if ⌂_.vk = s.key→ahk(A_PriorKey) { ; xx) a↓ ⌂↓ •a↑ ⌂↑
      dbgtt(2,'xx) a↓ ⌂↓ •a↑ ⌂↑`n' dbg⌂ '↓ vk↑' hex(vk) ' sc' hex(sc) ' PreK=' A_PriorKey '=' ⌂_.k ' ' preciseTΔ(),t:=4,i:=12,A_ScreenWidth - 40) ;
    } else { ; 🠿1aa) ⌂↓ a↓ <ΔH•a↑ ⌂↑
      if dbg >= 2 { ;
        keynm 	:= kr['en'].Get('vk' hex(vk),'✗')
        prionm	:= kr['en'].Get(s.key→ahk(A_PriorKey),'✗')
        t⌂_   	:= A_TickCount - ⌂_.t
        dbgtt(2,'🠿1aa) ⌂↓ a↓ <ΔH•a↑ ⌂↑ ' preciseTΔ() '`n' dbg⌂ '↓(' t⌂_ ') ' keynm '↑(vk' hex(vk) 'sc' hex(sc) ') prio ‘' prionm '’ ≠' ⌂_.k '`n' ⌂_.send↓ ' ' keynm,t:=4,i:=13,0,🖥️w↕//2) ;
      }
      SendInput(⌂_.send↓), ⌂_.is := true ;, dbgTT(0,⌂_.🔣,t:='∞',i↗,A_ScreenWidth - 40, 20)
      if tooltip⎀ {
        win.get⎀(&⎀←,&⎀↑,&⎀↔:=0,&⎀↕:=0), dbgTT(0,⌂_.🔣,t:='∞',i↗,⎀←-9,⎀↑-30)
      }
      SendInput('{' Format("vk{:x}sc{:x}",vk,sc) '}')
    }
  } else { ; 2b) ⌂↓ a↓ ⌂↑ •a↑ ??? unreachable since ⌂_↑ cancels input hook?
    dbgMsg(0,'2b) ⌂↓ a↓ ⌂↑ •a↑ ⌂↑`n' dbg⌂ '↓ vk↑' hex(vk) ' sc' hex(sc) ' PreK=' A_PriorKey '≠' ⌂_.k ' ' preciseTΔ() ' do nothing','Key↑_⌂')
  }
}

setup⌂mod(hk,c,is↓) { ;
  static k  	:= keyConstant._map, kr := keyConstant._mapr, lbl := keyConstant._labels ; various key name constants, gets vk code to avoid issues with another layout
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
   , d4      	:= 0 ;
   , isInit  	:= false ;
   , ih      	:= InputHook("I2 T" ⌂tHold) ; static so that there is only 1 active and multiple ⌂ don't conflict ;;; todo how to coop with f and j
   , ⌂ih     	:= {} ; modtap that triggered the unique inputhook
   , dbg⌂ih  	:= ''
      ; I1 sendlevel (ignore regular keys sent at level 0)
      ; L1024 def don't need many since after a short hold timer a permanent mode will set, the hoook will reset

  if not isInit {
    ih.KeyOpt('{All}','N')  ; N: Notify. OnKeyDown/OnKeyUp callbacks to be called each time the key is pressed
      ;;; or cbkeys? and '{Left}{Up}{Right}{Down}' separately???
    isInit	:= true
  }

  global ⌂a,⌂s,⌂d,⌂f,⌂j,⌂k,⌂l,⌂︔

  vkC := s.key→ahk(c)
  ⌂_ := ⌂map.Get(vkC, '')
  if not ⌂_ { ;
    throw ValueError("Unknow modtap key!", -1, c ' ' vkC)
  }
  dbgorder := Map('a',[1,4], 's',[1,3], 'd',[1,2], 'f',[1,1]
                 ,';',[0,4], 'l',[0,3], 'k',[0,2], 'j',[0,1])
  dbg⌂       	:= '⌂' ⌂_.k ' ' ⌂_.🔣 ;
  modtapflags	:= get⌂Status() ; {isAny‹,isAny›,bit}
  bit⌂       	:= modtapflags.bit
  isAny‹     	:= modtapflags.isAny‹
  isAny›     	:= modtapflags.isAny›
  isThis‹    	:= ⌂_.flag & bit‹
  isThis›    	:= ⌂_.flag & bit›
  isOpp      	:= (isThis‹ and isAny›)
    or     (isThis› and isAny‹)
    ; dbgtt(d4,isOpp ' isOpp`n' isThis‹ ' ' isAny› '`n' isThis› ' ' isAny‹,5)
  static tmpid := 2
  if tmpid > 5 {
    tmpid := 2
  }
  dbgtt(4, c ' ' vkC ' ' (is↓ ? '↓' : '↑') ' isOpp' isOpp ' ' preciseTΔ() '`n@setup⌂mod',t:=4,tmpid
   ,🖥️w↔*(1  - dbgorder.Get(c,0)[1]*.24)
   ,🖥️w↕*(.5 + dbgorder.Get(c,0)[2]*.05 + is↓ * .05) ) ;
  tmpid += 1 ;

  is↑ := not is↓ ;

  handle⌂↑(&⌂_,&ih,&⌂ih,&dbg⌂ih,&ihID,t⌂_) { ; allows calling called either when a single ⌂ or combined
    _tprio := A_PriorKey
    ih_input := ''
    if ih.InProgress { ;
      ih_input := ih.Input
      dbgtt(d4,'InputHook stopped input=' ih.Input,t:=2) ;
      ih.Stop(), ⌂ih:={}, dbg⌂ih:='', ihID := {⌂:'',dbg:''}	;
    }
    if ⌂_.is { ; 🠿1ba)
      SendInput(⌂_.send↑), dbgtt(d4,'⇧↑',t:='∞',i:=18,🖥️w↔,🖥️w↕)
      ⌂_.pos := '↑', ⌂_.t := A_TickCount, ⌂_.is := false, dbgTT(tooltip⎀?0:1,ttdbg?'`n':'',t:='∞',i↗,🖥️w↔ - 40, 20)
      dbgtt(d3,'🠿1ba) ⌂_↑ after sequenced ⌂_🠿(' t⌂_ (t⌂_<⌂ΔH?'<':'>') ⌂ΔH ') ' preciseTΔ() ' input=‘' ih_input '’',t:=2,,x:=🖥️w↔,y:=850)
    } else {
      if (prio := s.key→ahk(A_PriorKey)) = vkC {
        if ⌂_.pos = '↓' { ; ↕xz) ↕01)
          ⌂_.pos := '↑', ⌂_.t := A_TickCount, ⌂_.is := false, dbgTT(tooltip⎀?0:1,ttdbg?'`n':'',t:='∞',i↗,🖥️w↔ - 40, 20)
          dbgtt(d4,'↕xz) ↕01) ⌂_↑ alone ⌂_↓(' t⌂_ ' < ' ⌂ΔH ') PreKey ‘' A_PriorKey '’ prio=‘' prio '’ 🕐' preciseTΔ() ' input=‘' ih_input '’ ⌂_.is=' ⌂_.is ' ⌂_.pos=' ⌂_.pos,t:=2,,x:=0,y:=850)
          SendInput('{blind}' '{' . vkC . ' down}{' . vkC . ' up}') ; (~ does this) type the char right away to avoid delays (to be deleted later on match), use {blind} to retain ⇧◆⎇⎈ positions)
        } else { ; 00) haven't been activated, no need to send self
          ⌂_.pos := '↑', ⌂_.t := A_TickCount, ⌂_.is := false, dbgTT(tooltip⎀?0:1,ttdbg?'`n':'',t:='∞',i↗,🖥️w↔ - 40, 20)
          dbgtt(d3,'00) ⌂_↑ alone ⌂_↓(' t⌂_ ' < ' ⌂ΔH ') PreKey ‘' A_PriorKey '’ prio=‘' prio '’ 🕐' preciseTΔ() ' input=‘' ih_input '’ ⌂_.is=' ⌂_.is ' ⌂_.pos=' ⌂_.pos,t:=2,,x:=🖥️w↔,y:=850)
        }
      } else { ; ↕2a) ⌂↓ a↓ •⌂↑ a↑   fast typing ⌂,a
        ⌂_.pos := '↑', ⌂_.t := A_TickCount, ⌂_.is := false, dbgTT(tooltip⎀?0:1,ttdbg?'`n':'',t:='∞',i↗,🖥️w↔ - 40, 20)
        keynm := kr['en'].Get(prio,'✗') ;
        dbgtt(d3,'↕2a) ⌂↓ a↓ •⌂↑ a↑ (typing)`n' keynm ' (' A_PriorKey ') A_PriorKey, print self ‘' c '’‘' ih_input '’=input',t:=4,,x:=0)  ;
        SendLevel 1 ; main ⌂'s hook is monitoring at level 1, let it catch our sends to properly test whether ⌂ should be activated
        SendInput('{blind}' '{' . vkC . ' down}{' . vkC . ' up}') ; (~ does this) type the char right away to avoid delays (to be deleted later on match), use {blind} to retain ⇧◆⎇⎈ positions)
        SendInput(ih_input) ;
        SendLevel 0 ;
      }
    }
  }

  if ih.InProgress and isOpp { ; another ⌂ has an active inputhook, act as a regular key
    SendLevel 2 ; main ⌂'s hook is monitoring at level 1, let it catch our sends to properly test whether ⌂ should be activated
    vk_d := GetKeyVK(vkC) ; decimal value
    , sc_d := GetKeySC(vkC) ;
    if is↓ { ;is↓ get⌂Status
      if ⌂ih.flag & bit⌂ { ; the original ⌂ is also down
        dbgtt(1,dbg⌂ih ' hook active`n' dbg⌂ '↓ ' dbg⌂ih '↓ send ' vkC '(vk₁₀' vk_d 'sc₁₀' sc_d ')J lvl' A_SendLevel ' ihlvl' ih.MinSendLevel ' ' preciseTΔ(),t:=2,id:=16,🖥️w↔,🖥️w↕*.8)
        ; SendEvent('{' vkC ' Down}') ;;; ih catches Send↓, but for some reason the on↑↓ callbacks aren't called...
        Key↓_⌂(ih, vk_d, sc_d, ⌂ih) ;;; ...so try to invoke Key↓_⌂(ih, vk, sc, ⌂_) directly
      } else { ; the original ⌂ is up, so
        dbgtt(1,dbg⌂ih ' hook active`n' dbg⌂ '↓ ' dbg⌂ih '↑ send ' vkC '(vk₁₀' vk_d 'sc₁₀' sc_d ')J lvl' A_SendLevel ' ihlvl' ih.MinSendLevel ' ' preciseTΔ(),t:=2,id:=16,🖥️w↔,🖥️w↕*.8)
        Key↓_⌂(ih, vk_d, sc_d, ⌂ih) ;
      }
    } else { ;is↑
      if ⌂ih.flag & bit⌂ { ; the original ⌂ is also down
        dbgtt(d4,dbg⌂ih ' hook active`n' dbg⌂ '↑' dbg⌂ih '↑ send ' vkC '(vk₁₀' vk_d 'sc₁₀' sc_d ')J lvl' A_SendLevel ' ihlvl' ih.MinSendLevel ' ' preciseTΔ(),t:=2,id:=17,🖥️w↔,🖥️w↕*.86) ;
        ; SendEvent('{' vkC ' Up}') ;
        Key↑_⌂(ih, vk_d, sc_d, ⌂ih) ;
      } else { ; the original ⌂ is up, so
        t⌂_ := A_TickCount - ⌂_.t
        handle⌂↑(&⌂_,&ih,&⌂ih,&dbg⌂ih,&ihID,t⌂_) ;fjffjjjjjjj
        dbgtt(d4,ih.InProgress '✗' dbg⌂ih ' hook active`n' dbg⌂ '↑ ' dbg⌂ih '↑ send ' vkC '(vk₁₀' vk_d 'sc₁₀' sc_d ')J lvl' A_SendLevel ' ihlvl' ih.MinSendLevel ' ' preciseTΔ(),t:=4,id:=17,🖥️w↔,🖥️w↕*.86) ;
      }
    }
    SendLevel 0
  } else if is↑ { ;
    t⌂_ := A_TickCount - ⌂_.t
    handle⌂↑(&⌂_,&ih,&⌂ih,&dbg⌂ih,&ihID,t⌂_) ;
  } else { ; is↓
    ; dbgtt(d4,'is↓' is↓ ' ' preciseTΔ(),t:=3,i:=13,x:=🖥️w↔,y:=300) ;
    ⌂_.pos := '↓', ⌂_.t := A_TickCount
    , dbgtt(d4,'⇧↓',t:='∞',i:=18,🖥️w↔,🖥️w↕)
    ih.OnKeyUp  	:= cb⌂%⌂_.k%_Key↑	;
    ih.OnKeyDown	:= cb⌂%⌂_.k%_Key↓	;
    ih.Start()  	                 	; 0a) •⌂↓ do nothing yet, just activate inputhook
    ⌂ih         	:= ⌂_            	;
    dbg⌂ih      	:= dbg⌂          	;
    dbgtt(d4,dbg⌂ '¦' dbg⌂ih '`nIH with callback cb⌂' ⌂_.k '_Key↓ ↑ ' preciseTΔ(),t:=2,,🖥️w↔//2) ;
    ih.Wait()		; Waits until the Input is terminated (InProgress is false)

    if (ih.EndReason  = "Timeout") { ;0t) Timed out after ⌂tHold
      SendInput(⌂_.send↓), ⌂_.is := true ;, dbgtt(d4,⌂_.🔣,t:='∞',i↗,🖥️w↔ - 40, 20)
      if tooltip⎀ {
        win.get⎀(&⎀←,&⎀↑,&⎀↔:=0,&⎀↕:=0)
        dbgtt(d4,⌂_.🔣,t:='∞',i↗,⎀←-9,⎀↑-30)
      } ;
      dbgtt(d4,dbg⌂ ' ¦ ' dbg⌂ih '`n×IH Timeout, Input=' ih.Input ' ih.InProgress=' ih.InProgress,t:=4,,🖥️w↔//2,)
    } else if (ih.EndReason != "Max") { ; Timed out/Stopped without reaching typed char limit
      dbgtt(d4,dbg⌂ ' ¦ ' dbg⌂ih '`n×IH Nonmax ' ih.EndReason ', Input=' ih.Input ' ih.InProgress=' ih.InProgress,t:=4,,🖥️w↔//2) ;
    } else { ;
      dbgtt(d4,dbg⌂ ' ¦ ' dbg⌂ih '`n×IH else, Input=' ih.Input ' ih.InProgress=' ih.InProgress,t:=4,,🖥️w↔//2,) ;
      ; return ih.Input ; Returns any text collected since the last time Input was started
    }
  }
}
