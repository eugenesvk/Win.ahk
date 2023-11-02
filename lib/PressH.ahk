#Requires AutoHotKey 2.0.10
;v0.7@23-10

#include <Win>
#include %A_scriptDir%\gVar\PressH.ahk
PressH_ChPick(pChars, pLabel:=unset, pTrigger:="", pHorV:="", pCaret:=1, pis␈:=true) { ; output→CharChoicet
  ; Arg     	Type/Val      	Comment |default value|  ¦alt value¦
  ; pChars  	array         	symbols to insert ['⎋','❖','⌽'...]
  ; pTrigger	char          	key that triggered this function, used to exclude it from the index
  ; pLabel  	array         	key labels to use instead of the usual index (1-9a-z)
  ; pHorV   	|H|V          	Horizontal/Vertical layout of the listboxes
  ; pis␈    	|true|        	Delete last printed char by ‘Send '{BackSpace}'’ before inserting CharChoice (disable if this function is invoked via another method that doesn't type a char)
  ; pCaret  	|1,uia¦2¦[0,0]	Position CharacterPicker @ Text Caret position 1 or 'uia' UIA/Accessibility, 2 no UIA, [x,y] use explicit coords

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
  local curlayout := lyt.GetCurLayout(&lytPhys, &idLang)
  sLng	:= lyt.getLocaleInfo('en',idLang) ; en/ru/... format

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

  if IsSet(pLabel) { ; if passed (should be an array) create a local copy to avoid a bug:
    Labels := pLabel.Clone() ; if pTrigger='a' and matches/removes the first element of pLabel=['a','b'] subsequent calls would show pLabel as ['','b'] even when pTrigger is not 'a' anymore
  } else {
    if lbl_cust.Has(sLng) {
      Labels := lbl_cust[sLng].Clone() ;  clone to avoid ↓ cutting lbl_en_arr instead of just Labels
    } else {
      Labels := lbl_cust['en'].Clone() ;  clone to avoid ↓ cutting lbl_en_arr instead of just Labels
    }
    Labels.Capacity := pChars.Length
  }
  dbgTT(3,'pTrigger=' pTrigger ' pHorV=' pHorV ' pis␈=' pis␈ ' pCaret=' ((type(pCaret)='Array') ? (pCaret[1] '¦' pCaret[2]) : pCaret) ,t:=2) ;

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
  pTriggerNo	:= Ord(StrLower(pTrigger))	; Numeric character code of the trigger key
  GuiTitle  	:= "PressH: Select a special character"
  if WinExist(GuiTitle) { ; show exisitng GUI (when minimized or 2 threads)
    WinActivate
    return
  }

  static lbl_sub     	:= Map() ; map to store substitute layout-specific labels to use when trigger key matches existing labels
  if lbl_sub.Count   	= 0 { ; can set case only on empty maps
    lbl_sub.CaseSense	:= 0
  }
  if not lbl_sub.Has('en') {
    lbl_sub['en'] := 'zyxwvutsrqponmlkjihgfedcba123456789'
  }
  if not lbl_sub.Has('ru') {
    lbl_sub['ru'] := 'яюэьыъщшчцхфутсрпонмлкйизжёедгвба123456789'
  }

  ; HotIfWinActive   	 GuiTitle    	; Catch Arrow hotkeys while GUI is active
    ; Hotkey("~Enter"	, Nav_Pick())	; alternative solution with a button?
  ; tooltip(A_TimeSincePriorHotkey)
  ; HotIfWinActive		; deactivate context sensitivity for hotkeys

  HotIfWinActive       	 GuiTitle    	; Catch Arrow hotkeys while GUI is active
    Hotkey("~BackSpace"	, Nav_Exit)  	; Exit on ⌫
    Hotkey("~Enter"    	, Nav_Pick)  	; Enter inserts selection (if exists) alt button solution?
    Hotkey("~Up"       	, Nav_Return)	; Arrows select, but don't exit (~doesn't block native func)
    Hotkey("~Down"     	, Nav_Return)	;
    Hotkey("~Left"     	, Nav_Return)	;
    Hotkey("~Right"    	, Nav_Return)	;
  HotIfWinActive       	             	; deactivate context sensitivity for hotkeys

  CharChoice:= "", colIndex:=[], colSymbol:=[], skipLbl := 0
  NuChars := pChars.Length
  For i in pChars {
    colSymbol.Push(pChars[A_Index])
    if (A_Index <= (9+26)) { ; 9numbers+26letters=35 symbols
      symStart  	:= 97 ; start with Lowercase 'a'(#97)
      LabelChInd	:= symStart+(A_Index-1)-9 ; ... after 9numbers
    } else if (A_Index <= (9+26+16)) { ; +16 from 0x20–2F range = 51symbols
      symStart  	:= 32 ; continue with Space(32), then Shift+# (#33)
      LabelChInd	:= symStart+(A_Index-1)-35 ; ... after 35symbols
      skipLblBk 	:= skipLbl ; don't skip invoking trigger in symbols
      skipLbl   	:= 0 ; after z will be {, no need to adjust LabelChInd
    } else {
      skipLbl   	:= skipLblBk ; restore skipping invoking trigger
      symStart  	:= 65 ; continue with Uppercase 'A'(#65)
      LabelChInd	:= symStart+(A_Index-1)-51 ; ...after 51symbols
    }
    if (LabelChInd = pTriggerNo) { ; if invoking trigger key matches the label key...
      skipLbl := 1 ; ...skip it...
    }
    LabelChar	:= Chr(LabelChInd+skipLbl) ; ...by adding to the index
    if (A_Index < 10) {
      colIndex.Push(A_Index)
    } else {
      colIndex.Push(LabelChar)
    }
    ; Common character codes include 9 (tab), 10 (linefeed), 13 (carriage return), 32 (space), 48-57 (the digits 0-9), 65-90 (uppercase A-Z), and 97-122 (lowercase a-z)
  }
  if (Type(Labels)="Array") { ; use manual labels
    if Labels.Length < pChars.Length { ; pad Labels' array if it's shorter to avoid a selection error for a non-existing label element
      Loop (pChars.Length - Labels.Length) {
        Labels.Push("")
      }
    } else if Labels.Length > pChars.Length {
      Labels.Capacity := pChars.Length ; cut label's array if it's longer to avoid index error
    }
    pTriggerIndex := HasValue(Labels,pTrigger)
    static labelSub := ' '
    label_list := lbl_sub.Has(sLng) ? lbl_sub[sLng] : lbl_sub['en']
    if (pTriggerIndex >0 ) {	; if Labels includes pTrigger ...
      loop parse (labelSub . label_list) { ; loop through labels to see which one is free
        if HasValue(Labels,A_LoopField) {
          Continue
        } else {
          labelSub := A_LoopField
          Labels[pTriggerIndex] := labelSub	; replace pTrigger with space (alt: "" since some labels use space)
          Break
        }
      }
    }
    colIndex := Labels
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
    Picker.SetFont(CharGUIFontColI " s" CharGUIFontSize, CharGUIFontName)
    LBI := Picker.Add("ListBox", BoxIW BoxIR "AltSubmit vChoiceA " GuiOptX, colIndex)
    Picker.SetFont(CharGUIFontColV " s" CharGUIFontSize " w400", CharGUIFontName)
    LBV := Picker.Add("ListBox", BoxVW BoxVR "AltSubmit vChoiceB" VXtra GuiOptX, colSymbol)
  } else { ; Horizontal alignment, 1. Value 2. Index (like in macOS)
    BoxW   	:= CharGUIWidthColH * NuChars
    BoxIW  	:= BoxVW := " w" BoxW " "
    BoxIR  	:= BoxVR := " R" 1 " "
    VXtra  	:= " "
    DllIW  	:= DllVW := CharGUIWidthColH*DPI ; column width passed via DllCall adjusted for DPI
    BoxWDPI	:= CharGUIWidthColH * NuChars * DPI ; actual Box width
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
    Picker.SetFont(CharGUIFontColV " s" CharGUIFontSize " w400", CharGUIFontName)
    LBV := Picker.Add("ListBox", BoxVW BoxVR "AltSubmit vChoiceB" VXtra GuiOptX, colSymbol)
    Picker.SetFont(CharGUIFontColI " s" CharGUIFontSize, CharGUIFontName)
    LBI := Picker.Add("ListBox", BoxIW BoxIR "AltSubmit vChoiceA " GuiOptX, colIndex)
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

  ; Add triggers that control what happens when a GUI/list element is activated
    Picker.OnEvent("Close", Gui_Close)        	; On Close goes to Gui_Close (Picker)
    Picker.OnEvent("Escape",Gui_Close)        	;    Escape (Picker)
    ;         , (*) => Picker.Destroy())      	; alternative function call
    fnS := PressH_Select.bind(Picker, &pChars)	; Binds parameters to PressH_Select
    LBI.OnEvent("DoubleClick", fnS)           	; Select with a double-click
    LBV.OnEvent("DoubleClick", fnS)           	;   passes (GuiCtrlObj, Info), where Info for ListBox is item position
    LBI.OnEvent("Change", fnS)                	;             a selection chang
    LBV.OnEvent("Change", fnS)                	;   passes (GuiCtrlObj, Info), where Info has no meaning for ListBox

  Picker.Show(LocLB "AutoSize")	;GuiTitle a, xCenter yCenter, GuiTitle
  dbgTT(2,"Debug: Post Picker.Show`nPicker.Title`t" Picker.Title "`npChars[1]`t" pChars[1],TTdelay)
  return

  Nav_Pick(ThisHotkey) {  ;  <—— Keys referring here WILL trigger a selection
    if (Type(SavedGUI) = "Object") { ; avoid error when Enter pressed before selection
      if (dbg>0) {
        TestPrint(SavedGUI, Chars, "LB_Pick", "T2.5")
      }
      PressH_Select(Picker, &Chars) ; can't access ByRef_parameterChars inside a nested function
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

PressH_getPickerLoc(x,y,BoxWDPI) { ; giver caret coordinates and picker box width, adjust the position of the picker to fit the screen and not overlap screen edges
  yOffP := yOffN := 0, symOff := 16
  dbgTT(0,BoxWDPI ' of ' A_ScreenWidth,t:=2)
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

PressH_Select(Picker, &pChars, *) { ;t * allows extra parameters sent by OnEvents
  global is␈, TTdelay,TTx,TTy, SavedGUI := Picker.Submit(0) ; (0) doesn't hide the window
  Arrows     	:= "", AlphaThis := "", AlphaPrior := ""
  ArrowHKeys 	:= "~Down~Up~Left~Right"
  AlphaHKeys 	:= "$a$b$c$d$e$f$g$i$j$k$l$m$n$o$p"
  KeysTimeOut	:= ""
  if (dbg>0) {
    KeysTimeOut := "HK_This`t" . A_ThisHotkey . "(" . Arrows . AlphaThis . ")`n`t" . A_TimeSinceThisHotkey . " ms`nHK_Last`t" . A_PriorHotkey . "(" . AlphaPrior . ")`n`t" . A_TimeSincePriorHotkey . " ms"
  }

  ;——— Loop inside ListBox with arrow keys
  if InStr(ArrowHKeys, A_ThisHotkey) {
    Arrows:="Arrows"
  }
  if (Arrows=="Arrows" And A_TimeSinceThisHotkey>=0 And A_TimeSinceThisHotkey<=99)  {
    dbgTT(1,SavedGUI, pChars, "ArrowHKeys", TTdelay)
    return
  }
  if InStr(AlphaHKeys, A_ThisHotkey) {
    AlphaThis:="AlphaThis"
    dbgMsg(1,"A_ThisHK`t" A_ThisHotkey "`nKeysTimeOut`t" KeysTimeOut, "LoopArrows1", "T0.5")
  }
  if (A_PriorHotkey!="" and InStr(AlphaHKeys, A_PriorHotkey)) {
    AlphaPrior := "AlphaPrior"
  }
  if (AlphaThis=="AlphaThis" and AlphaPrior=="AlphaPrior" and A_TimeSincePriorHotkey>=0 and A_TimeSincePriorHotkey<=800)  {
    dbgMsg(1,"A_ThisHK`t" A_ThisHotkey "`nKeysTimeOut`t" KeysTimeOut, "LoopArrows2", "T0.5")
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
  dbgTT(2,"PreSend: KeysTimeOut`n" KeysTimeOut, TTdelay,2,TTx,TTy)
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
