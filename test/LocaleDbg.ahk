#Requires AutoHotKey 2.1-alpha.4
LocaleDbg() {
  enU	:= DllCall("LoadKeyboardLayout"	, "str","00000409"	, "uint",1)
  ruU	:= DllCall("LoadKeyboardLayout"	, "str","00000419"	, "uint",1)
  static locInf := localeInfo.m  ; Constants Used in the LCType Parameter of lyt.getLocaleInfo, lyt.getLocaleInfoEx, and SetLocaleInfo learn.microsoft.com/en-us/windows/win32/intl/locale-information-constants
   , kbdCountry	:= "sEnCountryNm"	;
   , kbdDisplay	:= "sEnDisplayNm"	;
  ; SendInput '{LWin Down}{Space}{LWin Up}'
  global enU,ruU
  local curlayout := lyt.GetCurLayout(&lytPhys, &idLang)
  local targetWin := "A" ; Active window to PostMessage to, need to be changed for '#32770' class (dialog window)

    SizeT   	:= 2
  sLng    	:= lyt.getLocaleInfo('en'           	,idLang)
  sLngLong	:= lyt.getLocaleInfo('English'      	,idLang)
  sCtr    	:= lyt.getLocaleInfo('United States'	,idLang)
  sLngLoc 	:= lyt.getLocaleInfo('Deutsch'      	,idLang)
  iC      	:= lyt.getLocaleInfo("IDialingCode" 	,idLang)
  klID    	:= lyt.getKLIDfromHKL(curlayout)
  ToolTip(""
  . "klID`t"    	klID                                     	"`n" ; 00000409
  . "Layout`t"  	format("0x{1:X}",curlayout) "=" curlayout	"`n" ; 0x4090409
  . " lytPhys`t"	format("0x{1:X}",lytPhys)                	"`n" ; 0x409
  . " idLang`t" 	format("0x{1:X}",idLang)   "=" idLang    	"`n" ; 0x409
  ; . "en`t"    	format("0x{1:X}",en)                     	"`n"
  . "enU`t"     	format("0x{1:X}",enU)                    	"`n" ; 0x4090409
  ; . "ru`t"    	format("0x{1:X}",ru)                     	"`n"
  . "ruU`t"     	format("0x{1:X}",ruU)                    	"`n" ; 0x4190419
  . "sLng`t"    	sLng                                     	"`n" ; en
  . "sLngLong`t"	sLngLong                                 	"`n" ; English
  . "sCountry`t"	sCtr                                     	"`n" ; United States
  . "sLngLoc`t" 	sLngLoc                                  	"`n" ; Deutsch
  . "sDial#`t"  	iC                                       	"`n" ; 1
  , 2050,900)
  SetTimer () => ToolTip(), -2000
  }

/*
Ctrl::{ ;lexikos.github.io/v2/docs/misc/Languages.htm - list of locale codes
  if (A_PriorHotKey = A_ThisHotKey
    and A_TimeSincePriorHotkey < 500) {
    if (GetCurLayout() = enU) {
      PostMessage(0x50, 0, ruU,, "A")
    } else {
      PostMessage(0x50, 0, enU,, "A")
    }
  }
}
*/
