#Requires AutoHotKey 2.1-alpha.18

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
  trayMan.trayMenu.Show(x?,y?)
}

class TrayManager {
  __New() {
    this.trayMenu := Menu()
    ; dbgtt(0,"TrayManager New",5,5,0,0)
    MyCallbackRu := menuLayoutSwitchTgt.bind(,,,ruU)
    MyCallbackEn := menuLayoutSwitchTgt.bind(,,,enU)
    this.trayMenu.Add("&Д → lng"    , menuLayoutSwitch)
    this.trayMenu.Add("&L → lng"    , menuLayoutSwitch)
    this.trayMenu.Add("&R → Русский", MyCallbackRu)
    this.trayMenu.Add("&F → Русский", MyCallbackRu)
    this.trayMenu.Add("&E → English", MyCallbackEn)
    this.trayMenu.Add("&У → English", MyCallbackEn)
    this.trayMenu.Add("&В → English", MyCallbackEn)
    this.trayMenu.Add()
    this.trayMenu.SetIcon("&R → Русский", "img\lng-RU48.ico")
    this.trayMenu.SetIcon("&E → English", "img\lng-US48.ico")
  }
}
