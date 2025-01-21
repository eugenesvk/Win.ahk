#Requires AutoHotKey 2.1-alpha.4
#include <str>	; string helper functions
class lytTypES { ; Typographic layout
  static __new() { ; store all layers in a Map, TypES['base']['en'] would be base qwerty labels
    static k	:= keyConstant._map, lbl := keyConstant._labels ; various key name constants, gets vk code to avoid issues with another layout
     , s    	:= helperString

    static TypES   	:= Map() ; actual base and other symbol layers
    TypES.CaseSense	:= 0 ;
    ; Define layout
    ; to exclude a key from the binding map:
      ;            key	: use literal space
      ; left-most  key	: (like Q in qwerty), remove LTrim, but then make sure to align everything vertically to the first non-space char in the first row (`) as AHK trims only the same amount of spaces like in the first row
      ; right-most key	: (and avoid text editor cutting off spaces) split into multiple strings :(
      ;             ` 	: might have to add all spaces manually or replace ` after setting up a layer
    this._map         	:= TypES

    TypES['base'] := lbl ; ↓ make sure this matches labels['en'] @ constKey to avoid symbol shifts
    TypES['⎇›'] := Map('en',"
      ( Join ` LTrim
        `¹²³$‰↑§∞←→—≠
        ⎋∑€®™¥ѵіѳ′[]
        ≈§°£π₽„“”‘’
        ÷Ω×©↓ß¶−«»⁄
       )"
     ,'ru',"
      ( Join ` LTrim
        ~¹²³$‰↑&∞←→—≠
        ⎋∑€®™¥ѵіѳ′[]
        ≈§°£π₽„“”‘’
        ÷Ω×©↓ß¶−«»/
       )"
     )

      ; typographic⁄≠/ macOS / is ÷
      ; replaced ⸮ with ‹
    TypES['‹⎈⎇›'] :=TypES['⎇›']  ; for AltGr

    TypES['⇧›⎇›'] := Map('en',"
      ( Join ` LTrim
       `¡½⅓¼‱ˆ¿·‹›–±
       ˘⇥⇪˚℃ѢѴІѲ˝{}⧵
       ⌥⇧⌀℉₴⌘✓√λ¨'
       ¸✗¢ˇẞ˜•<>´
       )"
     ,'ru',"
      ( Join ` LTrim
       `¡½⅓¼‱ˆ¿·‹›–±
       ˘⇥⇪˚℃ѢѴІѲ˝{}⧵
       ⌥⇧⌀℉₴⌘✓√λ¨'
       ¸✗¢ˇẞ˜•<>´
       )"
     ; ↓ order doesn't matter since this is matched by label match, not position
     ,'🕱',"
      ( Join ` LTrim
       `     6
        q  r
             h   ;
        z  v n   /
       )"
     )
      ;‹→⸮
      ;🙂→⧵
      ;macOS '= (Apple symbol)
      ;macOS . are „“
    ;
    TypES['‹⎈⇧›⎇›'] :=TypES['⇧›⎇›']  ; for AltGr
    TypES['☰'] := Map('en',
      "``           ="
      "{☰          \"
      "½         '"
      "⎈         "
     ,'ru',
      "``           ="
      "{☰          \"
      "½         '"
      "☰         "
     )
    TypES['‹⎈☰'] :=TypES['☰']  ; for AltGr


    ; ————— Fill helper map of labels to symbols
    keys_m           	:= Map() ; map of labels to symbols for each layer
    ,keys_m.CaseSense	:= 0 ; make key matching case insensitive
    ,pre_layers      	:= Map(   '⇧›⎇›',''     ,'⎇›',''  ,'☰','&'
                      ,'‹⎈⇧›⎇›',''  ,'‹⎈⎇›','' ) ; AltGr adds ‹⎈
    ,keys_m['en']          	:= Map()
    ,keys_m['en'].CaseSense	:= 0 ; make key matching case insensitive
    ,keys_m['ru']          	:= Map()
    ,keys_m['ru'].CaseSense	:= 0 ; make key matching case insensitive

    this._keys_m	:= keys_m
    this._pre   	:= pre_layers

    bir_labels_en	:= TypES['base']['en']
    bir_labels_ru	:= TypES['base']['ru']
    dbgtxt       	:= '', dbgcount := 0
    for pre,is⅋ in pre_layers {   ; ⇧›⎇› or ⎇›
      ; dbgTT(0,pre,t:=3) ;
      ; dbgtxt .= (pre='☰') ? pre '`tpre' '`n' : ''
      keys_m['en'][pre]	:= Map()
      keys_m['ru'][pre]	:= Map()
      keys_m['en'][pre].CaseSense := 0 ; make key matching case insensitive
      keys_m['ru'][pre].CaseSense := 0

      sym_en_list 	:= TypES[pre]['en']
      sym_ru_list 	:= TypES[pre]['ru']
      sym🕱lbl_list	:= TypES[pre].Get('🕱','')
      ; dbgtxt .= 'sym🕱lbl_list ' sym🕱lbl_list '`n'
      if not StrLen(bir_labels_en) = StrLen(bir_labels_ru) {
        throw ValueError("TypES's labels lists should have the same length", -1)
      }
      loop StrLen(bir_labels_en) {
        label_en	:= SubStr(bir_labels_en,A_Index,1)
        label_ru	:= SubStr(bir_labels_ru,A_Index,1)
        if inStr(sym🕱lbl_list, label_en) { ; skip deadkeys defined in the keyboard key list above
          ; dbgtxt .= '🕱' label_en
          ; dbgtxt .= (Mod(dbgcount, 10) = 0) ? '`n' : ' ', dbgcount += 1 ; insert a newline every X keys
          continue
        } else { ;
          sym_en := SubStr(sym_en_list,A_Index,1) ; ˘
          sym_ru := SubStr(sym_ru_list,A_Index,1) ; ˘
          keys_m['en'][pre][label_en] := sym_en ; [⇧›⎇›][q] = ˘
          keys_m['ru'][pre][label_ru] := sym_ru ; [⇧›⎇›][й] = ˘
          if pre == '☰' {
            ; dbgtxt .= label_en sym_en ' '
            ; dbgtxt .= label_ru sym_ru ' '
            ; dbgtxt .= (Mod(dbgcount, 10) = 0) ? '`n' : ' ', dbgcount += 1 ; insert a newline every X keys
          }
        }
      } ; msgbox(pre '`n' bir_labels_en '`n' sym_en_list)
    }
    ; ar1 := keys_m['en']['⇧›⎇›']
    ; ar2 := keys_m['ru']['⎇›']
    ; dbgtxt2 := ar1['w'] '`t' ar2['б'] '`t' ar2['ю'] '`t' ar2['.'] '`n' bir_labels_en '`n' sym_en_list
    ; msgbox(dbgtxt2); dbgTT(0, 'constTypES`n' dbgtxt,t:=5)
  }
}
