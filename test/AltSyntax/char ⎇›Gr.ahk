#Requires AutoHotKey 2.0.10
;#SingleInstance force
;#InstallKeybdHook
;#UseHook
; #HotIf WinActive("ahk_class PX_WINDOW_CLASS") ; Or WinActive("ahk_class GxWindowClass")
; TypES Typographic Layout via Right Alt, alternatively AltGr<^>! [Guide](https://superuser.com/questions/592970/can-i-make-ctrlalt-not-act-like-altgr-on-windows)
; Variables set in gVars
; Unicode codepoints https://unicode-table.com
  ; <^>!2::SendRaw '@' or  <^>!2::SendInput "{Raw}@"

add_TypES() {
; Numbers ⌥
  <^>!vkC0::{ ;[⌥`] vkC0 ⟶ [` / ~Ru] name (U+0060 / U+007E)
    global ruU
    if (GetCurLayout() = ruU) {
      SendInput Bir["1R"][1]
    } else {
      SendInput Bir["1"][1]
    }
    }
  <^>!vk31::	SendInput Bir["1"][2]	;[⌥1] vk31 ⟶ [¹] Superscript One  	(U+00B9)
  <^>!vk32::	SendInput Bir["1"][3]	;[⌥2] vk32 ⟶ [²] Superscript Two  	(U+00B2)
  <^>!vk33::	SendInput Bir["1"][4]	;[⌥3] vk33 ⟶ [³] Superscript Three	(U+00B3)
  <^>!vk34::	SendInput Bir["1"][5]	;[⌥4] vk34 ⟶ [$] Dollar           	(U+0024)
  <^>!vk35::	SendInput Bir["1"][6]	;[⌥5] vk35 ⟶ [‰] Per Mille        	(U+2030)
  <^>!vk36::	SendInput Bir["1"][7]	;[⌥6] vk36 ⟶ [↑] Upwards Arrow    	(U+2191)
  <^>!vk37::{  ;[⌥7] vk37 ⟶ [§/&Ru] name (U+)
    global ruU
    if (GetCurLayout() = ruU) {
      SendInput Bir["1R"][8]
    } else {
      SendInput Bir["1"][8]
    }
    }
  ; <^>!vk37::	SendInput Bir["1"][8]	;[⌥7] vk37 ⟶ [§] name	(U+)

  <^>!vk38::	SendInput Bir["1"][9] 	;[⌥8] vk38 ⟶ [∞] name	(U+)
  <^>!vk39::	SendInput Bir["1"][10]	;[⌥9] vk39 ⟶ [←] name	(U+)
  <^>!vk30::	SendInput Bir["1"][11]	;[⌥0] vk30 ⟶ [→] name	(U+)
  <^>!vkBD::	SendInput Bir["1"][12]	;[⌥-] vkBD ⟶ [—] name	(U+)
  <^>!vkBB::	SendInput Bir["1"][13]	;[⌥=] vkBB ⟶ [≠] name	(U+)
; Number ⌥⇧
  ; <^>!+vkC0::	SendInput Bir["1s"][1] 	;[⇧⌥`] vkC0 ⟶ [`] Grave Accent                 	(U+0060) ;DeadKey in TypES Layout
  ; <^>!+vkC0::	SendInput '{U+0300}'     	;[⇧⌥`] vkC0 ⟶ [ ̀] Combining Grave Accent      	(U+0300) ;DeadKey in TypES Layout
  <^>!+vk31::  	SendInput Bir["1s"][2] 	;[⇧⌥1] vk31 ⟶ [¡] Inverted Exclamation Mark    	(U+00A1)
  <^>!+vk32::  	SendInput Bir["1s"][3] 	;[⇧⌥2] vk32 ⟶ [½] Vulgar One Half              	(U+00BD)
  <^>!+vk33::  	SendInput Bir["1s"][4] 	;[⇧⌥3] vk33 ⟶ [⅓] Vulgar One Third             	(U+2153)
  <^>!+vk34::  	SendInput Bir["1s"][5] 	;[⇧⌥4] vk34 ⟶ [¼] Vulgar One Quarter           	(U+00BC)
  <^>!+vk35::  	SendInput Bir["1s"][6] 	;[⇧⌥5] vk35 ⟶ [‱] Per Ten Thousand             	(U+2031)
  ; <^>!+vk36::	SendInput Bir["1s"][7] 	;[⇧⌥6] vk36 ⟶ [ˆ] Mod Circumflex Accent        	(U+02C6) ;DeadKey in TypES Layout
  ; <^>!+vk36::	SendInput '{U+0302}'     	;[⇧⌥6] vk36 ⟶ [ ̂̂] Combining Circumflex Accent		(U+0302) ;DeadKey in TypES Layout
  <^>!+vk37::  	SendInput Bir["1s"][8] 	;[⇧⌥7] vk37 ⟶ [¿] Inverted Question Mark       	(U+00BF)
  <^>!+vk38::  	SendInput Bir["1s"][9] 	;[⇧⌥8] vk38 ⟶ [·] Middle Dot/interpunct        	(U+00B7)
  ; <^>!+vk39::	SendInput Bir["1s"][10]	;[⇧⌥9] vk39 ⟶ [〈] FILLER                       	(U+) ;FILLER
  <^>!+vk39::  	SendInput Bir["1s"][10]	;[⇧⌥9] vk39 ⟶ [⸮] Reversed Question Mark       	(U+2E2E)
  <^>!+vk30::  	SendInput Bir["1s"][11]	;[⇧⌥0] vk30 ⟶ [〉] FILLER                       	(U+) ;FILLER
  <^>!+vkBD::  	SendInput Bir["1s"][12]	;[⇧⌥-] vkBD ⟶ [–] name                         	(U+)
  <^>!+vkBB::  	SendInput Bir["1s"][13]	;[⇧⌥=] vkBB ⟶ [±] name                         	(U+)

; Letters: Top Row Q⌥
  <^>!vk51::  	SendInput Bir["Q"][1] 	;[⌥q] vk51 ⟶ [⎋] Escape              	(U+238B)
  <^>!vk57::  	SendInput Bir["Q"][2] 	;[⌥w] vk57 ⟶ [∑] Summation           	(U+2211)
  <^>!vk45::  	SendInput Bir["Q"][3] 	;[⌥e] vk45 ⟶ [€] Euro                	(U+20AC)
  <^>!vk52::  	SendInput Bir["Q"][4] 	;[⌥r] vk52 ⟶ [®] Registered          	(U+00AE)
  <^>!vk54::  	SendInput Bir["Q"][5] 	;[⌥t] vk54 ⟶ [™] Trade Mark          	(U+2122)
  <^>!vk59::  	SendInput Bir["Q"][6] 	;[⌥y] vk59 ⟶ [¥] Yen                 	(U+00A5)
  <^>!vk55::  	SendInput Bir["Q"][7] 	;[⌥u] vk55 ⟶ [ѵ] CyrSmall Izhitsa    	(U+0475)
  <^>!vk49::  	SendInput Bir["Q"][8] 	;[⌥i] vk49 ⟶ [і] CyrSmall Bel-Ukr I  	(U+0456)
  <^>!vk4F::  	SendInput Bir["Q"][9] 	;[⌥o] vk4F ⟶ [ѳ] CyrSmall Fita       	(U+0473)
  ; <^>!vk50::	SendInput Bir["Q"][10]	;[⌥p] vk50 ⟶ [´] Acute Accent        	(U+00B4)
  <^>!vk50::  	SendInput '{U+00B4}'  	;[⌥p] vk50 ⟶ [´] Acute Accent        	(U+00B4) ;Bir["Q"][10] acts as Combining
  <^>!vkDB::  	SendInput Bir["Q"][11]	;[⌥[] vkDB ⟶ [[] Left Square Bracket 	(U+005B)
  <^>!vkDD::  	SendInput Bir["Q"][12]	;[⌥]] vkDD ⟶ []] Right Square Bracket	(U+005D)
  <^>!vkDC::  	SendInput Bir["Q"][13]	;[⌥\] vkDC ⟶ [÷] Division            	(U+00F7)
; Letters: Top Row Q⌥⇧
  ; <^>!+vk51::	SendInput Bir["Qs"][1] 	;[⇧⌥q] vk51 ⟶ [˘] Breve                   	(U+02D8) ;DeadKey in TypES Layout
  ; <^>!+vk51::	SendInput '{U+0306}'   	;[⇧⌥q] vk51 ⟶ [ ̆] Combining Breve        		(U+0306) ;DeadKey in TypES Layout
  <^>!+vk57::  	SendInput Bir["Qs"][2] 	;[⇧⌥w] vk57 ⟶ [⇥] Rightwards Arrow To Bar 	(U+21E5)
  <^>!+vk45::  	SendInput Bir["Qs"][3] 	;[⇧⌥e] vk45 ⟶ [⇪] Caps Lock               	(U+21EA)
  ; <^>!+vk52::	SendInput Bir["Qs"][4] 	;[⇧⌥r] vk52 ⟶ [˚] Ring Above              	(U+02DA) ;DeadKey in TypES Layout
  ; <^>!+vk52::	SendInput '{U+030A}'   	;[⇧⌥r] vk52 ⟶ [ ̊] Combining Ring Above   		(U+030A) ;DeadKey in TypES Layout
  <^>!+vk54::  	SendInput Bir["Qs"][5] 	;[⇧⌥t] vk54 ⟶ [℃] Degree Celsius          	(U+2103)
  <^>!+vk59::  	SendInput Bir["Qs"][6] 	;[⇧⌥y] vk59 ⟶ [Ѣ] CyrCap Yat              	(U+0462)
  <^>!+vk55::  	SendInput Bir["Qs"][7] 	;[⇧⌥u] vk55 ⟶ [Ѵ] CyrCap Izhitsa          	(U+0474)
  <^>!+vk49::  	SendInput Bir["Qs"][8] 	;[⇧⌥i] vk49 ⟶ [І] CyrCap Bel-Ukr I        	(U+0406)
  <^>!+vk4F::  	SendInput Bir["Qs"][9] 	;[⇧⌥o] vk4F ⟶ [Ѳ] CyrCap Fita             	(U+0472)
  <^>!+vk50::  	SendInput Bir["Qs"][10]	;[⇧⌥p] vk50 ⟶ [˝] Double Acute Accent     	(U+02DD)
  <^>!+vkDB::  	SendInput Bir["Qs"][11]	;[⇧⌥[] vkDB ⟶ [{] Left Curly Bracket      	(U+007B)
  ; <^>!+vkDB::	SendInput '{U+007B}'   	;[⇧⌥[] vkDB ⟶ [{] Left Curly Bracket      	(U+007B)
  <^>!+vkDD::  	SendInput Bir["Qs"][12]	;[⇧⌥]] vkDD ⟶ [}] Right Curly Bracket     	(U+007D)
  ; <^>!+vkDD::	SendInput '{U+007D}'   	;[⇧⌥]] vkDD ⟶ [}] Right Curly Bracket     	(U+007D)
  <^>!+vkDC::  	SendInput Bir["Qs"][13]	;[⇧⌥\] vkDC ⟶ [⧵] Reverse Solidus Operator		(U+29F5)

; Letters: Second Row A⌥
  <^>!vk41::	SendInput Bir["A"][1] 	;[⌥a] vk41 ⟶ [≈] Almost Equal To            	(U+2248)
  <^>!vk53::	SendInput Bir["A"][2] 	;[⌥s] vk53 ⟶ [§] Section                    	(U+00A7)
  <^>!vk44::	SendInput Bir["A"][3] 	;[⌥d] vk44 ⟶ [°] Degree                     	(U+00B0)
  <^>!vk46::	SendInput Bir["A"][4] 	;[⌥f] vk46 ⟶ [£] Pound                      	(U+00A3)
  <^>!vk47::	SendInput Bir["A"][5] 	;[⌥g] vk47 ⟶ [π] Greek Small Letter Pi      	(U+03C0)
  <^>!vk48::	SendInput Bir["A"][6] 	;[⌥h] vk48 ⟶ [₽] Ruble                      	(U+20BD)
  <^>!vk4A::	SendInput Bir["A"][7] 	;[⌥j] vk4A ⟶ [„] Double Low-9 Quotation Mark	(U+201E)
  <^>!vk4B::	SendInput Bir["A"][8] 	;[⌥k] vk4B ⟶ [“] Left double quote          	(U+201C)
  <^>!vk4C::	SendInput Bir["A"][9] 	;[⌥l] vk4C ⟶ [”] Right double quote         	(U+201D)
  <^>!vkBA::	SendInput Bir["A"][10]	;[⌥;] vkBA ⟶ [‘] Left single quote          	(U+2018)
  <^>!vkDE::	SendInput Bir["A"][11]	;[⌥'] vkDE ⟶ [’] Right single quote         	(U+2019)

; Letters: Second Row A⌥⇧
  <^>!+vk41::  	SendInput Bir["As"][1] 	;[⇧⌥a] vk41 ⟶ [⌥] Option Key              	(U+2325)
  <^>!+vk53::  	SendInput Bir["As"][2] 	;[⇧⌥s] vk53 ⟶ [⇧] Upwards White Arrow     	(U+21E7)
  <^>!+vk44::  	SendInput Bir["As"][3] 	;[⇧⌥d] vk44 ⟶ [⌀] Diameter                	(U+2300)
  <^>!+vk46::  	SendInput Bir["As"][4] 	;[⇧⌥f] vk46 ⟶ [℉] Degree Fahrenheit       	(U+2109)
  ; <^>!+vk47::	SendInput Bir["As"][5] 	;[⇧⌥g] vk47 ⟶ [₴] Hryvnia                 		(U+20B4)
  <^>!+vk47::  	SendInput Bir["As"][5] 	;[⇧⌥g] vk47 ⟶ [꞉] Modifier Letter Colon   		(U+A789)
  ; <^>!+vk48::	SendInput Bir["As"][6] 	;[⇧⌥h] vk48 ⟶ [⌘] Place of Interest       	(U+2318) ;DeadKey in TypES Layout
  <^>!+vk4A::  	SendInput Bir["As"][7] 	;[⇧⌥j] vk4A ⟶ [✓] Check Mark/tick         	(U+2713)
  <^>!+vk4B::  	SendInput Bir["As"][8] 	;[⇧⌥k] vk4B ⟶ [√] Square Root/radical     	(U+221A)
  <^>!+vk4C::  	SendInput Bir["As"][9] 	;[⇧⌥l] vk4C ⟶ [λ] Greek Small Letter Lamda	(U+03BB)
  ; <^>!+vkBA::	SendInput Bir["As"][10]	;[⇧⌥;] vkBA ⟶ [¨] Diaeresis               	(U+00A8) ;DeadKey in TypES Layout
  ; <^>!+vkBA::	SendInput '{U+0308}'   	;[⇧⌥;] vkBA ⟶ [ ̈] Combining Diaeresis    		(U+0308) ;DeadKey in TypES Layout
  <^>!+vkDE::  	SendInput Bir["As"][11]	;[⇧⌥'] vkDE ⟶ ['] Apostrophe              	(U+0027)
  ; <^>!+vkDE::	SendInput Bir["As"][11]	;[⇧⌥'] vkDE ⟶ [”] Right double quote      	(U+201D)

; Letters: Third Row Z r⌥Gr
  <^>!vk5A::  	SendInput Bir["Z"][1] 	;[⌥z] vk5A ⟶ [Ω] GreekCap Omega          	(U+03A9)
  <^>!vk58::  	SendInput Bir["Z"][2] 	;[⌥x] vk58 ⟶ [×] Multiplication          	(U+00D7)
  <^>!vk43::  	SendInput Bir["Z"][3] 	;[⌥c] vk43 ⟶ [©] Copyright               	(U+00A9)
  <^>!vk56::  	SendInput Bir["Z"][4] 	;[⌥v] vk56 ⟶ [↓] Downwards Arrow         	(U+2193)
  <^>!vk42::  	SendInput Bir["Z"][5] 	;[⌥b] vk42 ⟶ [ß] LatinSmall Sharp S      	(U+00DF)
  <^>!vk4E::  	SendInput Bir["Z"][6] 	;[⌥n] vk4E ⟶ [¶] Pilcrow/paragraph       	(U+00B6)
  <^>!vk4D::  	SendInput Bir["Z"][7] 	;[⌥m] vk4D ⟶ [−] Minus                   	(U+2212)
  <^>!vkBC::  	SendInput Bir["Z"][8] 	;[⌥,] vkBC ⟶ [«] Left double-angle quote 	(U+00AB)
  <^>!vkBE::  	SendInput Bir["Z"][9] 	;[⌥.] vkBE ⟶ [»] Right double-angle quote	(U+00BB)
  <^>!vkBF::  	SendInput Bir["Z"][10]	;[⌥/] vkBF ⟶ [⁄] Fraction Slash          	(U+2044)
  ; <^>!vkBF::	SendInput Bir["Z"][10]	;[⌥/] vkBF ⟶ [⧸] Big Solidus             	(U+29F8)
  ; <^>!vkBF::	SendInput Bir["Z"][10]	;[⌥/] vkBF ⟶ [/] Slash/Solidus           	(U+002F) ; For Russian layout consistency
  ; <^>!vkBF:: ;[⌥/] vkBF ⟶ [⁄ or /Ru] Typographic (Fraction Slash)/Regular Solidus (U+2044 / U+002F)
  ; global ruU
  ;	if (GetCurLayout() = ruU) {
  ;		SendInput Bir["ZR"][10]
  ;	} else {
  ;		SendInput Bir["Z"][10]
  ;	}
  ;Return

; Letters: Third Row Z⌥⇧
  ; <^>!+vk5A::	SendInput Bir["Zs"][1] 	;[⇧⌥z] vk5A ⟶ [¸] Cedilla                	(U+00B8) ;DeadKey in TypES Layout
  ; <^>!+vk5A::	SendInput '{U+0327}'   	;[⇧⌥z] vk5A ⟶ [ ̧] Combining Cedilla     	(U+0327) ;DeadKey in TypES Layout
  <^>!+vk58::  	SendInput Bir["Zs"][2] 	;[⇧⌥x] vk58 ⟶ [✗] Ballot X               	(U+2717)
  <^>!+vk43::  	SendInput Bir["Zs"][3] 	;[⇧⌥c] vk43 ⟶ [¢] Cent                   	(U+00A2)
  ; <^>!+vk56::	SendInput Bir["Zs"][4] 	;[⇧⌥v] vk56 ⟶ [ˇ] Caron                  	(U+02C7) ;DeadKey in TypES Layout, acts as Combining
  ; <^>!+vk56::	SendInput '{U+030C}'   	;[⇧⌥v] vk56 ⟶ [ ̌] Combining Caron       	(U+030C) ;DeadKey in TypES Layout
  <^>!+vk42::  	SendInput Bir["Zs"][5] 	;[⇧⌥b] vk42 ⟶ [ẞ] LatCap Sharp S         	(U+1E9E)
  ; <^>!+vk4E::	SendInput Bir["Zs"][6] 	;[⇧⌥n] vk4E ⟶ [˜] Small Tilde            	(U+02DC) ;DeadKey in TypES Layout
  ; <^>!+vk4E::	SendInput '{U+0303}'   	;[⇧⌥n] vk4E ⟶ [ ̃] Combining Tilde       	(U+0303) ;DeadKey in TypES Layout
  <^>!+vk4D::  	SendInput Bir["Zs"][7] 	;[⇧⌥m] vk4D ⟶ [•] Bullet                 	(U+2022)
  <^>!+vkBC::  	SendInput Bir["Zs"][8] 	;[⇧⌥,] vkBC ⟶ [<] Less-Than              	(U+003C) ;For Russian layout consistency
  <^>!+vkBE::  	SendInput Bir["Zs"][9] 	;[⇧⌥.] vkBE ⟶ [>] Greater-Than           	(U+003E) ;For Russian layout consistency
  ; <^>!+vkBF::	SendInput Bir["Zs"][10]	;[⇧⌥/] vkBF ⟶ [´] Acute Accent           	(U+00B4) ;DeadKey in TypES Layout
  ; <^>!+vkBF::	SendInput '{U+0301}'   	;[⇧⌥/] vkBF ⟶ [ ́] Combining Acute Accent	(U+0301) ;DeadKey in TypES Layout
}
