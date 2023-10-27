﻿#Requires AutoHotKey 2.1-alpha.4
;v0.6@20-06

; F7::PressH_ChPick(ChXSymbols,ChXSymbolsLab,,"H","C","noBS")
; F8::PressH_ChPick(ChMath,,,"V","C","noBS")
; F9::PressH_ChPick(ChMathS,,,,"C","noBS") ; uses Global
PressH_ChPick(pChars, pLabel:=unset, pTrigger:="", pHorV:="", pCaret:="C", pBS:="BS") { ; output→CharChoicet
  ; pTrigger	- key that triggered this function, used to exclude it from the index
  ; pLabel  	- key labels to use instead of the usual index (1-9a-z)
  ; pHorV   	- Horizontal/Vertical layout of the listboxes
  ; pBS     	- Send '{BackSpace}' before inserting CharChoice (disable if this function is invoked via another method that doesn't type a char)
  ; pCaret  	- Position CharacterPicker@Text Caret position
  if IsSet(pLabel) { ; if passed (should be an array) create a local copy to avoid a bug:
    Labels := pLabel.Clone() ; if pTrigger='a' and matches/removes the first element of pLabel=['a','b'] subsequent calls would show pLabel as ['','b'] even when pTrigger is not 'a' anymore
  } else {
    Labels := ""
  }

  #MaxThreadsPerHotkey 1    ;;;
  global BS  	:= pBS   	; Copy of parameter for another function
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
  GuiTitle  	:= "AHK: Select a special character"
  if WinExist(GuiTitle) { ; show exisitng GUI (when minimized or 2 threads)
    WinActivate
    Return
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
    } Else if (A_Index <= (9+26+16)) { ; +16 from 0x20–2F range = 51symbols
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
    }
    pTriggerIndex := HasValue(Labels,pTrigger)
    if (pTriggerIndex >0 ) {      	; if Labels includes pTrigger ...
      Labels[pTriggerIndex] := " "	; replace pTrigger with space (alt: "" since some labels use space)
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
    ;;;pass caret position as arguments as they are used in individual keys to check whether to call the function at all
    ; get Window position relative to cursor
    static x,y
    if (CaretGetPos(&x, &y) & (pCaret="C")) { ; Can get Caret position and Config is set
      yOffP := yOffN := 0, symOff := 16
      if (y < symOff*8) { ; if too close to the top of the screen
        yOffP := symOff*3 ; move below the cursor
      } else {
        yOffN := symOff*5 ; otherwise move above the cursor
      }
      if (BoxWDPI > (A_ScreenWidth-x)) { ; too wide to fully fit to the right of cursor
        xOffN := BoxWDPI - (A_ScreenWidth-x) ; move to the left the cursor until it fits fully
      } else {
        xOffN := symOff ; move slightly to the left of the cursor
      }
      LocLB := " x" x-xOffN " y" y+yOffP-yOffN " "
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
  if (dbg>1) {
    Tooltip("Debug: Post Picker.Show`nPicker.Title`t" Picker.Title "`npChars[1]`t" pChars[1])
    SetTimer () => ToolTip(), -1000*TTdelay
  }
  Return

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

PressH_Select(Picker, &pChars, *) { ;t * allows extra parameters sent by OnEvents
  global BS, TTdelay,TTx,TTy, SavedGUI := Picker.Submit(0) ; (0) doesn't hide the window
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
    if (dbg>0) {
      TestTooltip(SavedGUI, pChars, "ArrowHKeys", TTdelay)
    }
    Return
  }
  if InStr(AlphaHKeys, A_ThisHotkey) {
    AlphaThis:="AlphaThis"
    if (dbg>0) {
      MsgBox("A_ThisHK`t" A_ThisHotkey "`nKeysTimeOut`t" KeysTimeOut, "LoopArrows1", "T␣0.5")
    }
  }
  if (A_PriorHotkey!="" and InStr(AlphaHKeys, A_PriorHotkey)) {
    AlphaPrior := "AlphaPrior"
  }
  if (AlphaThis=="AlphaThis" and AlphaPrior=="AlphaPrior" and A_TimeSincePriorHotkey>=0 and A_TimeSincePriorHotkey<=800)  {
    if (dbg>0) {
      MsgBox("A_ThisHK`t" A_ThisHotkey "`nKeysTimeOut`t" KeysTimeOut, "LoopArrows2", "T0.5")
    }
    Return
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
  if (BS="BS") {
    Send('{BackSpace}' CharChoice)	;A_TimeSincePriorHotkey (add 2nd {BackSpace})
  } else {
    Send(CharChoice)
  }
  Return
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
  Return
}

/*
  F3::{
    ;Binds parameters to the function and returns a BoundFunc object.
    ;BoundFunc := Func.Bind(Parameters)
    fn := RealFn.Bind(1)
    %fn%(2)    ; Shows "1, 2"
    fn.Call(3) ; Shows "1, 3"
    RealFn(a, b) {
      MsgBox a ", " b
    }
    Return
  }
F3:: {
  if GetKeyState("Shift") {
    MsgBox "At least one Shift key is down."
  } else {
    MsgBox "Neither Shift key is down."
  }
}
*/

/*
Event      	Raised when...                       	GuiControls
DoubleClick	The control is double-clicked        	ListBox
Change     	The control's value changes.         	ListBox
Focus      	The control gains the keyboard focus.	ListBox
LoseFocus  	The control loses the keyboard focus.	ListBox
 */
; Help
;autohotkey.com/board/topic/29362-browse-a-listbox-with-arrow-keys/
;nadeausoftware.com/articles/2010/07/java_tip_systemcolors_mac_os_x_user_interface_themes
; Test
  ; F5::PressH_ChPick(ChXSymbols)
  ;Auto-Execute Section (AES) begins
    ; #Include %A_scriptDir%\gVars\var.ahk
    ; #Include %A_scriptDir%\SpecialChars-Hold.ahk 	; Diacritics+chars on key hold
    ; #Include %A_scriptDir%\SpecialChars-Hold2.ahk	; Diacritics+chars on key hold
  ; ^+VK52::Reload ;[^⇧r] VK52
  ; {
  ;   PressH_ChPick(ChXSymbols)
  ;   while (waitingState)
  ;    Sleep 100
  ;   SendInput CharChoice
  ;   Return
  ; }