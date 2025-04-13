#Requires AutoHotKey 2.1-alpha.18
#include <Locale>

OnMessage(0x404, OnTrayClickRight)
OnTrayClickRight(wParam, lParam, nMsg, hwnd) {
  if (lParam = 0x205) { ; WM_RBUTTONUP
    ShowMenuRight()
    return 1
  }
}
ShowMenuRight() {
  static trayMan := TrayManagerRight()
    , lang := 'en'
  lang_cur := lyt.GetLocaleName()
  if lang != lang_cur {
    trayMan.changeLang(lang, lang_cur)
    lang  := lang_cur
  }
  A_TrayMenu.Show()
}

class TrayManagerRight {
  __New() {
    ; Add language change
    this.cbEn := cbMenuLayoutSwitchTgt.bind(,,,enU)
    this.cbRu := cbMenuLayoutSwitchTgt.bind(,,,ruU)
    A_TrayMenu.Insert("&Suspend Hotkeys"	, "&D → English"	, this.cbEn)
    A_TrayMenu.Insert("&Suspend Hotkeys"	, "&F → Русский"	, this.cbRu)
    A_TrayMenu.Insert("&Suspend Hotkeys"	, "&G → Change" 	,cbMenuLayoutSwitch)
    A_TrayMenu.Insert("&Suspend Hotkeys"	, ""            	,)
    A_TrayMenu.SetIcon("&D → English"   	, "img\en-US.ico")
    A_TrayMenu.SetIcon("&F → Русский"   	, "img\ru-RU.ico")

    ; Rename defaults to make accelerator key more prominent
    A_TrayMenu.Rename("&Suspend Hotkeys"	, "&S Suspend Hotkeys")
    A_TrayMenu.Rename("&Window Spy"     	, "&W Window Spy")
    A_TrayMenu.Rename("&Reload Script"  	, "&R Reload Script")
    A_TrayMenu.Rename("&Edit Script"    	, "&E Edit Script")
    A_TrayMenu.Rename("E&xit"           	, "&Q Quit")
    A_TrayMenu.Rename("&Pause Script"   	, "&P Pause Script")
    A_TrayMenu.Rename("&Open"           	, "&O Open")
    A_TrayMenu.Rename("&Help"           	, "&H Help")
  }
  changeLang(old, new) {
    if        old == "en" and new == "ru" {
      A_TrayMenu.Rename("&D → English"	,"&В → English")
      A_TrayMenu.Rename("&F → Русский"	,"&А → Русский")
      A_TrayMenu.Rename("&G → Change" 	,"&П → Сменить")
    } else if old == "ru" and new == "en" {
      A_TrayMenu.Rename("&В → English"	,"&D → English")
      A_TrayMenu.Rename("&А → Русский"	,"&F → Русский")
      A_TrayMenu.Rename("&П → Сменить"	,"&G → Change" )
    } else {
      dbgtt(0, "✗ Unknown layout, only 'en' and 'ru' are supported")
    }
  }
}
