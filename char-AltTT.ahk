#Requires AutoHotKey 2.1-alpha.4
#include <keyHelp>	; List of all registered hotkeys with help

; #HotIf WinActive("ahk_class PX_WINDOW_CLASS") ; Or WinActive("ahk_class GxWindowClass")

; k​ zero-width space helps search the last key in source files, it's cleaned up on import
keysCsub() ;⎇K⃣  adds accent to the next key. /board/topic/27801-special-characters-osx-style
keysCsub() { ; longer (and dupe), but can use ⇧ and adds to help
  static k	:= keyConstant._map ; various key name constants, gets vk code to avoid issues with another layout
   , s    	:= helperString
   , p    	:= helperPath
   , pre  	:= '$~' ; use $kbd hook and don't ~block input to avoid typing lag
   , k→a := s.key→ahk.Bind(helperString)  ; ⎇⇧c or !+c ⟶ !+vk43
  hk🛈("⇧⎇/​" 	,hkCSub,,Map("h","´ acute"           	,"f",p.fname_(A_LineFile),"l№",A_LineNumber))
  hk🛈("⇧⎇``​"	,hkCSub,,Map("h","` grave"           	,"f",p.fname_(A_LineFile),"l№",A_LineNumber))
  hk🛈("⇧⎇c​" 	,hkCSub,,Map("h","ˆ circumflex"      	,"f",p.fname_(A_LineFile),"l№",A_LineNumber))
  hk🛈("⇧⎇u​" 	,hkCSub,,Map("h","¨ diaeresis/umlaut"	,"f",p.fname_(A_LineFile),"l№",A_LineNumber))
  hk🛈("⇧⎇m​" 	,hkCSub,,Map("h","¯ macron"          	,"f",p.fname_(A_LineFile),"l№",A_LineNumber))
  hk🛈("⇧⎇e​" 	,hkCSub,,Map("h","~ tilde"           	,"f",p.fname_(A_LineFile),"l№",A_LineNumber))
  hk🛈("⇧⎇o​" 	,hkCSub,,Map("h","others"            	,"f",p.fname_(A_LineFile),"l№",A_LineNumber))
  hk🛈("⇧⎇p​" 	,hkCSub,,Map("h","others2"           	,"f",p.fname_(A_LineFile),"l№",A_LineNumber))
}
hkCsub(hk_dirty) {
  static k := helperString.key→ahk.Bind(helperString)
  hk := StrReplace(StrReplace(hk_dirty,'~'),'$') ; other hotkeys may register first without ＄ ˜
  Switch hk, 0 { ; Hotkey created → key name and ordering of its modifier symbols gets fixed
    default  : return ; dbgtt(0,'nothing matched hkCsub hk=' . hk, 4)
    case k("⇧⎇c" 	) : csubA(Dia["ˆ"])
    case k("⇧⎇/" 	) : csubA(Dia["´"])
    case k("⇧⎇``"	) : csubA(Dia["``"])
    case k("⇧⎇u" 	) : csubA(Dia["¨"])
    case k("⇧⎇m" 	) : csubA(Dia["¯"])
    case k("⇧⎇e" 	) : csubA(Dia["~"])
    case k("⇧⎇p" 	) : csubA(Dia["oth"])
    case k("⇧⎇o" 	) : csub(Dia["oall"],'M')
  }
}

keysAltTT()
keysAltTT() { ;⎇K⃣  various symbols in a popup panel
  static k	:= keyConstant._map ; various key name constants, gets vk code to avoid issues with another layout
   , s    	:= helperString
   , p    	:= helperPath
   , pre  	:= '$~' ; use $kbd hook and don't ~block input to avoid typing lag
   , k→a := s.key→ahk.Bind(helperString)  ; ⎇⇧c or !+c ⟶ !+vk43
  hk🛈("‹⎇``​​"	,hkAltTT,,Map("h","Paragraphs"       	,"f",p.fname_(A_LineFile),"l№",A_LineNumber))
  hk🛈("⇧⎇1​"  	,hkAltTT,,Map("h","Single Quotes"    	,"f",p.fname_(A_LineFile),"l№",A_LineNumber))
  hk🛈("⇧⎇2​"  	,hkAltTT,,Map("h","Double Quotes"    	,"f",p.fname_(A_LineFile),"l№",A_LineNumber))
  hk🛈("⇧⎇4​"  	,hkAltTT,,Map("h","currency"         	,"f",p.fname_(A_LineFile),"l№",A_LineNumber))
  hk🛈("⇧⎇5​"  	,hkAltTT,,Map("h","Percent"          	,"f",p.fname_(A_LineFile),"l№",A_LineNumber))
  hk🛈("⇧⎇6​"  	,hkAltTT,,Map("h","Superscript"      	,"f",p.fname_(A_LineFile),"l№",A_LineNumber))
  hk🛈("⇧⎇7​"  	,hkAltTT,,Map("h","Subscript"        	,"f",p.fname_(A_LineFile),"l№",A_LineNumber))
  hk🛈("⇧⎇8​"  	,hkAltTT,,Map("h","Fractions"        	,"f",p.fname_(A_LineFile),"l№",A_LineNumber))
  hk🛈("⇧⎇9​"  	,hkAltTT,,Map("h","‹"                	,"f",p.fname_(A_LineFile),"l№",A_LineNumber))
  hk🛈("⇧⎇0​"  	,hkAltTT,,Map("h","›"                	,"f",p.fname_(A_LineFile),"l№",A_LineNumber))
  hk🛈("⇧⎇r​"  	,hkAltTT,,Map("h","Misc"             	,"f",p.fname_(A_LineFile),"l№",A_LineNumber))
  hk🛈("⇧⎇q​"  	,hkAltTT,,Map("h","system"           	,"f",p.fname_(A_LineFile),"l№",A_LineNumber))
  hk🛈("⇧⎇a​"  	,hkAltTT,,Map("h","Arrows"           	,"f",p.fname_(A_LineFile),"l№",A_LineNumber))
  hk🛈("⇧⎇t​"  	,hkAltTT,,Map("h","Math"             	,"f",p.fname_(A_LineFile),"l№",A_LineNumber))
  hk🛈("⇧⎇y​"  	,hkAltTT,,Map("h","Math"             	,"f",p.fname_(A_LineFile),"l№",A_LineNumber))
  hk🛈("⇧⎇d​"  	,hkAltTT,,Map("h","Illegal Filenames"	,"f",p.fname_(A_LineFile),"l№",A_LineNumber))
  hk🛈("⇧⎇b​"  	,hkAltTT,,Map("h","Bullet"           	,"f",p.fname_(A_LineFile),"l№",A_LineNumber))
  hk🛈("⇧⎇k​"  	,hkAltTT,,Map("h","TypES with ⌥"     	,"f",p.fname_(A_LineFile),"l№",A_LineNumber))
  hk🛈("⇧⎇l​"  	,hkAltTT,,Map("h","TypES with ⌥⇧"    	,"f",p.fname_(A_LineFile),"l№",A_LineNumber))
}
hkAltTT(hk_dirty) {
  static k := helperString.key→ahk.Bind(helperString)
  hk := StrReplace(StrReplace(hk_dirty,'~'),'$') ; other hotkeys may register first without ＄ ˜
  Switch hk, 0 { ; Hotkey created → key name and ordering of its modifier symbols gets fixed
    default  : return ; dbgtt(0,'nothing matched hkCsub hk=' . hk, 4)
    ; 13 offset starts with Qwerty instead of `
    case k("‹⎇``"	) : alt_tt_popup("Para"   ,13)
    case k("⇧⎇1" 	) : alt_tt_popup("QuotesS",13)
    case k("⇧⎇2" 	) : alt_tt_popup("QuotesD",13)
    case k("⇧⎇4" 	) : R:=lRu(),csub(intersperse([],Ch["Currency"],,1) "`n" intersperse(Ch["CurrLab" R], Ch["Currency" R]),'M')
    case k("⇧⎇5" 	) : alt_tt_popup("Percent",13)
    case k("⇧⎇6" 	) : alt_tt_popup("Superscript")
    case k("⇧⎇7" 	) : alt_tt_popup("Subscript")
    case k("⇧⎇8" 	) : alt_tt_popup("Fractions")
    case k("⇧⎇9" 	) : SendText("‹")
    case k("⇧⎇0" 	) : SendText("›")
    case k("⇧⎇r" 	) : alt_tt_popup("Checks")
    case k("⇧⎇q" 	) : alt_tt_popup("XSymbols",1)
    case k("⇧⎇a" 	) : alt_tt_popup("Arrows")
    case k("⇧⎇t" 	) : alt_tt_popup("Math")
    case k("⇧⎇y" 	) : alt_tt_popup("Math2")
    case k("⇧⎇d" 	) : alt_tt_popup("WinFile")
    case k("⇧⎇b" 	) : alt_tt_popup("Bullet",13)
    case k("⇧⎇k" 	) : R:=lRu(),csub(intersperse(Bir["1Lab"],Bir["1" R]) "`n" intersperse(Bir["QLab" R],Bir["Q" ]) "`n" intersperse(Bir["ALab" R],Bir["A" ]) "`n" intersperse(Bir["ZLab" R],Bir["Z" R]),'M',,ListenTimerLong)
    case k("⇧⎇l" 	) : R:=lRu(),csub(intersperse(Bir["1Lab"],Bir["1s" ]) "`n" intersperse(Bir["QLab" R],Bir["Qs"]) "`n" intersperse(Bir["ALab" R],Bir["As"]) "`n" intersperse(Bir["ZLab" R],Bir["Zs" ]),'M',,ListenTimerLong)
  }
}
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
  arComb := ""
  AllKeys := isRu() ? KeyboardR : Keyboard  ; Use language-specific layout for index values
  sep№ := 0 ; cumulative № of skips to adjust index position
  for i,val in pVal {
    no_lbl     	:= 0
    if         	val = ␞ {
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
