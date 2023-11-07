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
>ΔH•        🠿0c) print ⇧A (⇧⌂ enabled on timer 🠿0t), A is printed outside of the scripts purview)
      •     ↕2a)  print ⌂,a
         •  ↕2b)  print nothing, 2a handle it
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
*/

; —————————— User configuration ——————————
global ucfg⌂mod := Map(
   'tooltip⎀' 	, true 	;|true| 	show a tooltip with activated modtaps near text caret (position isn't updated as the caret moves)
 , 'holdTimer'	, 0.5  	;|.5|   	seconds of holding a modtap key after which it becomes a hold modifier
 ; Debugging  	       	        	;
 , 'ttdbg'    	, false	;|false|	show an empty (but visible) tooltip when modtap is deactivated
  )
i↗ := 19 ; ttdbg index, top right position of the empty status of our home row mod

;;; ONLY ⌂f ⌂j is working ;;;

; ‹
⌂a := {k:'a',mod:'LControl'}
⌂s := {k:'s',mod:'LWin'    }
⌂d := {k:'d',mod:'LAlt'    }
⌂f := {k:'f',mod:'LShift'  }
; ›
⌂j := {k:'j',mod:'RShift'   }
⌂k := {k:'k',mod:'RAlt'     }
⌂︔ := {k:';',mod:'RControl'}
⌂l := {k:'l',mod:'RWin'     }
; setup info and status fields for all the homerow mods
⌂map := Map()
for _modtapp in [⌂a,⌂s,⌂d,⌂f,⌂j,⌂k,⌂l,⌂︔] {
  _modtapp.t       	:= A_TickCount
  _modtapp.vk      	:= helperString.key→ahk(_modtapp.k) ; vk21 for f
  _modtapp.pos     	:= '↑'
  _modtapp.is      	:= false
  _modtapp.send↓   	:= '{' _modtapp.mod ' Down' '}'
  _modtapp.send↑   	:= '{' _modtapp.mod ' Up'   '}'
  _modtapp.🔣       	:= helperString.modi_ahk→sym(    _modtapp.mod) ; ‹⇧
  _modtapp.🔣ahk    	:= helperString.modi_ahk→sym_ahk(_modtapp.mod) ; <+
  _modtapp.flag    	:= f%_modtapp.🔣%
  ⌂map[_modtapp.vk]	:= _modtapp
}

get⌂Status() {
  static bin→dec	:= numFunc.bin→dec.Bind(numFunc), dec→bin := numFunc.dec→bin.Bind(numFunc), nbase := numFunc.nbase.Bind(numFunc)
  bitflags := 0
  for modtap in [⌂a,⌂s,⌂d,⌂f,⌂j,⌂k,⌂l,⌂︔] {
    bitflags |= GetKeyState(modtap.vk,"P") ? modtap.flag : 0 ; modtap.is ? modtap.flag : 0
  } ; dbgtt(0,'bitflags ' dec→bin(bitflags) ' ‹' isAny‹ ' ›' isAny›,t:=5)
  return {isAny‹:bitflags & bit‹, isAny›:bitflags & bit›, bit:bitflags}
}
; #HotIf

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
  global  reg⌂map
  loop parse 'fj' {
    pre_ahk := ⌂%A_LoopField%.🔣ahk ; <+ for f and >+ for j
    hk_reg := reg⌂map[A_LoopField]
    , hkreg1	:= pre_ahk hk_reg.down ; >+ ＄ vk       for j
    , hkreg2	:= pre_ahk hk_reg.up   ; >+ ＄ vk ' UP'
    HotIf cb⌂%A_LoopField%_hotif
    HotKey(hkreg1, hkDoNothing) ; do nothing while home row mod is active _1)
    HotKey(hkreg2, hkModTap_up) ; reset home row mod _2)
    HotIf
    reg⌂map[hkreg1]     	:= {lbl:A_LoopField, is↓:1}
    reg⌂map[hkreg2]     	:= {lbl:A_LoopField, is↓:0}
    reg⌂map[A_LoopField]	:= {down:hkreg1, up:hkreg2}
  }
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

cb⌂_Key↓(ih, vk, sc) {
  static k	:= keyConstant._map, kr	:= keyConstant._mapr ; various key name constants, gets vk code to avoid issues with another layout
    , s   	:= helperString
  if ⌂f.pos = '↓' { ; ?0b) should always be true? otherwise we won't get a callback
    prionm := kr['en'].Get([s.key→ahk(A_PriorKey)],'✗')
    keynm := kr[ 'en'].Get([Format("vk{:x}",vk)],'✗')
    t⌂f := A_TickCount - ⌂f.t
    dbgtt(2,'✗ ?0b) ⌂f↓(' t⌂f ') Key↓ ' keynm ' prio ‘' prionm '’ vk' hex(vk) ' sc' hex(sc),t:=5 ,,x:=1100,y:=950) ; vk57 sc11
  } else { ; should never get here?;
    dbgMsg(0,'⌂f↑ Key↓ vk' hex(vk) ' sc' hex(sc))
  }
}
cb⌂_Key↑(ih, vk, sc) { ;
  static k	:= keyConstant._map, lbl := keyConstant._labels, kr	:= keyConstant._mapr ; various key name constants, gets vk code to avoid issues with another layout
   , s    	:= helperString
  if ⌂f.pos = '↓' { ; 1a)
    global ⌂f
    if ⌂f.vk = s.key→ahk(A_PriorKey) { ; xx)
      dbgtt(3,'xx  ⌂f↓ Key↑ ⇧vk' hex(vk) ' sc' hex(sc) ' PreK=' A_PriorKey '=' ⌂f.nm ' ' preciseTΔ(),t:=4,i:=12,x:=50) ;
    } else { ; 🠿1aa)
      dbgtt(2,'🠿1aa) ⌂f↓ Key↑ ⇧vk' hex(vk) ' sc' hex(sc) ' PreK=' A_PriorKey '≠' ⌂f.nm ' ' preciseTΔ(),t:=4,i:=12,x:=50,y:=200) ;
      SendInput("{LShift Down}"), ⌂f.mod := true ;, dbgTT(0,'⇧',t:='∞',i↗,A_ScreenWidth - 40, 20)
      win.get⎀(&⎀←,&⎀↑,&⎀↔:=0,&⎀↕:=0) ;;; comment
      dbgTT(0,'⇧',t:='∞',i↗,⎀←-9,⎀↑-30) ;;; comment out
      SendInput('{' Format("vk{:x}sc{:x}",vk,sc) '}') ;
    }
  } else { ; 2b) ??? unreachable since ⌂f↑ cancels input hook?
    dbgMsg(0,'2b) ⌂f↑ Key↑ vk' hex(vk) ' sc' hex(sc) ' do nothing') ;
  }
}
set_modtap_labels() { ; set key labels to monitor for home row mods
  static k	:= keyConstant._map, kr := keyConstant._mapr, lbl := keyConstant._labels ; various key name constants, gets vk code to avoid issues with another layout
   , get⎀ 	:= win.get⎀.Bind(win), get⎀GUI	:= win.get⎀GUI.Bind(win), get⎀Acc := win.get⎀Acc.Bind(win)
   , s    	:= helperString
   , labels := Map()
   , cbkeys := '' ; inputhook key lists that use callbacks
  if labels.Count   	= 0 { ; can set case only on empty maps
    labels.CaseSense	:= 0
    labels['en'] := "
    ( Join ` LTrim
     `1234567890-=
      qwertyuiop[]
      asdfghjkl;'\
      zxcvbnm,./
     )"
    labels['en_no⌂'] := "
    ( Join ` LTrim
     `1234567890-=
      qwertyuiop[]
          gh    '\
      zxcvbnm,./
     )"
    labels['en_no‹⌂'] := "
    ( Join ` LTrim
     `1234567890-=
      qwertyuiop[]
          ghjkl;'\
      zxcvbnm,./
     )"
    labels['‹en'] := "
    ( Join ` LTrim
     `12345
      qwert
      asdfg
      zxcvb
     )"
    labels['en›'] := "
    ( Join ` LTrim
           67890-=
           yuiop[]
           hjkl;'\
           nm,./
     )"
  }

  if cbkeys = '' {
    ; loop parse labels['en›'] { ; track half of the layout (right half for left home row mods) to avoid issues
    loop parse labels['en_no‹⌂'] { ; track layout except for same side home row
      cbkeys .= '{' s.key→ahk(A_LoopField) '}'
    }
    ; loop parse labels['‹en'] { ; break on the other half
    ;   breaks .= '{' s.key→ahk(A_LoopField) '}'
    ; } ;;; todo: useless? since anyway it has to be processed, so just not adding callbacks from ↑ is enough?
  }

  return {labels:labels, cbkeys:cbkeys}
}

modtap(hk,c,is↓) { ;
  static k 	:= keyConstant._map, kr := keyConstant._mapr, lbl := keyConstant._labels ; various key name constants, gets vk code to avoid issues with another layout
   , get⎀  	:= win.get⎀.Bind(win), get⎀GUI	:= win.get⎀GUI.Bind(win), get⎀Acc := win.get⎀Acc.Bind(win)
   , s     	:= helperString
   , ih    	:= '' ; inputhook
   , breaks	:= '' ; inputhook keys that break the inputhook
   , _lbl := set_modtap_labels() ;
   , labels := _lbl.labels
   , cbkeys := _lbl.cbkeys ; inputhook key lists that use callbacks
   , 🖥️w←,🖥️w↑,🖥️w→,🖥️w↓,🖥️w↔,🖥️w↕
   , _ := win.getMonWork(&🖥️w←,&🖥️w↑,&🖥️w→,&🖥️w↓,&🖥️w↔,&🖥️w↕) ; Get Monitor working area ;;; static, ignores monitor changes

  vkC := s.key→ahk(c)
  ; dbgtt(0,'c=' c ' vkC=' vkC ' is↓' is↓,t:=2) ;

  static ih := ''
  global ⌂f
  is↑ := not is↓
  if is↑ {
    _tprio := A_PriorKey
    ih_input := ''
    if type(ih) = 'InputHook' { ;
      ih_input := ih.Input
      dbgtt(4,'InputHook stopped InProgress=' ih.InProgress ' input=' ih.Input,t:=2) ;
      ih.Stop()	;
    }
    t⌂f := A_TickCount - ⌂f.t
    if ⌂f.mod { ; 🠿1ba)
      SendInput("{LShift Up}"), dbgTT(4,'⇧↑',t:='∞',i:=18,🖥️w↔,🖥️w↕)
      ⌂f.pos := '↑', ⌂f.t := A_TickCount, ⌂f.mod := false, dbgTT(0,'`n',t:='∞',i↗,🖥️w↔ - 40, 20)
      dbgtt(3,'🠿1ba) ⌂f↑ after sequenced ⌂f🠿(' t⌂f (t⌂f<⌂ΔH?'<':'>') ⌂ΔH ') ' preciseTΔ() ' input=‘' ih_input '’',t:=2,,x:=🖥️w↔,y:=850)
    } else {
      if (prio := s.key→ahk(A_PriorKey)) = vkC {
        if ⌂f.pos = '↓' { ; ↕01)
          ⌂f.pos := '↑', ⌂f.t := A_TickCount, ⌂f.mod := false, dbgTT(0,'`n',t:='∞',i↗,🖥️w↔ - 40, 20)
          dbgtt(1,'01) ⌂f↑ alone ⌂f↓(' t⌂f ' < ' ⌂ΔH ') PreKey ‘' A_PriorKey '’ prio=‘' prio '’ 🕐' preciseTΔ() ' input=‘' ih_input '’ ⌂f.mod=' ⌂f.mod ' ⌂f.pos=' ⌂f.pos,t:=2,,x:=0,y:=850)
          SendInput('{blind}' '{' . vkC . ' down}{' . vkC . ' up}') ; (~ does this) type the char right away to avoid delays (to be deleted later on match), use {blind} to retain ⇧◆⎇⎈ positions)
        } else { ; 00) haven't been activated, no need to send self
          ⌂f.pos := '↑', ⌂f.t := A_TickCount, ⌂f.mod := false, dbgTT(0,'`n',t:='∞',i↗,🖥️w↔ - 40, 20)
          dbgtt(3,'00) ⌂f↑ alone ⌂f↓(' t⌂f ' < ' ⌂ΔH ') PreKey ‘' A_PriorKey '’ prio=‘' prio '’ 🕐' preciseTΔ() ' input=‘' ih_input '’ ⌂f.mod=' ⌂f.mod ' ⌂f.pos=' ⌂f.pos,t:=2,,x:=🖥️w↔,y:=850)
        }
      } else { ; ↕2a)
        ⌂f.pos := '↑', ⌂f.t := A_TickCount, ⌂f.mod := false, dbgTT(0,'`n',t:='∞',i↗,🖥️w↔ - 40, 20)
        keynm := kr['en'].Get(prio,'✗') ;
        dbgtt(1,'↕2a) ' keynm ' (' A_PriorKey ') A_PriorKey, print prio ' prio ' input=‘' ih_input '’',t:=2,,x:=0)  ;
        ; SendEvent('{' . prio . ' down}{' . prio . ' up}') ; (~ does this) type the char right away to avoid delays (to be deleted later on match), use {blind} to retain ⇧◆⎇⎈ positions)
        SendInput('{blind}' '{' . vkC . ' down}{' . vkC . ' up}') ; (~ does this) type the char right away to avoid delays (to be deleted later on match), use {blind} to retain ⇧◆⎇⎈ positions)
        SendInput(ih_input) ;
      }
    }
  } else if type(ih) = 'InputHook'
    and ih.InProgress = 1 { ; active ih from some other key, skip?
    ; ⌂f := {pos:'↓', t:A_TickCount, mod:false}
    ; dbgTT(0,'⇧↓ ih' ih.InProgress,t:='∞',i:=18,🖥️w↔,🖥️w↕) ;
    ⌂f.pos := '↓', ⌂f.t := A_TickCount, dbgTT(3,'⇧↓ ih' ih.InProgress,t:='∞',i:=18,🖥️w↔,🖥️w↕) ;
  } else { ; is↓
    ; dbgtt(4,'is↓' is↓ ' ' preciseTΔ(),t:=3,i:=13,x:=🖥️w↔,y:=300) ;
    ⌂f.pos := '↓', ⌂f.t := A_TickCount, dbgTT(2,'⇧↓',t:='∞',i:=18,🖥️w↔,🖥️w↕) ;
    ; dbgtt(4,'is↓' is↓ ' ' preciseTΔ(),t:=3,i:=14,x:=🖥️w↔,y:=400) ;
    ; SendEvent('{blind}' '{' . vkC . ' down}{' . vkC . ' up}') ; (~ does this) type the char right away to avoid delays (to be deleted later on match), use {blind} to retain ⇧◆⎇⎈ positions)
    ih := InputHook("L1000 I1 T" ⌂tHold) ;;; I1 sendlevel (allows sending keys at level 0), L0 disables collection of text and the length limit, but does not affect which keys are counted as producing text (see VisibleText), can be useful in combination with OnChar, OnKeyDown, KeyOpt or the EndKeys parameter
    ; ih.KeyOpt("{LWin}{RWin}{LAlt}{RAlt}{LCtrl}{RCtrl}{Esc}", "ES")  ; EndKeys (terminate the input) and Suppress (blocks) the key after processing
    ; ih.KeyOpt("{Left}{Up}{Right}{Down}{BackSpace}", "E")  ; EndKeys (terminate the input)
    ; ih.KeyOpt(breaks, "E")  ; EndKeys (terminate the input)
    ;;; todo ↑ remove terminators?
    ; ih.KeyOpt("{vk57}{vk44}{vk32}", "N")  ;w N: Notify. OnKeyDown/OnKeyUp callbacks to be called each time the key is pressed
    ih.KeyOpt(cbkeys, "N")  ;w N: Notify. OnKeyDown/OnKeyUp callbacks to be called each time the key is pressed
    ;;;; ih.KeyOpt('{All}', "N")  ;w N: Notify. OnKeyDown/OnKeyUp callbacks to be called each time the key is pressed
    ih.KeyOpt('{Left}{Up}{Right}{Down}', "N")  ;wforfoOrfforOofroforforfor N: Notify. OnKeyDown/OnKeyUp callbacks to be called each time the key is pressed
    ;;;;; NS bugs and shift gets stuck sometimes
    ; ih.KeyOpt("{vk57}", "S")  ;w doesn't work for self, S also doesn't help
    ih.OnKeyUp := cb⌂_Key↑
    ih.OnKeyDown := cb⌂_Key↓
    ih.Start()	; Starts collecting input
    ih.Wait() 	; Waits until the Input is terminated (InProgress is false)
    if (ih.EndReason  = "Timeout") { ;0t) Timed out after ⌂tHold
      SendInput("{LShift Down}"), ⌂f.mod := true ;, dbgTT(0,'⇧',t:='∞',i↗,🖥️w↔ - 40, 20)
      win.get⎀(&⎀←,&⎀↑,&⎀↔:=0,&⎀↕:=0) ;;; comment out
      dbgTT(0,'⇧',t:='∞',i↗,⎀←-9,⎀↑-30) ;;; comment out
      dbgtt(4,'Timeout, Input=' ih.Input ' ih.InProgress=' ih.InProgress,t:=2,,🖥️w↔,650) ;
    } else if (ih.EndReason != "Max") { ; Timed out/Stopped without reaching typed char limit
      dbgtt(4,'Nonmax ' ih.EndReason ', Input=' ih.Input ' ih.InProgress=' ih.InProgress,t:=2) ;
      ; return False ;
    } else {
      dbgtt(4,'else, Input=' ih.Input ' ih.InProgress=' ih.InProgress,t:=2) ;
      ; return ih.Input ; Returns any text collected since the last time Input was started
    }
  }
}
