#Requires AutoHotKey 2.1-alpha.18

get_help(gTheme:="light") { ; Show a listview with all the registered hk🛈 hotkeys and their help🛈
  static is_init := false
   , chU	:= keyFunc.keyCharNameU
   , _d 	:= 0
  guiM := Gui()
  guiOptChrome := "-Caption -Border -Resize -SysMenu"
  guiM := Gui("+MinSize800x480 +DPIResize " guiOptChrome, t:="Registered Hotkeys")
  ; MaximizeBox: Enables the maximize button in the title bar. This is also included as part of Resize below.
  ; MinimizeBox (present by default): Enables the minimize button in the title bar.
  guiM.BackColor := (gTheme = "Dark") ? "3E3E3E" : ""
  guiM.MarginX := 0
  guiM.MarginY := 0

  guiM.SetFont("s10", "Segoe UI")
  gap_top := 0
  leftmost	:= "XM+2" ;px
  topmost 	:= "YM+" gap_top ;px
  ED_Opt  	:= leftmost " " topmost " w400" ((gTheme = "Dark") ? " cD9D9D9 Background5B5B5B" : "")
  ED := guiM.AddEdit(ED_Opt)
  ED.OnEvent("Change", LV_Search)
  EM_SETCUEBANNER(ED, "Search…", 1)

  gap_el := 0

  static sys := helperSystem
  dpi🖥️	:= sys.getDPI🖥️(), dpi🖥️x:=dpi🖥️[1], dpi🖥️y:=dpi🖥️[2]	; 1) monitor dpi
  dpi_f := dpi🖥️x / 96 ; 1.5

  guiM.SetFont("s10", "Segoe UI")
  LV_Header	:= ["⇧","⎈","◆","⎇","K⃣","🅃", "AHK⃣", "H", "🔣", "Names","File", "l№"]
  LV_Opt   	:= leftmost " y+" gap_el " w" A_ScreenWidth/dpi_f " r20" ((gTheme = "Dark") ? " cD9D9D9 Background5B5B5B" : "")
  LV       	:= guiM.AddListView(LV_Opt, LV_Header)
  LV.Opt("-Redraw")
  LV.OnEvent("DoubleClick", cbLV_DoubleClick)  ; Notify the script whenever the user double clicks a row
  for ahkey, help_map in help_keys { ; Add data
    if not is_init { ;
      if help_map.Has('🔣') {
        _ch := ''
        Loop Parse, help_map['🔣'] {
          ; dbgtt(0,A_LoopField,1)
          if (_chi := chU(A_LoopField)) {
            for repl in ['Latin ','Small ','Letter ','With '] {
              _chi := StrReplace(_chi,repl,'')
            }
            _ch .= _chi . ' ¦ '
          }
        }
        help_map['🔣name'] := StrLen(_ch) . " " . _ch
      }
    }

    LV.Add(, help_map["⇧"],help_map["⎈"],help_map["◆"],help_map["⎇"],
      help_map["c"],
     (help_map.Has("t")?help_map["t"]:""),
      ahkey, help_map["h"],
     (help_map.Has("🔣")?help_map["🔣"]:""),
     (help_map.Has("🔣name")?help_map["🔣name"]:""),
      help_map["f"], help_map["l№"])
  }
  if not is_init {
    is_init := true
  }
  ; LV.ModifyCol(2, "Integer")  ; for sorting purposes, indicate that column 2 is an integer
  ; todo: fails autosize, still get …
  loop LV.GetCount("Col") {
    if A_Index <= 4 or A_Index = 10 {
      continue
    }
    LV.ModifyCol(A_Index, "AutoHdr") ; auto-size column to fit max(contents, header text)
  }
  LV.ModifyCol(1,23) ;fits ‹⎈› without …
  LV.ModifyCol(2,29) ;     ‹⎈›
  LV.ModifyCol(3,29) ;     ‹◆›
  LV.ModifyCol(4,31) ;     ‹⎇›
  LV.ModifyCol(10,30) ; too huge of a field


  guiM.OnEvent("Escape", (*) => guiM.Hide())
  guiM.OnEvent("Size"  , cbGuiSize)
  ; guiM.OnEvent("Close", (*) => ExitApp)
  guiM.Show("AutoSize x0 y0") ; Display the window
  HideFocusBorder(guiM.Hwnd)
  LV.Opt("+Redraw")

  OnMessage(WM_KEYDOWN:=0x100, KeyDown)
  KeyDown(wParam, lParam, nmsg, hwnd) {
    static VK_UP	:= 0x26
     , VK_DOWN  	:= 0x28
     , vkF      	:= GetKeyVK('F')
     , vkS      	:= GetKeyVK('S')
    ; SoundBeep(0, 10) ; Suppress the beep
    if !(  wParam = vkF
        || wParam = vkS) {
      ; if !GetKeyState('Ctrl', "P") { ; limit to ⎈s ⎈f
      ; dbgtt(0,ControlGetFocus("A") " ¦ " ED.HWND, 5,, 0,120)
      return
    ; } else if (ControlGetFocus() = ED.HWND) { ; flashes on subsequent shows, for some reason can't find "A"
      ; dbgtt(0,"already active", 5,, 0,220)
      ; return
    } else if !(ControlGetFocus() = ED.HWND) {
      ControlFocus(ED)
    }
    ; ControlFocus(ED)
  }
  if   (VerCompare(A_OSVersion, "10.0.17763") >= 0) && (gTheme = "Dark") {
    DWMWA_USE_IMMERSIVE_DARK_MODE := 19
    if (VerCompare(A_OSVersion, "10.0.18985") >= 0) {
      DWMWA_USE_IMMERSIVE_DARK_MODE := 20
    }
    DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", guiM.hWnd, "Int", DWMWA_USE_IMMERSIVE_DARK_MODE, "int*", true, "Int", 4)
    SetExplorerTheme(LV.hWnd, "DarkMode_Explorer")
  } else {
    SetExplorerTheme(LV.hWnd)
  }

  ; Window Events
  cbGuiSize(thisGui, MinMax, Width, Height) {
    if (MinMax = -1) {
      return
    }
    ED.Move(, , Width - 4             )
    LV.Move(, , Width - 2, Height - gap_top - 30 - gap_el - 0)
    LV.Redraw()
  }

  cbLV_DoubleClick(LV, RowNumber) { ; todo: open file/line number
    RowText := LV.GetText(RowNumber)  ; Get the text from the row's first field
    dbgTT(0, "Double-clicked row " RowNumber ". Text: '" RowText "'")
  }

  LV_Search(CtrlObj, *) {
    static timer := LV_Search_Debounced.Bind()
    SetTimer(timer, -400) ; updates the old timer
    LV_Search_Debounced() {
      ; dbgtt(0,"LV_Search_Debounced")
      LV.Opt("-Redraw")
      LV.Delete()
      for ahkey, help_map in help_keys {
        IsFound := false
        ; for i, v in DATA_TYPES[k] { ;if !(CtrlObj.Value) || (InStr(v, CtrlObj.Value))
        v := help_map["h"]
        try {
          if (RegExMatch(v, "i)" CtrlObj.Value)) {
            IsFound := true
          }
        }
        if (help_map.Has("🔣name")) {
          v := help_map["🔣name"]
          try {
            if (RegExMatch(v, "i)" CtrlObj.Value)) {
              IsFound := true
            }
          }
        }
        if !(IsFound) {
          continue
        }
        LV.Add(, help_map["⇧"],help_map["⎈"],help_map["◆"],help_map["⎇"],
          help_map["c"],
         (help_map.Has("t")?help_map["t"]:""),
          ahkey, help_map["h"],
         (help_map.Has("🔣")?help_map["🔣"]:""),
         (help_map.Has("🔣name")?help_map["🔣name"]:""),
          help_map["f"], help_map["l№"])
      }
    LV.Opt("+Redraw")
    }
  }


  ; Messages
  EM_SETCUEBANNER(handle, string, option := false) {
    static ECM_FIRST       := 0x1500
    static EM_SETCUEBANNER := ECM_FIRST + 1
    SendMessage(EM_SETCUEBANNER, option, StrPtr(string), handle)
  }

  ; Functions
  HideFocusBorder(wParam, lParam := "", Msg := "", hWnd := "") {
    static Affected         := Map()
    static WM_UPDATEUISTATE := 0x0128
    static UIS_SET          := 1
    static UISF_HIDEFOCUS   := 0x1
    static SET_HIDEFOCUS    := UIS_SET << 16 | UISF_HIDEFOCUS
    static init             := OnMessage(WM_UPDATEUISTATE, HideFocusBorder)

    if (Msg = WM_UPDATEUISTATE) {
      if (wParam = SET_HIDEFOCUS) {
        Affected[hWnd] := true
      } else if (Affected.Has(hWnd)) {
        PostMessage(WM_UPDATEUISTATE, SET_HIDEFOCUS, 0,, "ahk_id " hWnd)
      }
    } else if (DllCall("user32\IsWindow", "Ptr", wParam, "UInt")) {
      PostMessage(WM_UPDATEUISTATE, SET_HIDEFOCUS, 0,, "ahk_id " wParam)
    }
  }

  SetExplorerTheme(handle, WindowTheme := "Explorer") {
    if   (DllCall("GetVersion","UChar") > 5) {
      VarSetStrCapacity(&ClassName, 1024)
      if (DllCall("user32\GetClassName", "Ptr",handle, "Str",ClassName, "Int",512, "Int")) {
        if (ClassName = "SysListView32") || (ClassName = "SysTreeView32") {
          return !DllCall("uxtheme\SetWindowTheme", "Ptr",handle, "Str",WindowTheme, "Ptr", 0)
        }
      }
    }
    return false
  }
}
