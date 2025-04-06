﻿#Requires AutoHotKey 2.1-alpha.4
; #HotIf WinActive("ahk_class PX_WINDOW_CLASS") ; Or WinActive("ahk_class GxWindowClass")

;Alt+Key adds accent to the next key. /board/topic/27801-special-characters-osx-style
!+vkBF::	csubA(Dia["´"])      	;⌥⇧/​	vkBF ⟶ ´ acute ?(using VK + scancode)
!+vkC0::	csubA(Dia["``"])     	;⌥⇧`​	vkC0 ⟶ ` grave ?(using VK + scancode)
!+c::   	csubA(Dia["ˆ"])      	;⌥⇧c​	vk43 ⟶ ˆ circumflex
!+u::   	csubA(Dia["¨"])      	;⌥⇧u​	vk55 ⟶ ¨ diaeresis/umlaut
!+m::   	csubA(Dia["¯"])      	;⌥⇧m​	vk4D ⟶ ¯ macron
!+e::   	csubA(Dia["~"])      	;⌥⇧e​	vk55 ⟶ ~ tilde
!+p::   	csubA(Dia["oth"])    	;⌥⇧p​	vk50 ⟶ others2 (must be unique letters)
!+o::   	csub(Dia["oall"],'M')	;⌥⇧o​	vk4F ⟶ others

; !vk34::                                       ;⌥4​ vk34 ⟶ Paragraphs
; !+vk33::                                       ;⌥⇧3 vk33 ⟶ Paragraphs conflicts
; !vk35::                                      ;⌥5 vk35 ⟶ Paragraphs
<!vkC0::csub(intersperse([], Ch["Para"],,,isRu()))	;⌥`​ vkC0 ⟶ Paragraphs
!+vk31::csub(intersperse([], Ch["QuotesS"],,1))   	;⌥⇧1​	vk31	⟶ Single Quotes
!+vk32::csub(intersperse([], Ch["QuotesD"],,1))   	;⌥⇧2​	vk32	⟶ Double Quotes
!+vk34::R:=isRu(),csub(intersperse([],Ch["Currency"],,1,R) "`n" intersperse(Ch["CurrLab" R], Ch["Currency" R]),'M') ;⌥⇧4​ vk34 ⟶ currency
!+vk35::csub(intersperse([],Ch["Percent"],,1))        	;⇧⌥5​ 	vk35	⟶ Percent
!+vk36::alt_tt_popup("Superscript")                   	;⇧⌥6​ 	vk36	⟶ Superscript
!+vk37::alt_tt_popup("Subscript")                     	;⇧⌥7​ 	vk37	⟶ Subscript
!+vk38::alt_tt_popup("Fractions")                     	;⇧⌥8​ 	vk38	⟶ Fractions
!+vk39::SendText("‹")                                 	; ⌥9​ 	vk39	⟶ ‹
!+vk30::SendText("›")                                 	; ⌥0​ 	vk30	⟶ ›
;!vk39::csub("")                                      	; ⌥9​ 	vk39	⟶ SOMETHING
;!vk30::csub("")                                      	; ⌥0​ 	vk30	⟶ SOMETHING
;!vkBD::csub(intersperse(Ch["DashLab"],Ch["Dash"],,1))	; ⌥-​ 	VKBD	⟶ Dashes
;!vkBB::csub("1≈2≠")                                  	; ⌥=​ 	VKBB	⟶ Equal signs
!+r::alt_tt_popup("Checks")                           	;⇧⌥r​ 	vk52	⟶ Misc
!+q::alt_tt_popup("XSymbols",1)                       	 ;⌥⇧q​	vk51	⟶ system
!+a::alt_tt_popup("Arrows")                           	;⌥⇧a​ vk41 ⟶ Arrows
!+t::alt_tt_popup("Math")                             	;⌥⇧t​ math vk54
!+y::alt_tt_popup("Math2")                            	;⌥⇧y​ math vk59
!+d::alt_tt_popup("WinFile")                          	;⌥⇧d	vk44	⟶ Illegal Filename Replacement
!+b::alt_tt_popup("Bullet",1)                         	;⌥⇧b	vk42	⟶ Bullet
!+k::R:=isRu(),csub(intersperse(Bir["1Lab"],Bir["1" R]) "`n" intersperse(Bir["QLab" R],Bir["Q" ]) "`n" intersperse(Bir["ALab" R],Bir["A" ]) "`n" intersperse(Bir["ZLab" R],Bir["Z" R]),'M',,ListenTimerLong) ;⌥⇧k​ VK4B ⟶ TypES with ⌥
!+l::R:=isRu(),csub(intersperse(Bir["1Lab"],Bir["1s" ]) "`n" intersperse(Bir["QLab" R],Bir["Qs"]) "`n" intersperse(Bir["ALab" R],Bir["As"]) "`n" intersperse(Bir["ZLab" R],Bir["Zs" ]),'M',,ListenTimerLong) ;⌥⇧l​ VK4C ⟶ TypES with ⌥⇧

alt_tt_popup(name:="", pOffset:=0) {
  i_val    	:= name ; Math2
  if       	Ch.has(i_val) {
    val    	:= Ch[i_val]
  } else   	{
    return 	;
  }        	;
  i_lbl    	:= name . "Lab" lRu() ; Math2LabRu
  if       	Ch.has(i_lbl) {
    lbl    	:= Ch[i_lbl]
  } else   	{
    i_lbl  	:= name . "Lab" ; Math2Lab
    if     	Ch.has(i_lbl) {
      lbl  	:= Ch[i_lbl]
    } else 	{
      lbl  	:= []
    }      	;
  }        	;
  i_sep    	:= name . "Sp" ; Math2Sp
  sep      	:= Ch.has(i_sep) ? Ch[i_sep] : []
  splitMode	:= (sep.Length > 0) ? "M" : "A"
  csub(intersperse(lbl, val, sep, pOffset,, &splitMode), splitMode) ;
}

intersperse(pLabel, pVal, pSplit:=[], pOffset:=0, &outMap:=Map(), &splitMode:="A") { ;[a b]+[1 2]=[a1 b2]
  ; insert newline splits at tSplit#s or when encountering an empty "" string or  records separator
  ; pOffset labels to avoid e.g. ` in `12  outMap to preserve values as is since stringifying them can lead to bugs: indexing a string by "char" cuts unicode chars in half
  ; splitMode is changed to "M"anual if any separator is encountered
  static seps := [␞,""]
  arComb := ""
  AllKeys := isRu() ? KeyboardR : Keyboard  ; Use language-specific layout for index values
  sep№ := 0 ; cumulative № of skips to adjust index position
  for i,val in pVal {
    no_lbl     	:= 0
    if         	HasValue(seps  ,val) {
      sep№--   	; allows specifying separator only in the values, but not the labels
      splitMode	:="M"
      no_lbl   	:= 1
      delim    	:= "`n" ; split if index is in the values
    } else if  	HasValue(pSplit,i) {
      splitMode	:="M"
      delim    	:= "`n" ; split if index is in Split hints array
    } else     	{
      delim    	:= " "
    }          	;
    ii         	:= i + sep№
    if no_lbl  	{
      lbl      	:= ""
    } else     	{
      lbl      	:= (ii > pLabel.Length) ? AllKeys[ii+pOffset] : pLabel[ii] ; use Full Keyboard for index when not enough Labels
    }          	;
    arComb     	.= lbl . val . delim
    outMap[lbl]	:= val
  }
  return arComb
}

csubA(map) { ; generate Tooltip (lower+Upper) from a string of diacritics
  mapL:="", mapU:="", TipL:="", TipU:="", subI:="", subNA :=""
  mapNA := RemoveLetterAccents(map)
  Loop StrLen(map) {
    subI 	:= SubStr(map  , A_Index, 1)
    subNA	:= SubStr(mapNA, A_Index, 1)
    TipL 	.= subNA subI " "
    TipU 	.= subNA subI " "
  }
  TipL:=RTrim(strLower(TipL)," "), TipU:=RTrim(StrUpper(TipU)," ")
  TipCombo := TipL "`n" TipU
  csub(TipCombo,'M')
}
csubmap(inter_map,inter_str,splitMode:="A",lineLen:=40,listenTimer:="") {
  if (splitMode = "M") { ; Manual split mode, `n newline chars are inside map
    Tooltip(inter_str)
  } else { ; Automatic split mode with map split by lineLen number of chars
    mapMulti	:= [] ; Tooltip map
    TTMulti 	:= "" ; Tooltip
    Loops   	:= Round(StrLen(inter_str)/lineLen) + 1
    Loop Loops {
      mapMulti.Push SubStr(inter_str, 1+lineLen*(A_Index-1), lineLen)
      TTMulti .= mapMulti[A_Index] "`n"
    }
    Tooltip(Trim(TTMulti,"`n"))
  }
  c := ListenChar(listenTimer="" ? ListenTimerShort : listenTimer) ; Read a char with global timer as a fallback
  if (c) { ; char $c typed before timeout
    if inter_map.Has(c) { ; search $c in passed map $inter_map
      SendText(inter_map[c]) ; print the found char with diacritics
    }
  }
  Tooltip()
  Return
}
csub(map,splitMode:="A",lineLen:=40,listenTimer:="") {
  ;Gui := Gui()
  ;Gui.Opt("+LastFound +AlwaysOnTop -Caption +ToolWindow")  ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
  ;Gui.BackColor := "EEAA99"  ; Can be any RGB color (it will be made transparent below).
  ;Gui.SetFont("s32")  ; Set a large font size (32-point).
  ;CoordText := Gui.Add("Text", "cLime", "XXXXX YYYYY")  ; XX & YY serve to auto-size the window.
  ; Make all pixels of this color transparent and make the text itself translucent (150):
  ;WinSetTransColor(Gui.BackColor " 150")
  ;SetTimer(() => UpdateOSD(CoordText), 200)
  ;UpdateOSD(CoordText)  ; Make the first update immediate rather than waiting for the timer.
  ;Gui.Show("x0 y400 NoActivate")  ; NoActivate avoids deactivating the currently active window.
  ;UpdateOSD(GuiCtrl) {
  ;  MouseGetPos(&MouseX, &MouseY)
  ;  GuiCtrl.Value := "X" MouseX ", Y" MouseY
  ;}

  if (splitMode = "M") { ; Manual split mode, `n newline chars are inside map
    Tooltip(map)
  } else { ; Automatic split mode with map split by lineLen number of chars
    mapMulti	:= [] ; Tooltip map
    TTMulti 	:= "" ; Tooltip
    loop_c  	:= Round(StrLen(map)/lineLen) + 1
    Loop loop_c {
      mapMulti.Push SubStr(map, 1+lineLen*(A_Index-1), lineLen)
      TTMulti .= mapMulti[A_Index] "`n"
    }
    Tooltip(Trim(TTMulti,"`n"))
  } ; Read a single char with global ListenTimerShort if listenTimer is not set
  c := ListenChar(listenTimer="" ? ListenTimerShort : listenTimer)
  if (c) { ; char $c typed before timeout
    if (i := InStr(map, c, isCaSe:=true)) { ; Search $c in passed string $map
      SendText(SubStr(map, i+1, 1)) ; Get next char with diacritics
    }
  }
  Tooltip()
  Return
}

ListenChar(listenT:=2) { ; Listen for 1 char and return it
  ih := InputHook("L1 T" listenT "C") ; Listen for L1char, T2sec, Case sensitive
  ih.KeyOpt("{LWin}{RWin}{LAlt}{RAlt}{LCtrl}{RCtrl}{Esc}", "ES")  ; EndKeys (terminate the input) and Suppress (blocks) the key after processing
  ih.KeyOpt("{Left}{Up}{Right}{Down}{BackSpace}", "E")  ; EndKeys (terminate the input)
  ih.Start()	; Starts collecting input
  ih.Wait() 	; Waits until the Input is terminated (InProgress is false)
  if (ih.EndReason != "Max") { ; Timed out without reaching typed char limit
    return False
  } else {
    return ih.Input ; Returns any text collected since the last time Input was started
  }
}

/* HELP
For ALT hotkeys that use the keyboard hook like $!a and #HotIfWinActive, control keystrokes are sent to avoid activating the active window's menu bar. Since this method is the only one I know, this behavior is by design and seems necessary.
It's conceivable that AutoHotkey could check the active window to see if it has a menu bar or icon-menu, and if it doesn't avoid sending the control keystrokes. However, querying the active window might be risky because if it's hung, it could cause the script to hang, which might temporarily freeze up the keyboard due to the keyboard hook. Furthermore, analyzing the active window might be impossible on Windows Vista if that window is running as admin but the script isn't.
autohotkey.com/board/topic/20375-ifwinactive-alt-included-hotkey-generates-control-key/
autohotkey.com/board/topic/20619-extraneous-control-key-presses-generated-by-or-hotkeys/

{Blind}
  - causes SetStoreCapslockMode to be ignored (the state of Capslock is not changed)
  - omits the extra Control keystrokes that would otherwise be sent; such keystrokes prevent: 1) Start Menu appearance during LWin/RWin keystrokes; 2) menu bar activation during Alt keystrokes.

KeyEvent(KEYDOWNANDUP, 0xFF, 0x0FF) or just KEYUP used in place of the Down&Up Control send... looks like an easy solution
*/
