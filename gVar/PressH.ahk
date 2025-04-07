#Requires AutoHotKey 2.0.10
;Font parameters for PressH_ChPick
global CharGUIFontName	:= "Source Code ProPL"	; Font name
  , CharGUIFontSize   	:= 14                 	; ≝14    	Font size
  , CharGUIFontWeight 	:= 400                	; ≝400   	Font weight
  , CharGUIFlowDir    	:= "H"                	; ≝H¦V   	Flow direction: Horizontal vs Vertical
  , CharGUIWMinColH   	:= 12                 	; ≝ 5    	Min Width of each column in Horizontal view (it shrinks on large lists to fit, but not below this)
  , CharGUIWidthColH  	:= 25                 	; ≝25    	Width of each column in Horizontal view
  , CharGUIWidthI     	:= 15                 	; ≝15    	Width of the Index  pane
  , CharGUIWidthV     	:= 25                 	; ≝25    	Width of the Values pane
  , CharGUIFontColI   	:= "cccccc"           	; ≝cccccc	Font color on the Index pane
  , CharGUIFontColV   	:= "0063cd"           	; ≝0063cd	Font color on the Values pane

;GUI Constants (used in PressH_ChPick)
global LBS_MultiColumn	:= 0x0200	;≝0x0200 github.com/AHK-just-me/AHK_Gui_Constants/blob/master/Sources/Const_ListBox.ahk
  , LB_SetColumnWidth 	:= 0x0195	;≝0x0195 github.com/AHK-just-me/AHK_Gui_Constants/blob/master/Sources/Const_ListBox.ahk
  , TimerHold         	:= "T0.4"	;≝"T0.4" Timer for Char-Hold.ahk
