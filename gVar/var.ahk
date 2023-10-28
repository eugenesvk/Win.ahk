#Requires AutoHotKey 2.1-alpha.4
global Keyboard 	:=["``","1","2","3","4","5","6","7","8","9","0","-","=","q","w","e","r","t","y","u","i","o","p","[","]","\","a","s","d","f","g","h","j","k","l",";","'","z","x","c","v","b","n","m",",",".","/"] ; Keyboard array q14 a27 z38
  ,    KeyboardR	:=["ё","1","2","3","4","5","6","7","8","9","0","-","=","й","ц","у","к","е","н","г","ш","щ","з","х","ъ","\","ф","ы","в","а","п","р","о","л","д","ж","э","я","ч","с","м","и","т","ь","б","ю","."] ; Keyboard array й14 ф27 я38
  ; modifiers # to the left/right of spacebar (helpful var in case the keys get physically remapped in registry to custom modifiers)
  , ‹␠1 := '‹⎈' , ‹␠2  := '‹⌥' , ‹␠3  := '‹◆'
  ,  ␠›1:=  '⎈›',  ␠›2 :=  '⌥›',  ␠›3 := '☰'
  , ⅋ := '&'
 ,ɵ1:=ɵ2:=ɵ3:=ɵ4:=ɵ5:=ɵ6:=ɵ7:=ɵ8:=0
loop 8 {
  ɵ%A_Index% := numFunc.ɵ(A_Index)
}

#include <Array>

;Custom special characters
  ;xLab - Labels, xLabR - Labels in Russian, xSp – Newline split positions
  global Ch          	:= Map()
    Ch.CaseSense     	:= 0 ; make key matching case insensitive
    Ch['QuotesS']    	:= ["‹","›","‘","’","‚","‛"]                         	;' str→arrCh() ~10 times longer
  , Ch['QuotesD']    	:= ["«","»","“","”","„"]                             	;"
  , Ch['Dash']       	:= ["−","–","—","⁃"]                                 	;- minus, en/em dash, Hyphen Bullet
  , Ch['DashLab']    	:= ["=","n","m","b"]                                 	;
  , Ch['Space']      	:= [" "," "," "," "," "," "," ","​","␣"]             	;? ¦m¦n¦r¦1¦.¦t¦h¦0¦ (Em¦En¦nbSp¦Figure¦Punctuation¦Thin¦Hair¦Zero-Width¦OpenBoxU+2423 (jkorpela.fi/chars/spaces.html))
  , Ch['SpaceLab']   	:= ["m","n"," ","1",".","t","h","0","u"]             	;¦ ¦ ¦ ¦ ¦ ¦ ¦ ¦​¦
  , Ch['Percent']    	:= ["%","‰","‱","°"]                                 	;% percentiles
  , Ch['Currency']   	:= ["₽","€","£","$","¢","¥","Ƀ"]                     	;h or Shift+4 currency
  , Ch['CurrLabN']   	:= ["1","2","3","4","5","6","7"]                     	; ... in Numbers
  , Ch['CurrLab']    	:= ["h","e","p","d","c","y","b"]                     	; Labels for Currency
  , Ch['CurrencyRu'] 	:= joinArr(Ch['Currency'],     ['£','$','¢','¥','Ƀ'])	; repeat for En mneminics with Ru symbols
  , Ch['CurrLabRu']  	:= ["р","е","ф","д","ц","й","б",'з','в','с','н','и'] 	; ... in Russian
  ;Ch['Fractions']   	:= ["½","⅓","⅔","¼","¾"]                             	;f fractions
  , Ch['Fractions']  	:= ["½","↉","⅓","⅔","¼","¾","⅕","⅖","⅗","⅘","⅙","⅚","⅐","⅛","⅜","⅝","⅞","⅑","⅒"] ;8 fractions
  , Ch['FSp']        	:= [10,12,13,17]
  , Ch['Superscript']	:= ["¹","²","³","⁴","⁵","⁶","⁷","⁸","⁹","⁰","⁻","⁺","⁼","ⁿ","ⁱ"]		;6 g superscript
  , Ch['SupLab']     	:= ["1","2","3","4","5","6","7","8","9","0","-","+","=","n","i"]	; Labels for Superscripts
  , Ch['SupSp']      	:= [13,16]
  , Ch['Subscript']  	:= ["₁","₂","₃","₄","₅","₆","₇","₈","₉","₀","₋","₊","₌","ₑ","ₒ","ₜ","ₚ","ₐ","ₛ","ₕ","ₖ","ₗ","ₓ","ₙ","ₘ"]		;7 v subscript
  , Ch['SubLab']     	:= ["1","2","3","4","5","6","7","8","9","0","-","+","=","e","o","t","p","a","s","h","k","l","x","n","m"]	; Labels for Subscripts
  , Ch['SubSp']      	:= [13,17,22]
  ;t math
  ; global Ch['Math']   	:= ["¬","∩","∪","∴","∵","∎","∞","×","−","±","≈","   ","√","∃","∀","π","∑","∂","∫","÷"]
  ; global Ch['MathLab']	:= ["1","2","3","4","5","6","8","*","-","+","=","   ","q","e","a","g","s","d","i","/"]
  , Ch['MathS']         	:= ["¬","θ","⇑","⇓","∗","⊂","⊃","⌈","⌉","⇒","ℚ","Ω","∃","ℝ","∴","Ψ","∪","∩","Θ","Π","⌊","⌋","∀","Σ","Δ","Φ","Γ","Λ"] ; tshorter Math ending with 1-0a-s to fit on screen for Press&Hold
  , Ch['Math']          	:= ["¬","√","θ","⇑","⇓","∞", "∗","⊂","⊃","⌈","⌉","≝","⇒","ℚ","Ω","∃","ℝ","∴","Ψ","∪","∩","Θ","Π","⌊","⌋","∀","Σ","Δ","Φ","Γ","H","J","K","Λ","∈","｜","ℤ","Ξ","×","ℂ","∇","∨","∵","ℕ","M","〈","〉","·","÷"]
  , Ch['MathLab']       	:= ["``","2","3","6","7","8","*","9","0","(",")","-","=","q","w","e","r","t","y","u","i","o","p","[","]", "a","s","d","f","g","h","j","k","l",";","'", "z","x","X","c","v","V","b","n","m","<",">",".","/"]
  , Ch['MathLabRu']     	:= ["``","2","3","6","7","8","*","9","0","(",")","-","=","й","ц","у","к","е","н","г","ш","щ","з","х","ъ", "ф","ы","в","а","п","р","о","л","д","ж","э", "я","ч","Ч","с","м","М","и","т","ь","Б","Ю","ю","."]
  , Ch['MathSp']        	:= [13,25,36]
  ;y math2
  , Ch['Math2']     	:= ["ω","ε","ρ","θ","ψ","υ","π","α","σ","d","f","γ","η","κ","λ","…","ζ","ξ","χ","√","β","ν","μ","…","÷"]
  , Ch['Math2Lab']  	:= ["w","e","r","t","y","u","p","a","s","d","f","g","h","k","l",";","z","x","c","v","b","n","m",".","/"]
  , Ch['Math2LabRu']	:= ["ц","у","к","е","н","г","з","ф","ы","в","а","п","р","л","д","ж","я","ч","с","м","и","т","ь","ю","."]
  , Ch['Math2Sp']   	:= [7,16]
  ;q OS symbols
  , Ch['XSymbols']   	:= ["⌫","␣","⌦","⏏","⇞","⇟","⌽","⎋","⇥","⭾","⇤","⇪","⇧","⌃","⌥","⌘","❖","⏎","↩","⌤","⤒","⤓"] ;old⇱⇲
  , Ch['XSymbolsLab']	:= ["1", " " ,"2" ,"3" ,"4" ,"5","8","x","f","t", "b", "c","s","^","a","m","w","r","n","u","h","e"]
  , Ch['XSymSp']     	:= [7,14]
  ;a Arrows
  , Ch['Arrows']     	:= ["←","↑","→","↓","⟵","￪","⟶","￬","⇠","⇡","⇢","⇣","↖","↗","↘","↙","▶","◀","🡙"] ;a
  , Ch['ArrowsLab']  	:= ["a", "w" ,"d" ,"s" ,"j" ,"i","l" ,"k","1" ,"2" ,"3" ,"4" ,"5" ,"6" ,"7" ,"8" ,"9" ,"0", "x"]
  , Ch['ArrowsLabRu']	:= ["ф","ц","в","ы","о","ш","д","л","1","2","3","4","5","6","7","8","9","0"]
  , Ch['ArrowsSp']   	:= [4,8,12,16]
  ; others
  , Ch['Checks']     	:= ["℃","℉","©","✓","✗","°","¯","¨","′","″","‶"]            	;r ′prime ″dbl, ‶rev dlb, ℃ 1char
  , Ch['ChecksLab']  	:= ["c","f","r","y","n","d","7","8","'",'"']                	;Label for Misc
  , Ch['Para']       	:= ["~","§","†","¶","$","‡","⁋"]                            	;⇧`(~) paragraphs Dagger, Pilcrow Sign, Double Dagger, Reversed Pilcrow Sign
  , Ch['Tech']       	:= ["⏦","⎓","©","✓","✗","°","¯","¨","′","″","‶"]            	;x ⎓(U+2393) DC, ⏦(U+23E6) AC
  , Ch['TechLab']    	:= ["a","d","r","y","n","d","7","8","'",'"']                	;
  , Ch['WinFile']    	:= ["∗","∗","⧵","¦","꞉","꞉","”","“","‹","›","⁄","⸮","⸮","．"]	;d LegalReplacement
  , Ch['WinFileLab'] 	:= ["8","*","\","|",";",":","'","l","<",">","/","?","7","."]	; Illegal Filename Chars (Windows)
  , Ch['WinFile1']   	:= ["∗","⧵","¦","꞉","”","“","‹","›","⁄","⸮","⸮","．"]        	;d LegalReplacement
  , Ch['WinFileLab1']	:= ["8","\","|",";","'","l","<",">","/","?","7","."]        	; Illegal Filename Chars (Windows)
  , Ch['WinFileLab2']	:= ["*","\","|",":",'"',"'","<",">","/","?","."]            	; Illegal Filename Chars (Windows)
  , Ch['Bullet']     	:= ["•","‣","⁌","⁍","⁘","⁙","⁚","⁛","⁝","⁞","※","⁜"]        	;b Bullet, Triangular Bullet, Reference Mark, Black Leftwards Bullet, Black Rightwards Bullet, 4/5/2 Dot Punctuation, 4 Dot Mark, Dotted Cross, Tricolon, Vertical Four Dots
  , Ch['Misc']       	:= ["♪","♫","⁁","⁂","⁑","⁒","⁖"]                            	;B Caret Insertion Point, Asterism, Two Asterisks Aligned Vertically, Commercial Minus Sign, Three Dot Punctuation

setBir()
setBir() { ; Typography Layout. Lab - label‹›≤≥
  En:='', Ru:='Ru', lEn:='Lab', lRu:=lEn Ru
  global Bir     	:= Map()
    Bir.CaseSense	:= 0 ; make key matching case insensitive
    Bir['1'  En] 	:= ["``","¹","²","³","$","‰","↑","§","∞","←","→","—","≠"]
  , Bir['1'  Ru] 	:= ["~","¹","²","³","$","‰","↑","&","∞","←","→","—","≠"]
  , Bir['1s'   ] 	:= ["``","¡","½","⅓","¼","‱","ˆ","¿","·","⸮","›","–","±"] ;‹→⸮
  , Bir['1' lEn] 	:= ["``","1","2","3","4","5","6","7","8","9","0","-","="]
  , Bir['Q'  En] 	:= ["⎋","∑","€","®","™","¥","ѵ","і","ѳ","´","[","]","÷"]
  , Bir['Qs'   ] 	:= ["˘","⇥","⇪","˚","℃","Ѣ","Ѵ","І","Ѳ","˝","{","}","⧵"] ;🙂→⧵
  , Bir['Q' lEn] 	:= ["q","w","e","r","t","y","u","i","o","p","[","]","\"]
  , Bir['Q' lRu] 	:= ["й","ц","у","к","е","н","г","ш","щ","з","х","ъ","\"]
  , Bir['A'  En] 	:= ["≈","§","°","£","π","₽","„","“","”","‘","’"]
  , Bir['As_old']	:= ["⌥","⇧","⌀","℉","꞉","⌘","✓","√","λ","¨","'"] ;macOS '= (Apple symbol)
  , Bir['As'   ] 	:= ["⌥","⇧","⌀","℉","₴","⌘","✓","√","λ","¨","'"] ;macOS '= (Apple symbol)
  , Bir['A' lEn] 	:= ["a","s","d","f","g","h","j","k","l",";","'"]
  , Bir['A' lRu] 	:= ["ф","ы","в","а","п","р","о","л","д","ж","э"]
  , Bir['Z'  En] 	:= ["Ω","×","©","↓","ß","¶","−","«","»","⁄"] ;typographic⁄≠/, macOS / is ÷
  , Bir['ZRu'  ] 	:= ["Ω","×","©","↓","ß","¶","−","«","»","/"] ;Regular /slash in Russian
  , Bir['Zs'   ] 	:= ["¸","✗","¢","ˇ","ẞ","˜","•","<",">","´"] ;macOS ,. are „“
  , Bir['Z' lEn] 	:= ["z","x","c","v","b","n","m",",",".","/"]
  , Bir['Z' lRu] 	:= ["я","ч","с","м","и","т","ь","б","ю","."]
  }

;1´acute 2`grave 3ˆcircumflex 4¨diaeresis 5¯macron 6˙dot above 7˛ogonek 8˚ring above 9ˇcaron
  global Dia	:= Map( ; must be case sensitive (default) Dia.CaseSense := 1
    'Hlp'   	, " ´   `   ˆ   ¨   ¯   ˙   ˛   ˚   ˇ   ˜"
  , 'A'     	, ["Á","À","Â","Ä","Ā",        "Å",    "Ã","Æ"]
  , 'a'     	, ["á","à","â","ä","ā",        "å",    "ã","æ"]
  , 'C'     	, ["Ç","Ć","Č"]
  , 'c'     	, ["ç","ć","č"]
  , 'E'     	, ["É","È","Ê","Ë","Ē","Ė","Ę"]
  , 'e'     	, ["é","è","ê","ë","ē","ė","ę"]
  , 'I'     	, ["Í","Ì","Î","Ï","Ī"    ,"Į"]
  , 'i'     	, ["í","ì","î","ï","ī"    ,"į"]
  , 'L'     	, ["Ł"]
  , 'l'     	, ["ł"]
  , 'N'     	, ["Ń",                                "Ñ"]
  , 'n'     	, ["ń",                                "ñ"]
  , 'O'     	, ["Ó","Ò","Ô","Ö","Ō",                "Õ","Œ","Ø"]
  , 'o'     	, ["ó","ò","ô","ö","ō",                "õ","œ","ø"]
  , 'S'     	, ["Ś","ß",                        "Š"]
  , 's'     	, ["ś","ß",                        "š"]
  , 'U'     	, ["Ú","Ù","Û","Ü","Ū"]
  , 'u'     	, ["ú","ù","û","ü","ū"]
  , 'Y'     	, [            "Ÿ"]
  , 'y'     	, [            "ÿ"]
  , 'Z'     	, ["Ź",                "Ż",        "Ž"]
  , 'z'     	, ["ź",                "ż",        "ž"]
  , 'aLabX' 	, ["x","b","3","4","5","6","7","8"]
  ; Char-Alt	replacement strings
  , '´'     	, "áéíóú"  	;´ acute
  , '``'    	, "àèìòù"  	;` grave
  , 'ˆ'     	, "âêîôû"  	;ˆ circumflex
  , '¨'     	, "äëïöüÿ" 	;¨ diaeresisumlaut
  , '¯'     	, "āēī"    	;¯ macron
  , '~'     	, "ãõñ"    	;~ tilde
  , 'oth'   	, "åėįøłšż"	;  others
  , '´U'    	, "ÁÉÍÓÚ"
  , '``U'   	, "ÀÈÌÒÙ"
  , 'ˆU'    	, "ÂÊÎÔÛ"
  , '¨U'    	, "ÄËÏÖÜŸ"
  , '¯U'    	, "ĀĒĪ"
  , '~U'    	, "ÃÕÑ"
  , 'othU'  	, "ÅĖØŠ"
  , 'oall'  	, "aæ eę iį oœ lł   sß  zż  1å 3ė 5ø 7š `nAÆ EĘ IĮ OŒ LŁ Sẞ ZŻ 2Å 4Ė 6Ø 8Š"
  )
;Window management
  global Monitor_DefaultToNearest	:= 0x00000002
  ;List of styles https://www.autoitscript.com/autoit3/docs/appendix/GUIStyles.htm
    , WS_Border       	:= 0x00800000 ; a thin-line border
    , WS_DlgFrame     	:= 0x00400000 ; border of a style typically used with dialog boxes
    ; , WS_Caption    	:= WS_Border|WS_DlgFrame
    , WS_Caption      	:= 0x00C00000 ; Title bar (WS_BORDER + WS_DLGFRAME)
    , WS_SizeBox      	:= 0x00040000 ; Sizing border (=WS_THICKFRAME)
    , WS_Borderless   	:= WS_Caption|WS_SizeBox ; BitwiseOR (logical inclusive OR)
    , WS_Visible      	:= 0x10000000
    , WS_MaxBox       	:= 0x10000
    , WS_Min          	:= 0x20000000
    , WS_MaxBox       	:= 0x00010000 ; maximize button. Cannot be combined with the WS_EX_CONTEXTHELP style. The WS_SYSMENU style must also be specified.
    , WS_SysMenu      	:= 0x00080000	; a window menu on its title bar. The WS_CAPTION style must also be specified
    ;                 	; system default values
    , smFullscreen_Xpx	:= 16 ; Width and height of the client area for a full-screen window on the primary display monitor, in pixels.
    , smFullscreen_Ypx	:= 17
    , smWinMax_Xpx    	:= 61 ; Default dimensions, in pixels, of a maximized top-level window on the primary display monitor
    , smWinMax_Ypx    	:= 62
    , smMaxTrack_Xpx  	:= 59 ; Default maximum dimensions of a window that has a caption and sizing borders, in pixels. This metric refers to the entire desktop. The user cannot drag the window frame to a size larger than these dimensions
    , smMaxTrack_Ypx  	:= 60
    , smBorder_Xpx    	:= 5 ; Width and height of a window border, in pixels. This is equivalent to the SM_CXEDGE value for windows with the 3-D look
    , smBorder_Ypx    	:= 6 ;
    , smFrameFixed_Xpx	:= 7 ; (synonymous with SM_CXDLGFRAME, SM_CYDLGFRAME): Thickness of the frame around the perimeter of a window that has a caption but is not sizable, in pixels. SM_CXFIXEDFRAME is the height of the horizontal border and SM_CYFIXEDFRAME is the width of the vertical border.
    , smFrameFixed_Ypx	:= 8 ;
    , smSzFrame_Xpx   	:= 32 ; Thickness of the sizing border around the perimeter of a window that can be resized, in pixels. SM_CXSIZEFRAME is the width of the horizontal border, and SM_CYSIZEFRAME is the height of the vertical border. Synonymous with SM_CXFRAME and SM_CYFRAME
    , smSzFrame_Ypx   	:= 33 ;
    , smEdge_Xpx      	:= 45 ; Dimensions of a 3-D border, in pixels. These are the 3-D counterparts of SM_CXBORDER and SM_CYBORDER
    , smEdge_Ypx      	:= 46 ;

  global TTx          	:= 2100	; Alt ToolTip X coordinates
    , TTy             	:= 1275	;             Y coordinates
    , TTyOff          	:= -70 	;             Y offset for subsequent ToolTip
    , ListenTimerShort	:= 2   	; Remove short tooltip after 2 seconds (SpecialChars-Alt)
    , ListenTimerLong 	:= 4   	; Remove long  tooltip after 4 seconds (SpecialChars-Alt)

  global wForward	:= true 	; Needed for WinCycle function
    , wCycling   	:= false	; Needed for WinCycle function

  global ctrlEditClass := Array()  ; edit box class names
      ctrlEditClass.Push("Edit1") ; standard
    , ctrlEditClass.Push("Edit2") ; MSO creates this instead of 1 after Toolbar ops
  ; , exeScrollH.Push("Edit3") ; just in case

  global ctrlPathClassNN  := Array() ; class names for path toolbar in Save/Open dialoge
      ctrlPathClassNN.Push("ToolbarWindow323")
    , ctrlPathClassNN.Push("ToolbarWindow324")
    , ctrlPathClassNN.Push("ToolbarWindow325")
  global ctrlPathClassNNA := Array() ; active ...
      ctrlPathClassNNA.Push("Edit2")
    , ctrlPathClassNNA.Push("Edit3")
  ; Sublime, Wordpad:
    ;          Inactive         Act   ahk_class
    ; Open [L] ToolbarWindow323 Edit2 #32770	[L]eft-most breadcrumb control
    ;      [R] ToolbarWindow324             	[R]ight-most dropdown menu
    ; Save [L] ToolbarWindow324 Edit2 #32770
    ;      [R] ToolbarWindow325
  ; Excel, Word:
    ; Open [L] ToolbarWindow324 Edit2 #32770
    ;      [R] ToolbarWindow325
    ; Save [L] ToolbarWindow325 Edit3 #32770
    ;      [R] ToolbarWindow326

;Font parameters for PressH_ChPick
  global CharGUIFontName	:= "Source Code ProPL"	; Font name
    , CharGUIFontSize   	:= 14                 	; Font size
    , CharGUIFontWeight 	:= 400                	; Font weight
    , CharGUIFlowDir    	:= "H"                	; Default flow direction Horizontal vs Vertical
    , CharGUIWidthColH  	:= 25                 	; Width of each column in Horizontal view
    , CharGUIWidthI     	:= 15                 	; Width of the Index pane
    , CharGUIWidthV     	:= 25                 	; Width of the Values pane
    , CharGUIFontColI   	:= "ccccccc"          	; Font color on the Index pane
    , CharGUIFontColV   	:= "c0063cd"          	; Font color on the Values pane

;GUI Constants (used in PressH_ChPick)
  global LBS_MultiColumn	:= 0x0200	;  github.com/AHK-just-me/AHK_Gui_Constants/blob/master/Sources/Const_ListBox.ahk
    , LB_SetColumnWidth 	:= 0x0195	;  github.com/AHK-just-me/AHK_Gui_Constants/blob/master/Sources/Const_ListBox.ahk
    , TimerHold         	:= "T0.4"	; Timer for Char-Hold.ahk; change to 0.4

  global tDTap	:= 200	;  ms time to wait till a second duplicate key is considered a double tap vs two separate key presses

;Windows 10 Shell Commands
  global shellFd := Map()
      shellFd['TaskView']     	:= "explorer.exe Shell:::{0DF44EAA-FF21-4412-828E-260A8728E7F1}" ;❖Tab
    , shellFd['ActionCenter'] 	:= "ms-actioncenter:" ;❖A
    , shellFd['CortanaSpeech']	:= "?" ;❖C
    , shellFd['Desktop']      	:= "explorer.exe Shell:::{00021400-0000-0000-C000-000000000046}" ;❖D
    , shellFd['Explorer']     	:= "explorer.exe Shell:::{20D04FE0-3AEA-1069-A2D8-08002B30309D}" ;❖E thisPC
    , shellFd['GameBar']      	:= "?" ;❖G
    , shellFd['Share']        	:= "?" ;❖H
    , shellFd['Settings']     	:= "ms-settings:" ;❖I
    , shellFd['Connect']      	:= "ms-settings-connectabledevices:devicediscovery" ;❖K
    ;, shellFd['Lock']        	:= "LockWorkStation" ;❖L
    , shellFd['Project']      	:= "ms-settings-displays-topology:projection" ;❖P
    , shellFd['Run']          	:= "explorer.exe Shell:::{2559a1f3-21d7-11d4-bdaf-00c04f60b9f0}" ;❖r
    , shellFd['Cortana']      	:= "ms-cortana:" ;❖S
    , shellFd['PowerUser']    	:= "explorer.exe " ;❖X
    ;, ms-projection:
    , shellFd['QuickAccess']	:= "explorer.exe shell:::{679F85CB-0220-4080-B29B-5540CC05AAB6}" ; File Explorer Folder: Quick access

; shellFd['Run'] := "explorer.exe " ;❖
; https://g-ek.com/clsid-guid-spisok-shell-v-windows-10
; http://ipmnet.ru/~sadilina/Windows/227.html
; security
; Explorer.exe Shell:::{2559a1f2-21d7-11d4-bdaf-00c04f60b9f0}
; system
; Explorer.exe Shell:::{BB06C0E4-D293-4f75-8A90-CB05B6477EEE}
; Start Menu
; Explorer.exe Shell:::{48e7caab-b918-4e58-a94d-505519c795dc}
; Explorer.exe Shell:::{04731B67-D933-450a-90E6-4ACD2E9408FE}
; https://www.askvg.com/tip-how-to-disable-all-win-keyboard-shortcuts-hotkeys-in-windows/

;WinAPI functions and constants
  ;Faster performance by looking up the function's address beforehand (lexikos.github.io/v2/docs/commands/DllCall.htm)
global getDefIMEWnd := DllCall("GetProcAddress", "Ptr",DllCall("GetModuleHandle", "Str","Imm32", "Ptr"), "AStr","ImmGetDefaultIMEWnd", "Ptr") ; HWND ImmGetDefaultIMEWnd(HWND Arg1) docs.microsoft.com/en-us/windows/win32/api/imm/nf-imm-immgetdefaultimewnd. Invoke: DllCall(getDefIMEWnd, "Ptr",fgWin)
  , CreateProcessW_proc := DllCall("GetProcAddress", "Ptr",DllCall("GetModuleHandle", "Str","kernel32", "Ptr"), "AStr","CreateProcessW", "Ptr") ; docs.microsoft.com/en-us/windows/win32/api/processthreadsapi/nf-processthreadsapi-createprocessw
  , QPerfC_proc := DllCall("GetProcAddress", "Ptr",DllCall("GetModuleHandle", "Str","kernel32", "Ptr"), "AStr","QueryPerformanceCounter", "Ptr") ; docs.microsoft.com/en-us/windows/win32/api/profileapi/nf-profileapi-queryperformancecounter
  , changeInputLang	:= 0x50  	; WM_INPUTLANGCHANGEREQUEST
  , msgWheelH      	:= 0x20E 	; WM_MOUSEHWHEEL, docs.microsoft.com/en-us/windows/win32/inputdev/wm-mousehwheel
  , msgScrollH     	:= 0x0114	; WM_HSCROLL (=scrollbar button press, by line very slow, by page fast, might need to be sent to the control, not just the window), docs.microsoft.com/en-us/windows/win32/controls/wm-hscroll
  , msgScrollV     	:= 0x0115	; WM_VSCROLL, docs.microsoft.com/en-us/windows/win32/controls/wm-vscroll
  , WheelDelta     	:= 120   	; WHEEL_DELTA threshold for action to be taken, and one such action (for example, scrolling one increment) should occur for each delta
  , scroll←Ln      	:= 0     	; SB_LINELEFT ; by one unit = click ←
  , scroll←Pg      	:= 2     	; SB_PAGELEFT ; by window's width = click on the scroll bar
  , scroll→Ln      	:= 1     	; SB_LINERIGHT
  , scroll→Pg      	:= 3     	; SB_PAGERIGHT
  , scroll↑Ln      	:= 0     	; SB_LINEUP
  , scroll↑Pg      	:= 2     	; SB_PAGEUP
  , scroll↓Ln      	:= 1     	; SB_LINEDOWN
  , scroll↓Pg      	:= 3     	; SB_PAGEDOWN
  , scroll↑        	:= 6     	; SB_TOP
  , scroll↓        	:= 7     	; SB_BOTTOM
  , scroll←        	:= 6     	; SB_LEFT; upper left
  , scroll→        	:= 7     	; SB_RIGHT; lower right
  , kbControl      	:= 0x0008	; MK_CONTROL;  CTRL   key          is down
  , kbShift        	:= 0x0004	; MK_SHIFT;    SHIFT  key          is down
  , mbL            	:= 0x0001	; MK_LBUTTON;  left   mouse button is down
  , mbM            	:= 0x0010	; MK_MBUTTON;  middle mouse button is down
  , mbR            	:= 0x0002	; MK_RBUTTON;  right  mouse button is down
  , mbX1           	:= 0x0020	; MK_XBUTTON1; first  X     button is down
  , mbX2           	:= 0x0040	; MK_XBUTTON2; second X     button is down
  , msgSelect      	:= 0x00B1	; EM_SETSEL; set text selection
  , bytes⁄char     	:= 2
  , →              	:=  1
  , ←              	:= -1
  , ↑              	:=  2
  , ↓              	:= -2

