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
  •<ΔH perform action at this point only if ⌂tHold seconds has NOT passed
  ⌂ home row modtap key (e.g., f⃣ types ‘f’ with a single tap, but becomes ⇧ on hold)
  a any regular key (not modtap)
⌂↓ always activates our modtap input handler, so won't be marked as •
Key sequences and how to treat them:
Sequence    Label Comment
a↓ ⌂↓ a↑ ⌂↑ ↕     modtap starts after another key, should let the prior key finish
      •      xx)  print nothing (a is printed outside of this script)
         •  ↕xz)  print ⌂
⌂↓       ⌂↑ ↕     single standalone tap, not hold
         •  ↕00)  print ⌂
⌂↓ a↓ ⌂↑ a↑ ↕     should be ⌂,a as that's just fast typing
•            0a)  print nothing, don't know the future yet, just activate input hook
   •<ΔH      ?0b) print nothing, don't know whether to print ⇧A or ⌂,a, the hold depends on the next key sequence
   •>ΔH      🠿0c) print ⇧A
      •     ↕2a)  print ⌂,a
         •  ↕2b)  print nothing, 2a handle it
⌂↓ a↓ a↑ ⌂↑ 🠿    should be ⇧A, not ⌂
   •              same as above
      •<ΔH  🠿1aa) print ⇧A, also set ⌂ var as a modifier since we know it's not quick typing
      •>ΔH  🠿1ab) print nothing, 0c handled key↓
         •  🠿1b)  print nothing, 1a handles key, ⌂ is a mod
Other options:
  - (✗ need sequence info to set properly) OR just do layers and set global vars like in KE : ⌂f := ['↑',A_TickCount]
todo:
  - try setting the modifier directly instead of (in addition to?) setting the var, could be simpler SendInput("{LShift down}")
  - fix handling of cursor keys (add special logic), set ⌂f.mod is true on cursor key↓
  - add cursor hider
  - add asd to immediately set on key↓ other mods?
  - add xz) 0a) labels to source
  - add a diagram
  - ? track only the opposite half of the layout? would it help with any bugs?
  - ? set all keys to output their shifted states if ⌂f.mod is true? Maybe will be less buggy that using input hooks?
  - convert everything into a char-by-char state machine for each down/up event with input hooks instead that would only set/unset vars?
*/

⌂f := {nm:'f',vk:helperString.key→ahk('f'), pos:'↑', t:A_TickCount, mod:false}
⌂tHold := 0.5 ; treat ⌂ as a modifier if it's held for longer than this many seconds

; #HotIf ⌂f.mod
; ;;; todo set all keys to output their shifted states? maybe will be less buggy that using input hooks?
; ;;; but then need to add a standalone timer to each ⌂f and make sure it's only activated if it's continuously being held down without any interrupts. How?
; 3::msgbox('⌂f.mod') ;
; #HotIf

preciseTΔ() ; start timer for debugging

⌂ΔH := ⌂tHold * 1000
reg_f()
reg_f() { ; f=⌂⇧
  static k	:= keyConstant._map ; various key name constants, gets vk code to avoid issues with another layout
   , s    	:= helperString
   , pre  	:= '$' ; use $kbd hook and don't ~block input to avoid typing lag
  HotKey(pre s.key→ahk('f')      , hkModTapD) ;
  HotKey(pre s.key→ahk('f') ' UP', hkModTapD) ;
}
hkModTapD(ThisHotkey) {
  hk := ThisHotkey
  ; dbgtt(0,ThisHotkey,t:=1) ;
  Switch ThisHotkey, 0 {
    default  : return ; msgbox('nothing matched setChar🠿 ThisHotkey=' . ThisHotkey)
    case ＄ f⃣	     	: modtap(hk,'f',1) ;
    case ＄ f⃣	' UP'	: modtap(hk,'f',0) ;
  }
}

MyCallbackOnKey↓(ih, vk, sc) {
  static k	:= keyConstant._map, kr	:= keyConstant._mapr ; various key name constants, gets vk code to avoid issues with another layout
    , s    	:= helperString
  if ⌂f.pos = '↓' { ; 0) should always be true? otherwise we won't get a callback
    if (t⌂f := A_TickCount - ⌂f.t) > ⌂ΔH { ; 🠿0c)
      ; dbgtt(0,'🠿0c) ⌂f🠿(' t⌂f ') Key↓ ⇧vk' hex(vk) ' sc' hex(sc),t:=2) ; vk57 sc11
      SendInput("{LShift Down}")
      SendInput('{' Format("vk{:x}sc{:x}",vk,sc) '}') ;
    } else { ; ?0b)
      prionm := kr['en'].Get([s.key→ahk(A_PriorKey)],'✗')
      keynm := kr[ 'en'].Get([Format("vk{:x}",vk)],'✗')
      ; dbgtt(0,'✗ ?0b) ⌂f↓(' t⌂f ') Key↓ ' keynm ' prio ‘' prionm '’ vk' hex(vk) ' sc' hex(sc),t:=5 ,,x:=1100,y:=950) ; vk57 sc11
    }
  } else { ; should never get here?;
    dbgMsg(0,'⌂f↑ Key↓ vk' hex(vk) ' sc' hex(sc))
  }
}
MyCallbackOnKey↑(ih, vk, sc) { ;
  static k	:= keyConstant._map, lbl := keyConstant._labels, kr	:= keyConstant._mapr ; various key name constants, gets vk code to avoid issues with another layout
   , s    	:= helperString
  if ⌂f.pos = '↓' { ; 1a)
    global ⌂f
    if (A_TickCount - ⌂f.t) > ⌂ΔH { ; 🠿1ab)
      ; dbgtt(0,'✗ 🠿1ab) ⌂f🠿 Key↑ vk' hex(vk) ' sc' hex(sc),t:=2,,x:=1300,y:=950) ;
      ; SendInput('+' '{' Format("vk{:x}sc{:x}",vk,sc) '}') ;
      ⌂f.mod := true
      SendInput("{LShift Down}")
    ; } else if ((kn:=GetKeyName(Format("vk{:x}",vk))) = A_PriorKey) { ; 🠿1aa)
    } else if ⌂f.vk = s.key→ahk(A_PriorKey) { ; xx)
      ; dbgtt(0,'xx  ⌂f↓ Key↑ ⇧vk' hex(vk) ' sc' hex(sc) ' PreK=' A_PriorKey '=' ⌂f.nm ' ' preciseTΔ(),t:=4,,x:=50) ;
    } else { ; 🠿1aa)
      ; dbgtt(0,'🠿1aa) ⌂f↓ Key↑ ⇧vk' hex(vk) ' sc' hex(sc) ' PreK=' A_PriorKey '≠' ⌂f.nm ' ' preciseTΔ(),t:=4,,x:=50) ;
      SendInput("{LShift Down}")
      ⌂f.mod := true
      SendInput('{' Format("vk{:x}sc{:x}",vk,sc) '}') ;IJJKJJKJKJJK
    }
  } else { ; 2b ??? unreachable since ⌂f↑ cancels input hook?
    dbgMsg(0,'2b ⌂f↑ Key↑ vk' hex(vk) ' sc' hex(sc)) ;
    msgbox('2b do nothing')
  }
}
modtap(hk,c,is↓) { ;
  static k 	:= keyConstant._map, kr := keyConstant._mapr, lbl := keyConstant._labels ; various key name constants, gets vk code to avoid issues with another layout
   , s     	:= helperString
   , ih    	:= '' ; inputhook
   , cbkeys	:= '' ; inputhook key lists that use callbacks
   , breaks	:= '' ; inputhook keys that break the dwdfdffdfddffddfdffddffddfdfdoidoópdpdiIiIzpPpPpPpP
   , labels := Map()
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

  ; loop parse labels['en›'] { ; track half of the layout (right half for left home row mods) to avoid issues
  loop parse labels['en_no‹⌂'] { ; track layout except for same side home row
    cbkeys .= '{' s.key→ahk(A_LoopField) '}'
  }
  ; loop parse labels['‹en'] { ; break on the other half
  ;   breaks .= '{' s.key→ahk(A_LoopField) '}'
  ; } ;;; todo: useless? since anyway it has to be processed, so just not adding callbacks from ↑ is enough?

  vkC := s.key→ahk(c)
  ; dbgtt(0,'c=' c ' vkC=' vkC,t:=2) ;

  static ih := ''
  global ⌂f
  if not is↓ {
    SendInput("{LShift Up}")
    ; dbgtt(0,'up',t:=1) ; ;
    ih_input := ''
    if type(ih) = 'InputHook' { ;
      ; dbgtt(0,'InputHook stopped InProgress=' ih.InProgress,t:=2) ;
      ih_input := ih.Input
      ; dbgtt(0,'InputHook input=' ih.Input,t:=2) ;
      ih.Stop()	;
    }
    if (t⌂f := A_TickCount - ⌂f.t) > ⌂ΔH { ; 1b) ⌂↑ after it's definitely a modifier (timer or a↓a↑)
      ; dbgtt(0,'1b ⌂f↑ after timed ⌂f🠿(' t⌂f ') ' preciseTΔ(),t:=2,,x:=1300,y:=850) ;
      ⌂f.pos  	:= '↑'
      , ⌂f.t  	:= A_TickCount
      , ⌂f.mod	:= false
    } else if ⌂f.mod { ; 1b)
      ; dbgtt(0,'1b ⌂f↑ after sequenced ⌂f🠿(' t⌂f ' < ' ⌂ΔH ') ' preciseTΔ(),t:=2,,x:=1300,y:=850)
      ⌂f.pos  	:= '↑'
      , ⌂f.t  	:= A_TickCount
      , ⌂f.mod	:= false
    } else {
      SendEvent('{blind}' '{' . vkC . ' down}{' . vkC . ' up}') ; (~ does this) type the char right away to avoid delays (to be deleted later on match), use {blind} to retain ⇧◆⎇⎈ positions)
      if (prio := s.key→ahk(A_PriorKey)) = vkC { ; ↕00)
        ; dbgtt(0,'00) ⌂f↑ alone ⌂f🠿(' t⌂f ' < ' ⌂ΔH ') PreKey ' A_PriorKey ' ' preciseTΔ(),t:=2,,x:=1300,y:=850)
      } else { ; ↕2a)
        keynm := kr['en'].Get(prio,'✗')
        ; dbgtt(0,'↕2a) ' keynm ' (' A_PriorKey ') A_PriorKey, print prio ' prio,t:=2)  ;
        ; SendEvent('{' . prio . ' down}{' . prio . ' up}') ; (~ does this) type the char right away to avoid delays (to be deleted later on match), use {blind} to retain ⇧◆⎇⎈ positions)
        SendInput(ih_input) ;
      }
    }
  } else if type(ih) = 'InputHook'
    and ih.InProgress = 1 { ; active ih from some other key, skip?
    ; ⌂f := {pos:'↓', t:A_TickCount, mod:false}
    ; dbgtt(0,'down, ih ' ih.InProgress,t:=2,,x:=0,y:=0) ;
  } else { ;
    ⌂f.pos := '↓'
    , ⌂f.t := A_TickCount
    ; dbgtt(0,'down',t:=) ;
    ; SendEvent('{blind}' '{' . vkC . ' down}{' . vkC . ' up}') ; (~ does this) type the char right away to avoid delays (to be deleted later on match), use {blind} to retain ⇧◆⎇⎈ positions)
    ih := InputHook("L1000 I1") ;;; I1 sendlevel (allows sending keys at level 0), L0 disables collection of text and the length limit, but does not affect which keys are counted as producing text (see VisibleText), can be useful in combination with OnChar, OnKeyDown, KeyOpt or the EndKeys parameter
    ; ih.KeyOpt("{LWin}{RWin}{LAlt}{RAlt}{LCtrl}{RCtrl}{Esc}", "ES")  ; EndKeys (terminate the input) and Suppress (blocks) the key after processing
    ; ih.KeyOpt("{Left}{Up}{Right}{Down}{BackSpace}", "E")  ; EndKeys (terminate the input)
    ; ih.KeyOpt(breaks, "E")  ; EndKeys (terminate the input)
    ;;; todo ↑ remove terminators?
    ; ih.KeyOpt("{vk57}{vk44}{vk32}", "N")  ;w N: Notify. OnKeyDown/OnKeyUp callbacks to be called each time the key is pressed
    ih.KeyOpt(cbkeys, "N")  ;w N: Notify. OnKeyDown/OnKeyUp callbacks to be called each time the key is pressed
    ih.KeyOpt('{Left}{Up}{Right}{Down}', "N")  ;w N: Notify. OnKeyDown/OnKeyUp callbacks to be called each time the key is pressed
    ; ih.KeyOpt("{vk57}", "S")  ;w doesn't work for self, S also doesn't help
    ih.OnKeyUp := MyCallbackOnKey↑
    ih.OnKeyDown := MyCallbackOnKey↓
    ih.Start()	; Starts collecting input
    ih.Wait() 	; Waits until the Input is terminated (InProgress is false)
    if (ih.EndReason != "Max") { ; Timed out without reaching typed char limit
      ; dbgtt(0,'Time out, Input=' ih.Input ' ih.InProgress=' ih.InProgress,t:=2) ;
      ; return False
    } else {
      ; dbgtt(0,'else, Input=' ih.Input ' ih.InProgress=' ih.InProgress,t:=2) ;
      ; return ih.Input ; Returns any text collected since the last time Input was started
    }
  }
}
