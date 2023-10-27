#Requires AutoHotKey 2.1-alpha.4
; TypES Typographic Layout via ⎇› or ‹⎈⎇›AltGr
  ; [Guide](superuser.com/questions/592970/can-i-make-ctrlalt-not-act-like-altgr-on-windows)
  ; Unicode codepoints unicode-table.com
  ; >!2::SendRaw '@' or  >!2::SendInput "{Raw}@"
; #HotIf WinActive("ahk_class PX_WINDOW_CLASS") ; Or WinActive("ahk_class GxWindowClass")

global isAltGr := false ; does ⎇› emit ⎈ keycode?

#include <constTypES>	; Typographic layout list of keys

add_TypES()
add_TypES() { ; use english labels and precompute revers maps to easier match hotkey to a character to insert
  static vk             	:= keyConstant._map, vkr	:= keyConstant._mapr ; various key name constants, gets vk code to avoid issues with another layout
   , s                  	:= helperString
   , hkf                	:= keyFunc.customHotkeyFull
  vkrloc                	:= Map() ; create a local reverse matching Map to easily map hotkey back to its origin key to paste its replacement
  vkrloc.CaseSense      	:= 0 ; make key matching case insensitive
  vkrloc['en']          	:= Map()
  vkrloc['ru']          	:= Map()
  vkrloc['en'].CaseSense	:= 0
  vkrloc['ru'].CaseSense	:= 0

  TypES        	:= lytTypES._map
  keys_m       	:= lytTypES._keys_m
  pre_layers   	:= lytTypES._pre
  bir_labels_en	:= TypES['base']['en']
  bir_labels_ru	:= TypES['base']['ru']

  dbgtxt := '', dbgcount := 0
  pre	:= '⎈'
  ; msgbox(bir_labels_ru '`n' vk['ru']['ю'] ' ' hkf('',pre . 'ю',,,'ru')[1] '`n' vk['ru']['.'] ' ' hkf('',pre . '.',,,'ru')[1])
  for labels in [bir_labels_en, bir_labels_ru] {
    lng_lbl := (labels = bir_labels_ru) ? 'ru' : 'en'
    ; if not lng_lbl = 'en' {
      ; continue
    ; }
    if isAltGr and (labels = bir_labels_ru) {
      AltGr := "‹⎈"
      dbgtxt .= '`nAltGr ' AltGr '`n'
    } else {
      AltGr := ""
    }
    loop parse labels { ; ` and some others might be mapped separately to a rich tooltip in Char-AltTT
      for pre,is⅋ in pre_layers {   ; ⇧›⎇› or ⎇›
        key	:= A_LoopField	; 0
        if is⅋ = '&' { ; convert all to vk codes and connect with &
          ; try {
            ; hk := s.key→ahk(pre . key,,"&")
            ; vk_pre	:= vk[lng_lbl][pre]	; ⎈› → vkA3
          ; } catch Error as err {
            ; msgbox(pre '`t' 'pre' '`n' key '`t' 'key',"can't be found")
          ; }
          ; hk := s.key→ahk(pre . key,,"&")
          vk_pre	:= vk[pre]            	; ⎈› → vkA3
          vk_key	:= vk[lng_lbl][key]   	; vk30
          hk    	:= vk_pre " & " vk_key	; vkA3 vk30  , need VK only for appskey
          ; dbgtxt .= pre '`tpre ' vk_pre '`t`n' key '`tkey ' vk_key0
        } else {
          pre	:= AltGr . pre
          r  	:= hkf('',pre . key,,,lng_lbl)
          hk 	:= r[1] ; ahk format >!>+vk30 for ⇧›⎇›0
        }
        ; if not pre = '☰' {
          ; continue
        ; }
        if    keys_m[lng_lbl].Has(pre)
          and keys_m[lng_lbl][pre].Has(key) {   ; skip registering keys not defined in the TypES layers
          if not  keys_m[lng_lbl][pre][key] = ' ' { ; as well as those containig blanks
            dbgtxt .= hk " (" key ')'
            dbgtxt .= (Mod(dbgcount, 10) = 0) ? '`n' : ' ', dbgcount += 1 ; insert a newline every X keys
            vkrloc[lng_lbl][hk] := [pre, A_LoopField] ; map reverse keys only for registered hotkeys (allows skipping RU hotkeys if EN VK code was registered (which is the same as in RU))
            HotKey(hk, hkTypES)
          } else { ; ignore blanks
            ; dbgtxt .= pre " " key " " AltGr ' ', dbgcount += 1
          }
        } else {
          if AltGr = "" {
            ; dbgtxt .= pre " " key
            ; dbgtxt .= (Mod(dbgcount, 10) = 0) ? '`n' : ' ', dbgcount += 1 ; insert a newline every X keys
          }
        }
      }
    }
  }
  ; dbgTT(0,dbgtxt,t:=5)
  ; msgbox(dbgtxt)

  hkTypES(ThisHotkey) { ; inserts symbols based on precomputed maps of Hotkey → Symbol
    static vkrloc_en	:= vkrloc['en']
     ,     vkrloc_ru	:= vkrloc['ru']
    ; key_ru := ''
    ; key_en := ''
    ; for hk,hval in vkrloc_ru {
    ;   key_ru .= InStr(hk,'>!<^vkB') ? '|' hk '|' (hk='>!<^vkB') : '' ;
    ;   key_ru .= (Mod(A_Index, 8) = 0) ? '`n' : '`t' ; insert a newline every 8 keys¹≈⁄◆⁄
    ; }
    for hk,hval in vkrloc_en {
      key_en .= hk
    }

    lyt_enabled	:= lyt.getlist() ; system loaded that are available in the language bar
    lyt_current	:= lyt.GetCurLayout(&hDevice, &idLang)
    lytA       	:= lyt_enabled[lyt_current]
    lngShort   	:= lytA['LangShort']
    lngLong    	:= lytA['LangLong']

    if lngLong = 'Russian' {
      if not vkrloc_ru.Has(ThisHotkey) { ; some labels can be missing in Ru, but present in VK
        return
      }
      rev_arr	:= vkrloc_ru[ThisHotkey]
      pre    	:= rev_arr[1]
      key    	:= rev_arr[2]
      dbgtxt := ThisHotkey "|`n" pre "`tpre`n" key '`tkey in Ru'
      SendText(keys_m['ru'][pre][key])
    } else {
      if not vkrloc_en.Has(ThisHotkey) {
        return
      }
      rev_arr	:= vkrloc_en[ThisHotkey]
      pre    	:= rev_arr[1]
      key    	:= rev_arr[2]
      dbgtxt := ThisHotkey "|`n" pre "`tpre`n" key '`tkey in En'
      SendText(keys_m['en'][pre][key])
    } ; SendText('{Blind}' avoid releasing modifiers, might bug in some apps
    ; dbgTT(0,dbgtxt,t:=3)
  }
}

