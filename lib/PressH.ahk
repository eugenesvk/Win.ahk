#Requires AutoHotKey 2.1-alpha.4
;v0.7@23-10

#include <Win>
#include %A_scriptDir%\gVar\PressH.ahk
PressH_ChPick(pChars, pLabel:=unset, pTrigger:="", pHorV:="", pCaret:=1, pis␈:=true, can␠ins:=true) { ; output→CharChoicet
  ;Arg     	Type/Val      	Comment ≝default
  ;pChars  	array         	symbols to insert [⎋,❖,⌽...]
  ;pTrigger	char          	key that triggered this function, used to exclude it from the index
  ;pLabel  	array         	key labels to use instead of the usual index (1-9a-z)
  ;pHorV   	≝H¦V          	Horizontal/Vertical layout of the listboxes
  ;pis␈    	≝true         	Delete last printed char by ‘Send '{BackSpace}'’ before inserting CharChoice (disable if this function is invoked via another method that doesn't type a char)
  ;can␠ins 	≝true         	Space pressed when GUI is shown inserts the first item, otherwise it only selects it (filtered out just like arrow keys)
  ;pCaret  	≝1,uia¦2¦[0,0]	Position CharacterPicker @ Text Caret position 1 or 'uia' UIA/Accessibility, 2 no UIA, [x,y] use explicit coords

  static k   	:= keyConstant._map, lyt_lbl := keyConstant._labels ; various key name constants, gets vk code to avoid issues with another layout
   , s       	:= helperString
   , get⎀    	:= win.get⎀.Bind(win), get⎀GUI	:= win.get⎀GUI.Bind(win), get⎀Acc := win.get⎀Acc.Bind(win)
   , lbl_cust	:= Map()
   , lbl_en := "
      ( Join ` LTrim
       1234567890
       qwertyuiop
       asdfghjkl;
       zxcvbnm,.-=[]'\/`
      )"
   , _d  := 0 ;
   , _d1 := 1 ;
   , _d2 := 2 ;
   , _d3 := 3 ;
  local curlayout := lyt.GetCurLayout(&lytPhys, &idLang)
  sLng	:= lyt.getLocaleInfo('en',idLang) ; en/ru/... format
  Trigger  := StrLower(pTrigger)
  TriggerU := StrUpper(pTrigger)

  if lbl_cust.Count = 0 { ; can set case only on empty maps
    lbl_cust.CaseSense	:= 0
  }
  if not lbl_cust.Has('en') {
    lbl_en_arr := Array()
    lbl_en_arr.Capacity := StrLen(lbl_en)
    loop parse lbl_en { ;
      lbl_en_arr.push(A_LoopField)
    }
    lbl_cust['en'] := lbl_en_arr
  }
  if not lbl_cust.Has(sLng)
    and lyt_lbl.Has(sLng) {
    lbl_cust[sLng] := s.convert_lyt_arr(lbl_cust['en'],sLng,&ℯ:="")
  }

  AllKeys  := isRu() ? KeyboardRNoCap : KeyboardNoCap ; Use language-specific layout for index values
  Labels := []
  if IsSet(pLabel) && (Type(pLabel)="Array") { ; if array passed create a local copy to avoid a bug
    Labels := pLabel.Clone() ; if pTrigger='a' and matches/removes the first element of pLabel=['a','b'] subsequent calls would show pLabel as ['','b'] even when pTrigger is not 'a' anymore
    missing := pChars.Length - Labels.Length
    if        missing > 0 { ; add missing   labels
      for c in AllKeys {
        if !HasValue(pLabel, c) {
          Labels.push(c)
          missing -= 1
          if missing <= 0 {
            break
          }
        }
      }
    } else if missing < 0 { ; cut excessive labels
      Labels.Capacity := pChars.Length
    }
  }
  (dbg<_d3)?'':(dbgTT(0,pTrigger "¦" Trigger "¦" TriggerU "¦ p|Trigger|U" pHorV "¦=pHorV ¦" pis␈ "¦=pis␈ pCaret=" ((type(pCaret)='Array') ? (pCaret[1] '¦' pCaret[2]) : pCaret) ,4)) ;🕐

  #MaxThreadsPerHotkey 1    ;;;
  global is␈ 	:= pis␈  	; Copy of parameter for another function
   , Chars   	:= pChars	; Copy of a ByRef_parameter for a nested function
   , SavedGUI	:= ""    	; Arrows (trigger Events) save GUI for Enter
  ;;; , Gui  	:= ""    	; Enter (no Event trigger) can save GUI from Arrows
   , TTdelay 	:= 2     	; tooltip delay
   , TTx     	:= 2300  	; second tooltip X position
   , TTy     	:= 1200  	; ...            Y
   , LBS_MultiColumn
  if (pHorV="") {
    pHorV := CharGUIFlowDir ; set to a value from gVars if empty (not passed)
  }
  if (pHorV="V") {
    FlowDir := ""
  } else { ; default to Horizontal for all other values
    FlowDir := "+" LBS_MultiColumn
  }
  GuiTitle	:= "PressH: Select a special character"
  if WinExist(GuiTitle) { ; show exisitng GUI (when minimized or 2 threads)
    WinActivate
    return
  }

  ; HotIfWinActive   	 GuiTitle    	; Catch Arrow hotkeys while GUI is active
    ; Hotkey("~Enter"	, Nav_Pick())	; alternative solution with a button?
  ; tooltip(A_TimeSincePriorHotkey)
  ; HotIfWinActive		; deactivate context sensitivity for hotkeys

  ArrowHKeys := "~Down~Up~Left~Right"
  HotIfWinActive       	 GuiTitle    	; Catch Arrow hotkeys while GUI is active
    Hotkey("~BackSpace"	, Nav_Exit)  	; Exit on ⌫
    Hotkey("~Enter"    	, Nav_Pick)  	; Enter inserts selection (if exists) alt button solution?
    Hotkey("~Up"       	, Nav_Return)	; Arrows select, but don't exit (~doesn't block native func)
    Hotkey("~Down"     	, Nav_Return)	;
    Hotkey("~Left"     	, Nav_Return)	;
    Hotkey("~Right"    	, Nav_Return)	;
    if ! can␠ins {
      hks := "*Space" ; ignore modifiers
      Hotkey(hks	, Nav_Return)
      ArrowHKeys	.= hks
    }
  HotIfWinActive		; deactivate context sensitivity for hotkeys

  CharChoice:= "", colIndex:=[], colSymbol:=[], skipLbl := 0
  NuChars := pChars.Length
  if Labels.Length > 0 { ; use manual labels
    for i, c in pChars {
      colSymbol.Push(pChars[i])
    }
    set_space := false
    for i, l in Labels { ; remove trigger key
      if ((l == Trigger)
        ||(l == TriggerU)) {
        if !set_space && (pTrigger != " ") { ; replace 1st dupe with space unless trigger is space
          (dbg<_d3)?'':(dbgtt(0,"replaced dupe ¦" l "¦ with ¦␠¦",5))
          set_space := true
          Labels[i] := " "
        } else { ; replace dupe with any unique letter remaining
          for c in AllKeys {
            if !HasValue(Labels, c) {
              (dbg<_d3)?'':(dbgtt(0,"replaced dupe ¦" l "¦ with ¦" c "¦",5))
              Labels[i] := c
              break
            }
          }
        }
      }
    }
    colIndex := Labels
  } else { ; automatic labels
    i_off := 0
    if IsSet(pLabel) && (Type(pLabel)="String") {
      if (i_found := HasValue(AllKeys, pLabel)) {
        i_off := i_found - 1
      }
    }
    set_space := false
    for i, c in pChars {
      colSymbol.Push(pChars[i])
      ii := i + i_off
      LabelChar   := (ii > AllKeys.Length) ? "" : AllKeys[ii]
      while ((LabelChar == Trigger )
        ||   (LabelChar == TriggerU)) { ; skip lower/upper
        i_off += 1, ii := i + i_off
        if !set_space && (pTrigger != " ") { ; replace 1st dupe with space unless trigger is space
          set_space := true
          LabelChar := " "
        } else {
          LabelChar := (ii > AllKeys.Length) ? "" : AllKeys[ii]
        }
      } ; Common character codes include 9 (tab), 10 (linefeed), 13 (carriage return), 32 (space), 48-57 (the digits 0-9), 65-90 (uppercase A-Z), and 97-122 (lowercase a-z)
      colIndex.Push(LabelChar)
    }
  }

  ChoiceA := 0, ChoiceB := 0, LocLB := ""
  Picker := Gui(, GuiTitle)
  Picker.Opt("-MinimizeBox -Caption -SysMenu -Border +ToolWindow")   ;e +AlwaysOnTop +ToolWindow avoids a taskbar button and an alt-tab menu
  GuiOptX := " -E0x200 " FlowDir ;0x200 WS_EX_CLIENTEDGE remove vertical internal border ; lexikos.github.io/v2/docs/misc/Styles.htm#ListBox
  Picker.MarginX := "-1", Picker.MarginY := "-1"
  ;Picker.Add("Button", "Hidden Default", OK) ; to make enter select
  DPI	:= (A_ScreenDPI / 96) ; Calculate DPI scaling
  if (pHorV="V") { ; Vertical alignment, 1. Index 2. Value
    BoxIW	:= " w" CharGUIWidthI " "   	; Index row width
    BoxVW	:= " w" CharGUIWidthV " "   	; Value row width
    BoxIR	:= BoxVR := " R" NuChars " "	; # of rows
    VXtra	:= " x+0 "                  	; attach Value row to the right
    Picker.SetFont("C" CharGUIFontColI " s" CharGUIFontSize, CharGUIFontName)
    LBI := Picker.Add("ListBox", BoxIW BoxIR "AltSubmit vChoiceA "      GuiOptX, colIndex)
    Picker.SetFont("C" CharGUIFontColV " s" CharGUIFontSize " w400", CharGUIFontName)
    LBV := Picker.Add("ListBox", BoxVW BoxVR "AltSubmit vChoiceB" VXtra GuiOptX, colSymbol)
  } else { ; Horizontal alignment, 1. Value 2. Index (like in macOS)
    CharW  	:= Max(CharGUIWMinColH,Min(CharGUIWidthColH, A_ScreenWidth / NuChars / DPI))
    BoxW   	:= CharW * NuChars
    BoxWDPI	:= CharW * NuChars * DPI ; actual Box width
    BoxIW  	:= BoxVW := " w" BoxW " "
    BoxIR  	:= BoxVR := " R" 1 " "
    VXtra  	:= " "
    DllIW  	:= DllVW := CharW*DPI ; column width passed via DllCall adjusted for DPI
    ; get Window position relative to cursor
    static x,y
    if             pCaret = 1
      or           pCaret = 'uia' { ; use UIA/Accessibility library to get caret position even in apps that don't report it
      if get⎀(&⎀←,&⎀↑,&⎀↔:=0,&⎀↕:=0) {
        LocLB := PressH_getPickerLoc(⎀←     ,⎀↑      ,BoxWDPI)
      }
    } else if      pCaret = 2 { ; get Caret position using the default AHK function
      if (CaretGetPos(&x, &y)) { ; Can get Caret position
        LocLB := PressH_getPickerLoc(x      ,y        ,BoxWDPI)
      }
    } else if Type(pCaret) = 'Array'
      and          pCaret.Length = 2 {
      LocLB := PressH_getPickerLoc(pCaret[1],pCaret[2],BoxWDPI)
    }
    ; show Index row second to match macOS style
    Picker.SetFont("C" CharGUIFontColV " s" CharGUIFontSize " w400", CharGUIFontName)
    LBV := Picker.Add("ListBox", BoxVW BoxVR "AltSubmit vChoiceB" VXtra GuiOptX, colSymbol)
    Picker.SetFont("C" CharGUIFontColI " s" CharGUIFontSize, CharGUIFontName)
    LBI := Picker.Add("ListBox", BoxIW BoxIR "AltSubmit vChoiceA "      GuiOptX, colIndex)
    ; adjust column width in horizontal view
    hwndLBI := ControlGetHwnd(LBI), hwndLBV := ControlGetHwnd(LBV)
    DllCall("SendMessage", "Ptr",hwndLBI, "UInt",LB_SetColumnWidth, "Ptr",DllIW, "Ptr", 0)
    DllCall("SendMessage", "Ptr",hwndLBV, "UInt",LB_SetColumnWidth, "Ptr",DllVW, "Ptr", 0)
    ControlFocus(LBI) ; Switch focus to Index row
  }
  ; Create two ListBoxes: 1. Labels, 2. Characters (allows different styles)
    ; AltSubmit: Picker.Submit item's position rather than text ;BackgroundFFDD99
  if (dbg>0) {
    waitingState := true ; Tracks whether the function has finished
  }

  fnS := PressH_Select.bind(Picker,&ArrowHKeys,&pChars)	; Binds parameters to PressH_Select
  ; Add triggers that control what happens when a GUI/list element is activated
    Picker.OnEvent("Close", Gui_Close)  	; On Close goes to Gui_Close (Picker)
    Picker.OnEvent("Escape",Gui_Close)  	;    Escape (Picker)
    ;         , (*) => Picker.Destroy())	; alternative function call
    LBI.OnEvent("DoubleClick", fnS)     	; Select with a double-click
    LBV.OnEvent("DoubleClick", fnS)     	;   passes (GuiCtrlObj, Info), where Info for ListBox is item position
    LBI.OnEvent("Change", fnS)          	;             a selection chang
    LBV.OnEvent("Change", fnS)          	;   passes (GuiCtrlObj, Info), where Info has no meaning for ListBox

  Picker.Show(LocLB "AutoSize")	;GuiTitle a, xCenter yCenter, GuiTitle
  dbgTT(2,"Debug: Post Picker.Show`nPicker.Title`t" Picker.Title "`npChars[1]`t" pChars[1],TTdelay)
  return

  Nav_Pick(ThisHotkey) {  ;  <—— Keys referring here WILL trigger a selection
    if (Type(SavedGUI) = "Object") { ; avoid error when Enter pressed before selection
      if (dbg>0) {
        TestPrint(SavedGUI, Chars, "LB_Pick", "T2.5")
      }
      PressH_Select(Picker, &ArrowHKeys, &Chars) ; can't access ByRef_parameterChars inside a nested function
    }
    return
  }
  Nav_Return(ThisHotkey) {  ; <—— Keys referring here will NOT trigger a selection
    return
  }
  Nav_Exit(ThisHotkey) {  ; <—— Keys referring here will exit
    Gui_Close(Picker)
  }
}

PressH_getPickerLoc(x,y,BoxWDPI) { ; given caret coordinates and picker box width, adjust the position of the picker to fit the screen and not overlap screen edges
  yOffP := yOffN := 0, symOff := 16
  dbgTT(4,BoxWDPI ' of ' A_ScreenWidth,t:=2)
  if (y    < symOff*8) { ; if too close to the top of the screen
    yOffP := symOff*3 ; move below the cursor
  } else {
    yOffN := symOff*5 ; otherwise move above the cursor
  }
  if        (BoxWDPI >  A_ScreenWidth   ) { ; too wide to fully fit the screen
    xOffN := x ; move to the left (still won't fit, but oh well)
  } else if (BoxWDPI > (A_ScreenWidth-x)) { ; too wide to fully fit to the right of cursor
    xOffN := BoxWDPI - (A_ScreenWidth-x) ; move to the left the cursor until it fits fully
  } else {
    xOffN := symOff ; move slightly to the left of the cursor
  }
  LocLB := " x" x-xOffN " y" y+yOffP-yOffN " "
  return LocLB
}

PressH_Select(Picker, &ArrowHKeys, &pChars, *) { ;t * allows extra parameters sent by OnEvents
  global is␈, TTdelay,TTx,TTy, SavedGUI := Picker.Submit(0) ; (0) doesn't hide the window
  Arrows     	:= "", AlphaThis := "", AlphaPrior := ""
  AlphaHKeys 	:= "$a$b$c$d$e$f$g$i$j$k$l$m$n$o$p"
  KeysTimeOut	:= ""
  _d  := 1 ;
  _d1 := 1 ;
  _d2 := 0 ;
  (dbg<_d)?'':(dbgtt(0,'hk= ' A_ThisHotkey ' name=¦' GetKeyName(A_ThisHotkey) '¦',3))
  (dbg<_d)?'':(KeysTimeOut := "HK_This`t" . A_ThisHotkey . "(" . Arrows . AlphaThis . ")`n`t" . A_TimeSinceThisHotkey . " ms`nHK_Last`t" . A_PriorHotkey . "(" . AlphaPrior . ")`n`t" . A_TimeSincePriorHotkey . " ms")

  ;——— Loop inside ListBox with arrow keys
  if InStr(ArrowHKeys, A_ThisHotkey) {
    Arrows:="Arrows"
  }
  if (Arrows=="Arrows" And A_TimeSinceThisHotkey>=0 And A_TimeSinceThisHotkey<=99)  {
    dbgTT(_d1,SavedGUI, pChars, "ArrowHKeys", TTdelay)
    return
  }
  if InStr(AlphaHKeys, A_ThisHotkey) {
    AlphaThis:="AlphaThis"
    dbgMsg(_d1,"A_ThisHK`t" A_ThisHotkey "`nKeysTimeOut`t" KeysTimeOut, "LoopArrows1", "T0.5")
  }
  if (A_PriorHotkey!="" and InStr(AlphaHKeys, A_PriorHotkey)) {
    AlphaPrior := "AlphaPrior"
  }
  if (AlphaThis=="AlphaThis" and AlphaPrior=="AlphaPrior" and A_TimeSincePriorHotkey>=0 and A_TimeSincePriorHotkey<=800)  {
    dbgMsg(_d1,"A_ThisHK`t" A_ThisHotkey "`nKeysTimeOut`t" KeysTimeOut, "LoopArrows2", "T0.5")
    return
  }

  if (dbg>0) {
    TestTooltip(SavedGUI, pChars, "PreCharChoice", TTdelay)
    waitingState := false
  }
  CharChoice := pChars[max(SavedGUI.ChoiceA, SavedGUI.ChoiceB)]
  Picker.Destroy()
  if (CharChoice = "") {
    Exit
  }
  dbgTT(_d2,"PreSend: KeysTimeOut`n" KeysTimeOut, TTdelay,2,TTx,TTy)
  if is␈ {
    Send('{BackSpace}' CharChoice)	;A_TimeSincePriorHotkey (add 2nd {BackSpace})
  } else {
    Send(CharChoice)
  }
  return
}

TestPrint(SavedGUI, pChars, Title, Time, *) {
  CharChA := (SavedGUI.ChoiceA>0) ?	pChars[SavedGUI.ChoiceA] : "N/A"
  CharChB := (SavedGUI.ChoiceB>0) ?	pChars[SavedGUI.ChoiceB] : "N/A"
  MsgBox("HK_This`t" A_ThisHotkey "`nHK_Prior`t" A_PriorHotkey "`nHK_TimeSinceThis`t" A_TimeSinceThisHotkey "`nChoiceA`t" SavedGUI.ChoiceA "`nChoiceB`t" SavedGUI.ChoiceB "`npChars[A]`t" CharChA "`npChars[B]`t" CharChB, "Debug: " Title, Time)
}
TestTooltip(SavedGUI, pChars, Title, Period , *) {
  CharChA := (SavedGUI.ChoiceA>0) ?	pChars[SavedGUI.ChoiceA] : "N/A"
  CharChB := (SavedGUI.ChoiceB>0) ?	pChars[SavedGUI.ChoiceB] : "N/A"
  ToolTip("Debug: " Title "`nHK_This`t" A_ThisHotkey "`nHK_Prior`t" A_PriorHotkey "`nHK_TimeSinceThis`t" A_TimeSinceThisHotkey "`nChoiceA`t" SavedGUI.ChoiceA "`nChoiceB`t" SavedGUI.ChoiceB "`npChars[A]`t" CharChA "`npChars[B]`t" CharChB)
  SetTimer () => ToolTip(), -1000*Period ; -Period to run timer only once
}

Gui_Close(Picker) {
  Picker.Destroy()
  return
}

/* Help
Event      	Raised when...              	GuiControls
DoubleClick	Control is double-clicked   	ListBox
Change     	Control's value changes     	ListBox
Focus      	Control gains keyboard focus	ListBox
LoseFocus  	Control loses keyboard focus	ListBox
autohotkey.com/board/topic/29362-browse-a-listbox-with-arrow-keys/
nadeausoftware.com/articles/2010/07/java_tip_systemcolors_mac_os_x_user_interface_themes
 */
