#Requires AutoHotKey 2.1-alpha.18
#include <Locale>

OnMessage(0x404, OnTrayClickLeft)
OnTrayClickLeft(wParam, lParam, nMsg, hwnd) {
  static ‹🖰№ := 0, 🖰x := 0, 🖰y := 0
  if (lParam = 0x202) { ; WM_LBUTTONUP
    mode_mouse := A_CoordModeMouse
    mode_menu  := A_CoordModeMenu
    CoordMode("Mouse","Screen")
    MouseGetPos(&🖰x, &🖰y) ; save mouse position to show menu there even if the mouse moves during wait
    SetTimer(OnTrayClickLeftSingle, -200) ; wait ms for a second left click, then Continue
    ‹🖰№ += 1
    OnTrayClickLeftSingle() {
      if (‹🖰№ == 1) {
        ; dbgtt(0,🖰x "¦" 🖰y " mode_mouse=" mode_mouse " mode_menu=" mode_menu,5,18,0,0)
        CoordMode("Menu","Screen")
        ; A_TrayMenu.Show(🖰x, 🖰y)
        ShowMenu(🖰x, 🖰y)
      }
      ‹🖰№ := 0
    }
    CoordMode("Mouse",mode_mouse) ; restore coord
    CoordMode("Menu" ,mode_menu )
    return 1
  ; } else if (lParam = 0x203) { ; WM_LBUTTONDBLCLK
  ; } else if (lParam = 0x205) { ; WM_RBUTTONUP
  }
}
ShowMenu(x?,y?) {
  static trayMan := TrayManager()
    , lang := 'en'
  lang_cur := lyt.GetLocaleName()
  if lang != lang_cur {
    trayMan.changeLang(lang, lang_cur)
    lang  := lang_cur
  }
  trayMan.trayMenu.Show(x?,y?)
}

class TrayManager {
  __New() {
    this.trayMenu := Menu()
    ; dbgtt(0,"TrayManager New",5,5,0,0)
    this.cbRu := cbMenuLayoutSwitchTgt.bind(,,,ruU)
    this.cbEn := cbMenuLayoutSwitchTgt.bind(,,,enU)
    this.trayMenu.Add("&E → English"	, this.cbEn)
    this.trayMenu.Add("&R → Русский"	, this.cbRu)
    this.trayMenu.Add(              	)
    this.trayMenu.Add("&D → Change" 	, cbMenuLayoutSwitch)
    this.trayMenu.SetIcon("&E → English", "img\en-US.ico")
    this.trayMenu.SetIcon("&R → Русский", "img\ru-RU.ico")
  }
  changeLang(old, new) {
    if        old == "en" and new == "ru" {
      this.trayMenu.Rename("&D → Change" 	,"&В → Сменить")
      this.trayMenu.Rename("&E → English"	,"&У → English")
      this.trayMenu.Rename("&R → Русский"	,"&К → Русский")
    } else if old == "ru" and new == "en" {
      this.trayMenu.Rename("&В → Сменить"	,"&D → Change" )
      this.trayMenu.Rename("&У → English"	,"&E → English")
      this.trayMenu.Rename("&К → Русский"	,"&R → Русский")
    } else {
      dbgtt(0, "✗ Unknown layout, only 'en' and 'ru' are supported")
    }
  }
}
