#Requires AutoHotKey 2.1-alpha.4

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
