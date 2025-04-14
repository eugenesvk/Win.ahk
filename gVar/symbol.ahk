#Requires AutoHotKey 2.1-alpha.4
global Keyboard 	:=["``","1","2","3","4","5","6","7","8","9","0","-","="	;1–13  = 13
  ,             	    "q","w","e","r","t","y","u","i","o","p","[","]","\"	;14–26 = 13
  ,             	    "a","s","d","f","g","h","j","k","l",";","'"        	;27–37 = 11
  ,             	    "z","x","c","v","b","n","m",",",".","/"            	;38–47 = 10
  ,             	    "~","!","@","#","$","%","^","&","*","(",")","_","+"	;48–60 = 13
  ,             	    "{","}","|",":",'"',"<",">","?"                    	;61–68 =  8
  ,             	    "Q","W","E","R","T","Y","U","I","O","P"            	;69–78 = 10
  ,             	    "A","S","D","F","G","H","J","K","L"                	;79–87 =  9
  ,             	    "Z","X","C","V","B","N","M"                        	] ;88–94 =7 z11 Keyboard array q14 a27 z38
  ,    KeyboardR	:=[ "ё","1","2","3","4","5","6","7","8","9","0","-","="	;1–13  = 13
  ,             	    "й","ц","у","к","е","н","г","ш","щ","з","х","ъ","\"	;14–26 = 13
  ,             	    "ф","ы","в","а","п","р","о","л","д","ж","э"        	;27–37 = 11
  ,             	    "я","ч","с","м","и","т","ь","б","ю","."            	;38–47 = 10
  ,             	    "Ё","!",'"',"№",";","%",":","?","*","(",")","_","+"	;48–60 = 13
  ,             	    "/",","                                            	;61–62 =  2
  ,             	    "Й","Ц","У","К","Е","Н","Г","Ш","Щ","З","Х","Ъ"    	;63–74 = 12
  ,             	    "Ф","Ы","В","А","П","Р","О","Л","Д","Ж","Э"        	;75–85 = 11
  ,             	    "Я","Ч","С","М","И","Т","Ь","Б","Ю"                	] ;86–94 =9 й14 ф27 я38
  , KeyboardNoCap := Keyboard.Clone()
  , KeyboardRNoCap := KeyboardR.Clone()
  ; separate symbols since CAPS in some contexts (like GUI list) aren't separated from lower case
  ; modifiers # to the left/right of spacebar (helpful var in case the keys get physically remapped in registry to custom modifiers)
 ,ɵ1:=ɵ2:=ɵ3:=ɵ4:=ɵ5:=ɵ6:=ɵ7:=ɵ8:=0
KeyboardNoCap .Capacity := 68
KeyboardRNoCap.Capacity := 62
#include <libFunc Num>
loop 8 {
  ɵ%A_Index% := numFunc.ɵ(A_Index)
}

; Various key constants for more ergonomic input or avoiding keyboard layout issues in key definition
set_flag_global()
set_flag_global() { ; register global modifier flags
  global ___ := 0
  ;bitflags	;
    , f∗   	:=    1     	;                1 any modifiers allowed
    , f˜   	:=    2     	;             10 passthru native key
    , f＄   	:=    4     	;            100 keyboard hook on
  ;bitflags	modifier    	            left‹›right ‹›
    , f⇧›  	:=   0x001  	;    0b                  1 0x    1      1 right  shift
    , f‹⇧  	:=   0x002  	;    0b                 1  0x    2      2 left   shift
    , f⎈›  	:=   0x004  	;    0b                1   0x    4      4 right  ctrl
    , f‹⎈  	:=   0x008  	;    0b               1    0x    8      8 left   ctrl
    , f◆›  	:=   0x010  	;    0b              1     0x   10     16 right  super ❖◆ (win ⊞)
    , f‹◆  	:=   0x020  	;    0b             1      0x   20     32 left   super
    , f⎇›  	:=   0x040  	;    0b            1       0x   40     64 right  alt
    , f‹⎇  	:=   0x080  	;    0b           1        0x   80    128 left   alt
    , f👍›  	:= 0x100    	;  0b          1         0x  100    256 right  Oyayubi 親指
    , f‹👍  	:= 0x200    	;  0b         1          0x  200    512 left   Oyayubi
    , f⇧   	:=  0x0403  	;    0b        1        11 0x  403   1027 any    shift (&f‹⇧› removes non⇧ mods)
    , f⎈   	:=  0x080c  	;    0b       1       11   0x  80c   2060 any    ctrl
    , f◆   	:=  0x1030  	;    0b      1      11     0x 1030   4144 any    super
    , f⎇   	:=  0x20c0  	;    0b     1     11       0x 20c0   8384 any    alt
    , f👍   	:=0x4300    	;  0b    1    11         0x 4300  17152 any    Oyayubi
    , f‹⇧› 	:= f‹⇧|f⇧›  	;    0b                 11 0x    3      3 both   shift
    , f‹⎈› 	:= f‹⎈|f⎈›  	;    0b               11   0x    c     12 both   ctrl
    , f‹◆› 	:= f‹◆|f◆›  	;    0b             11     0x   30     48 both   super
    , f‹⎇› 	:= f‹⎇|f⎇›  	;    0b           11       0x   c0    192 both   alt
    , f‹👍› 	:= f‹👍|f👍›  	;0b         11         0x  300    768 both   Oyayubi
    , f⇪   	:=   0x08000	  ;  0b   1                0x 8000  32768 caps   lock
    , f🔢   	:= 0x10000  	;  0b  1                 0x10000  65536 num    lock
    , f⇳🔒  	:=   0x20000	  ;  0b 1                  0x20000 131072 scroll lock
    , fkana	:=   0x40000	  ;  0b1                   0x40000 262144 kana かな
    , bit‹ := f‹⇧ | f‹⎈ | f‹◆ | f‹⎇ | f‹👍
    , bit› := f⇧› | f⎈› | f◆› | f⎇› | f👍›
}
set_key_global()
set_key_global() { ; register global variables
  global ___ := 0
   , ⇧     	    	:= "Shift"	, ‹⇧      	     	:= "LShift"	, ⇧›      	     	:= "RShift"
   , ⎈ := ⌃	    	:= "Ctrl" 	, ‹⎈ := ‹⌃	     	:= "LCtrl" 	, ⎈› := ⌃›	     	:= "RCtrl"
   , ◆ := ❖	:= ⌘	:= "LWin" 	, ‹◆ := ‹❖	:= ‹⌘	:= "LWin"  	, ◆› := ❖›	:= ⌘›	:= "RWin"
   , ⎇ := ⌥	    	:= "Alt"  	, ‹⎇ := ‹⌥	     	:= "LAlt"  	, ⎇› := ⌥›	     	:= "RAlt"
   , ☰:="AppsKey"
   , ∗:='*', ˜	:='~', ＄:='$'
   , ‹␠1 := '‹⎈' , ‹␠2  := '‹⌥' , ‹␠3  := '‹◆'
   ,  ␠›1:=  '⎈›',  ␠›2 :=  '⌥›',  ␠›3 := '☰'
   , ⅋ := '&'
}
#include <Array>

;Custom special characters, use ␞ in values to signal ␤ (labels don't need to match it)
  ;xLab - Labels, xLabR - Labels in Russian, xSp – Newline split positions (or ␞)
  global Ch         	:= Map()
    Ch.CaseSense    	:= 0 ; make key matching case insensitive
    Ch["QuotesS"    	]:=["‹","›","‘","’","‚","‛"]                           	;' str→arrCh() ~10 times longer
  , Ch["QuotesD"    	]:=["«","»","“","”","„"]                               	;"
  , Ch["Dash"       	]:=["−","–","—","‒","⁃","­"]                           	;- minus, en/em dash, Figure Dash, Hyphen Bullet, Soft Hyphen
  , Ch["DashLab"    	]:=["=","n","m","f","b","s"]                           	;
  , Ch["Space"      	]:=[" "," "," "," "," "," "," "," ","​","␣"]           	;⎈›⎇›␠⬓ ¦m¦n¦r¦1¦.¦t¦h¦0¦ (Em¦En¦nbSp¦Figure¦Punctuation¦Thin¦Hair¦Zero-Width¦OpenBoxU+2423 (jkorpela.fi/chars/spaces.html))
  , Ch["SpaceLab"   	]:=["m","n"," ","1","f",".","t","h","0","u"]           	;¦ ¦ ¦ ¦ ¦ ¦ ¦ ¦​¦    [    ]
  , Ch["SpaceLab2"  	]:=["m","n","b","1","f",".","t","h","0","u"]           	;
  , Ch["Percent"    	]:=["%","‰","‱","°"]                                   	;% percentiles
  , Ch["Currency"   	]:=["₽","€","£","$","¢","¥","Ƀ"]                       	;h or Shift+4 currency
  , Ch["CurrLabN"   	]:=["1","2","3","4","5","6","7"]                       	; ... in Numbers
  , Ch["CurrLab"    	]:=["h","e","p","d","c","y","b"]                       	; Labels for Currency
  , Ch["CurrencyRu" 	]:=joinArr(Ch["Currency"],     ['£','$','¢','¥','Ƀ'])  	; repeat for En mneminics with Ru symbols
  , Ch["CurrLabRu"  	]:=["р","е","ф","д","ц","й","б",'з','в','с','н','и']   	; ... in Russian
  ;Ch["Fractions"]  	:= ["½","⅓","⅔","¼","¾"]                               	;f fractions
  , Ch["Fractions"  	]:=["½","↉","⅓","⅔","¼","¾","⅕","⅖","⅗","⅘"            	,␞
    ,               	    "⅙","⅚"                                            	,␞
    ,               	    "⅐"                                                	,␞
    ,               	    "⅛","⅜","⅝","⅞"                                    	,␞
    ,               	    "⅑","⅒"                                            	] ;8 fractions
  , Ch["Superscript"	]:=["¹","²","³","⁴","⁵","⁶","⁷","⁸","⁹","⁰","⁻","⁺","⁼"	,␞
    ,               	    "ⁿ","ⁱ"                                            	] ;6 g superscript
  , Ch["SupLab"     	]:=["1","2","3","4","5","6","7","8","9","0","-","+","="	,␞
    ,               	    "n","i"                                            	] ; Labels for Superscripts
  , Ch["Subscript"  	]:=["₁","₂","₃","₄","₅","₆","₇","₈","₉","₀","₋","₊","₌"	,␞
    ,               	    "ₑ","ₒ","ₜ","ₚ","ₐ"                                	,␞
    ,               	    "ₛ","ₕ","ₖ","ₗ"                                    	,␞
    ,               	    "ₓ","ₙ","ₘ"                                        	] ;7 v subscript
  , Ch["SubLab"     	]:=["1","2","3","4","5","6","7","8","9","0","-","+","="	,␞
    ,               	    "e","o","t","p","a"                                	,␞
    ,               	    "s","h","k","l"                                    	,␞
    ,               	    "x","n","m"                                        	] ; Labels for Subscripts
  ;t math
  ; global Ch["Math"]   	:= ["¬","∩","∪","∴","∵","∎","∞","×","−","±","≈","   ","√","∃","∀","π","∑","∂","∫","÷"]
  ; global Ch["MathLab"]	:= ["1","2","3","4","5","6","8","*","-","+","=","   ","q","e","a","g","s","d","i","/"]
  , Ch["MathS"          	]:=["¬","θ" ,"⇑","⇓","∗","⊂","⊃","⌈","⌉"                	,"⇒","ℚ","Ω","∃","ℝ","∴","Ψ","∪","∩","Θ","Π","⌊","⌋","∀","Σ","Δ","Φ","Γ","Λ"] ; tshorter Math ending with 1-0a-s to fit on screen for Press&Hold
  , Ch["Math"           	]:=["¬","√" ,"θ","⇑","⇓","∞","∗","⊂","⊃","⌈","⌉","≝","⇒"	,␞
    ,                   	    "ℚ","Ω","∃","ℝ","∴","Ψ","∪","∩","Θ","Π","⌊","⌋"     	,␞
    ,                   	    "∀","Σ","Δ","Φ","Γ","H","J","K","Λ","∈","｜"         	,␞
    ,                   	    "ℤ","Ξ","ℂ","∇","∵","ℕ","⋅","·","÷"                 	,␞
    ,                   	    "≤","≥","×","∨","〈","〉"                             	]
  , Ch["MathLab"        	]:=["``","2","3","6","7","8","*","9","0","(",")","-","="	;
    ,                   	    "q","w","e","r","t","y","u","i","o","p","[","]"     	;
    ,                   	    "a","s","d","f","g","h","j","k","l",";","'"         	;
    ,                   	    "z","x","c","v","b","n","m",".","/"                 	;
    ,                   	    "_","+","X","V","<",">"                             	]
  , Ch["MathLabRu"      	]:=["``","2","3","6","7","8","*","9","0","(",")","-","="	;
    ,                   	    "й","ц","у","к","е","н","г","ш","щ","з","х","ъ"     	;
    ,                   	    "ф","ы","в","а","п","р","о","л","д","ж","э"         	;
    ,                   	    "я","ч","с","м","и","т","ь","ю","."                 	;
    ,                   	    "_","+","Ч","М","Б","Ю"                             	]
  ;⌥⇧y math2
  , Ch["Math2"       	]:=["ω","ε","ρ","θ","ψ","υ","π"                 	,␞
    ,                	    "α","σ","d","f","γ","η","κ","λ"             	,␞
    ,                	    "…","ζ","ξ","χ","√","β","ν","μ","…","÷"     	]
  , Ch["Math2Lab"    	]:=["w","e","r","t","y","u","p"                 	;
    ,                	    "a","s","d","f","g","h","k","l"             	;
    ,                	    ";","z","x","c","v","b","n","m",".","/"     	]
  , Ch["Math2LabRu"  	]:=["ц","у","к","е","н","г","з"                 	;
    ,                	    "ф","ы","в","а","п","р","л","д"             	;
    ,                	    "ж","я","ч","с","м","и","т","ь","ю","."     	]
  , Ch["XSymbols"    	]:=["⌫","␣","⌦","⏏","⌂","⌽","⎋"                 	,␞ ;
    ,                	    "⭾","⇤","⇥","⇞","⇟","⇪","⇧"                 	,␞
    ,                	    "⌃","⌥","⌘","❖","⏎","↩","⌤","⤒","⤓","⇱","⇲" 	] ;q OS symbols
  , Ch["XSymbolsLab" 	]:=["1" ," " ,"2"  ,"3" ,"f","8","x"            	;
    ,                	    "t","l" ,";","j","k","c","s"                	;
    ,                	    "^" ,"a","m","w","r","n","u","h","e","o","p"	] ;
  , Ch["Arrows"]     	:= ["↓","↑","←" ,"→"   ,␞ ;w
    ,                	    "￬","￪","⟵","⟶",␞
    ,                	    "⇣","⇡","⇠" ,"⇢" ,␞
    ,                	    "↖","↗","↙","↘" ,␞
    ,                	    "▼","▲","◀","▶"   ,␞
    ,                	    "🠿","🠽","🠼","🠾"  ,␞
    ,                	             "🢔","🢖"   ,␞
    ,                	    "↕"     ,"↔"
    ,                	    "🡙"     ,"🡘"]
  , Ch["ArrowsLab"]  	:= ["a","s","d","f"
    ,                	    "q","w","e","r"
    ,                	    "z","x","c","v"
    ,                	    "1","3","7","9"
    ,                	    "j","k","l",";"
    ,                	    "m",",",".","/"
    ,                	            "o","p"
    ,                	    "["     ,"]"
    ,                	    "-"     ,"="]
  , Ch["ArrowsLabRu"]	:= ["ф","ы","в","а"
    ,                	    "й","ц","у","к"
    ,                	    "я","ч","с","м"
    ,                	    "1","3","7","9"
    ,                	    "о","л","д","ж"
    ,                	    "ь","б","ю","."
    ,                	            "щ","з"
    ,                	    "х"     ,"ъ"
    ,                	    "-"     ,"="]
  ; others
  ,Ch["Checks"     	]:=["℃","℉","°"                                        	,␞
    ,              	    "©","✓","✗"                                        	,␞
    ,              	    "¯","¨","¨"                                        	,␞
    ,              	    "′","″","‴","⁗","‵","‶","‷","ʹ","ʺ"                	] ;r ′prime ″dbl, ‶rev dlb, ℃ 1char ʹmodiprime to replace ь in romanization
  ,Ch["ChecksLab"  	]:=["c","f","d"                                        	;
    ,              	    "r","y","n"                                        	;
    ,              	    "7","8","u"                                        	;
    ,              	    ";","'","\","/",":",'"',"|","[","]"                	] ;Label for Misc
  ,Ch["Para"       	]:=["~","§","†","¶","$","‡","⁋"                        	] ;⇧`(~) paragraphs Dagger, Pilcrow Sign, Double Dagger, Reversed Pilcrow Sign
  ,Ch["Tech"       	]:=["⏦","⎓","©","✓","✗","⤫","°","⟲","⟳","🔄"            	;
  ,                	    "🖱","🖰","🖮","☸","⬓","¯","¨","′","″","‶"]           	;x ⎓(U+2393) DC, ⏦(U+23E6) AC
  ,Ch["TechLab"    	]:=["a","d","r","y" ,"n","c","d","9" ,"0","-"          	;
  ,                	    "m","n","j","w","k","7","8","'",'"']               	;
  ,Ch["WinFile"    	]:=["∗","∗"                                            	,␞
    ,              	   "꞉","꞉","“","”","⧵","¦"                             	,␞
    ,              	   "‹","›","⁄","⸮","⸮","．"                             	] ;d LegalReplacement
  ,Ch["WinFileLab" 	]:=["8","*"                                            	;
    ,              	   ";",":","l","'","\","|"                             	;
    ,              	   "<",">","/","?","7","."                             	] ; Illegal Filename Chars (Windows)
  ,Ch["WinFile1"   	]:=["∗","⧵","¦","꞉","”","“","‹","›","⁄","⸮","⸮","．"    	] ;d LegalReplacement
  ,Ch["WinFileLab1"	]:=["8","\","|",";","'","l","<",">","/","?","7","."    	] ; Illegal Filename Chars (Windows)
  ,Ch["WinFileLab2"	]:=["*","\","|",":",'"',"'","<",">","/","?","."        	] ; Illegal Filename Chars (Windows)
  ,Ch["Bullet"     	]:=["•","‣","⁌","⁍"                                    	,␞
    ,              	    "⁘","⁙","⁚","⁛"                                    	,␞
    ,              	    "⁝","⁞","※","⁜"                                    	] ;b Bullet, Triangular Bullet, Reference Mark, Black Leftwards Bullet, Black Rightwards Bullet, 4/5/2 Dot Punctuation, 4 Dot Mark, Dotted Cross, Tricolon, Vertical Four Dots
  ,Ch["Misc"       	]:=["♪","♫"                                            	,␞
    ,              	    "⁁","‸","⎀"                                        	,␞
    ,              	    "⁂","⁑","⁒","⁖"]                                   	;B Caret Insertion Point, Asterism, Two Asterisks Aligned Vertically, Commercial Minus Sign, Three Dot Punctuation
  ,Ch["MacEn"      	]:=["¡","™","£","¢","∞","§","¶","•","ª","º","–","≠"    	,␞
    ,              	    "œ","∑","´","®","†","¥","¨","ˆ","ø","π","“","‘"    	,␞
    ,              	    "å","ß","∂","ƒ","©","˙","∆","˚","¬","…","æ","«"    	,␞
    ,              	    "Ω","≈","ç","√","∫","˜","µ","≤","≥","÷"            	]
  ,Ch["MacRu"      	]:=["§","!","@","#","$","©","^","&","₽","(",")","–","≠"	,␞
    ,              	    "ј","џ","ў","ќ","†","њ","ѓ","ѕ","'","‘","“","«"    	,␞
    ,              	    "d","z","ћ","÷","…","•","∆","љ","l","«","є","\"    	,␞
    ,              	    "ђ","x","c","v","і","ƒ","m","≤","≥","ї"            	]

setBir()
setBir() { ; Typography Layout. Lab - label‹›≤≥
  En:='', Ru:='Ru', El:='Lab', Rl:='LabRu'
  global Bir     	:= Map()
    Bir.CaseSense	:= 0 ; make key matching case insensitive
    Bir['1'  En  	]:=["``","¹","²","³","$","‰","↑","§","∞","←","→","—","≠"]
  , Bir['1'  Ru  	]:=["~","¹","²","³","$","‰","↑","&","∞","←","→","—","≠"]
  , Bir['1s'     	]:=["``","¡","½","⅓","¼","‱","ˆ","¿","·","⸮","›","–","±"] ;‹→⸮
  , Bir['1'  El  	]:=["``","1","2","3","4","5","6","7","8","9","0","-","="]
  , Bir['Q'  En  	]:=["⎋","∑","€","®","™","¥","ѵ","і","ѳ","´","[","]","÷"]
  , Bir['Qs'     	]:=["˘","⇥","⇪","˚","℃","Ѣ","Ѵ","І","Ѳ","˝","{","}","⧵"] ;🙂→⧵
  , Bir['Q'  El  	]:=["q","w","e","r","t","y","u","i","o","p","[","]","\"]
  , Bir['Q'  Rl  	]:=["й","ц","у","к","е","н","г","ш","щ","з","х","ъ","\"]
  , Bir['A'  En  	]:=["≈","§","°","£","π","₽","„","“","”","‘","’"]
  , Bir['As_old' 	]:=["⌥","⇧","⌀","℉","꞉","⌘","✓","√","λ","¨","'"] ;macOS '= (Apple symbol)
  , Bir['As'     	]:=["⌥","⇧","⌀","℉","₴","⌘","✓","√","λ","¨","'"] ;macOS '= (Apple symbol)
  , Bir['A'  El  	]:=["a","s","d","f","g","h","j","k","l",";","'"]
  , Bir['A'  Rl  	]:=["ф","ы","в","а","п","р","о","л","д","ж","э"]
  , Bir['Z'  En  	]:=["Ω","×","©","↓","ß","¶","−","«","»","⁄"] ;typographic⁄≠/, macOS / is ÷
  , Bir['ZRu'    	]:=["Ω","×","©","↓","ß","¶","−","«","»","/"] ;Regular /slash in Russian
  , Bir['Zs'     	]:=["¸","✗","¢","ˇ","ẞ","˜","•","<",">","´"] ;macOS ,. are „“
  , Bir['Z'  El  	]:=["z","x","c","v","b","n","m",",",".","/"]
  , Bir['Z'  Rl  	]:=["я","ч","с","м","и","т","ь","б","ю","."]
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
  , '¨'     	, "äëïöüÿ" 	;¨ diaeresis umlaut
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
