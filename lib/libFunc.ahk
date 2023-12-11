#Requires AutoHotKey 2.0.10

#include <libFunc Native>	; Functions: Native
#include <constKey>      	; various key constants
#include <str>           	; string helper functions

preciseTΔ(n:=3) {
  static start := nativeFunc.GetSystemTimePreciseAsFileTime()
  t := round(nativeFunc.GetSystemTimePreciseAsFileTime() - start,n)
  return t
}

perfT() { ; QueryPerformanceCounter learn.microsoft.com/en-us/windows/win32/api/profileapi/nf-profileapi-queryperformancecounter
  static count0	:= 0
   , frequency 	:= nativeFunc.QueryPerformanceFrequency()
  return DllCall(QPerfC_proc,"Int64*",&count1:=0)
    ? ((count1 - count0) / frequency * 1000) + ((count0 := count1) & 0)
    : (count0 := 0)
}

class keyFunc {
  static __new() { ; get all vars and store their values in this .Varname as well ‘m’ map, and add aliases

    this.hkSend := hkSend
    static hkSend(  keyNm, s) { ; closure allows registering hotkeys with variables in the target, so great for loops of similar keys
      fnSend(       keyNm   ) { ; closure due to a free variable S in the outer function that is used here. Can share vars with the outer function even after the outer function returns
        Send(s) ;, dbgTT(0,s)
      }
      Hotkey(keyNm, fnSend)
    }
    this.hkSendI := hkSendI
    static hkSendI(keyNm, s) {
      fnSendI(     keyNm   ) { ; closure due to a free variable S in the outer function that is used here. Can share vars with the outer function even after the outer function returns
        SendInput(s) ;, dbgTT(0,s)
      }
      Hotkey(keyNm, fnSendI)
    }

    this.hkSendC := hkSendC
    static hkSendC(keyNm, s) {
      fnSendC(     keyNm   ) { ; closure due to a free variable S in the outer function that is used here. Can share vars with the outer function even after the outer function returns
        ControlSend(s,,'A') ;, dbgTT(0,s)
      }
      Hotkey(keyNm, fnSendC)
    }

    this.customHotkey := customHotkey
    static customHotkey(key_combo) {
      customHotkeyFull("",key_combo,"")
    }

    this.customHotkeyFull := customHotkeyFull
    static customHotkeyFull(pre:='',key_combo:='',pos:='',kT:='vk',lng:='en') {
      if not key_combo{
        throw ValueError("customHotkeyFull: ‘key_combo’ should not be blank", -1)
      }
      is⅋ := false
      static s := helperString
       , vk := keyConstant._map, sc := keyConstant._mapsc  ; various key name constants, gets vk code to avoid issues with another layout

      str_replace := Map(A_Space,"", A_Tab,"") ; remove whitespace and allow & in function names
      for from,to in str_replace {
        key_combo := StrReplace(key_combo,from,to)
      }

      sep⅋      	:= ''
      ,sep⅋Fn   	:= ''
      ,pre_combo	:= ''
      if InStr(key_combo, "&") { ; ☰&x
        customCombo_arr	:= StrSplit(key_combo, "&")
        sep⅋           	:= " & "
        sep⅋Fn         	:= "⅋"
        if not customCombo_arr.Length = 2 {
          throw ValueError('At most one & should be present in ‘' . key_combo . '’', -1)
        } else {
          pre_combo	:= customCombo_arr[1] ; ☰
          key_combo	:= customCombo_arr[2] ; x
        }
        is⅋ := true
      }

      vkpre := pre_combo = "" ? "" : vk[pre_combo]
      key_combo_FNm	:= 'hk' . pre_combo . sep⅋Fn . s.replace_illegal_id(key_combo)
      key_combo_ahk	:= s.key→ahk(key_combo, kT,,lng)
      key_combo_out := pre . vkpre . sep⅋ . key_combo_ahk . pos
      ; dbgtxt := key_combo_out '`t' 'key_combo_out' '`n' key_combo_FNm '`t' 'key_combo_FNm'
      ; dbgTT(0,dbgtxt, t:=5)
      ; key_combo  	⇧5
      ; mod_ahk_str	 +5
      ; nonmod     	  5
      return [key_combo_out, key_combo_FNm]
    }
  }
}
; ————————————————————————— Functions —————————————————————————
IsFunc(FunctionName){
  try {
    return %FunctionName%.MinParams+1
  } catch {
    return 0
  }
  return
}
