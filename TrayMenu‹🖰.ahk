#Requires AutoHotKey 2.1-alpha.18
#include <Locale>

; Language-independent &Accelerators by renaming menu items before each Show
  ; is there a better way? autohotkey.com/boards/viewtopic.php?f=82&t=136663
; Separate single and double click action

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
    this.trayMenu.Add("&D → English"	, this.cbEn)
    this.trayMenu.Add("&F → Русский"	, this.cbRu)
    this.trayMenu.Add(              	)
    this.trayMenu.Add("&G → Change" 	, cbMenuLayoutSwitch)
    this.trayMenu.SetIcon("&D → English", "img\en-US.ico")
    this.trayMenu.SetIcon("&F → Русский", "img\ru-RU.ico")
  }
  changeLang(old, new) {
    if        old == "en" and new == "ru" {
      this.trayMenu.Rename("&D → English"	,"&В → English")
      this.trayMenu.Rename("&F → Русский"	,"&А → Русский")
      this.trayMenu.Rename("&G → Change" 	,"&П → Сменить")
    } else if old == "ru" and new == "en" {
      this.trayMenu.Rename("&В → English"	,"&D → English")
      this.trayMenu.Rename("&А → Русский"	,"&F → Русский")
      this.trayMenu.Rename("&П → Сменить"	,"&G → Change" )
    } else {
      dbgtt(0, "✗ Unknown layout, only 'en' and 'ru' are supported")
    }
  }
}
