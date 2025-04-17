#Requires AutoHotKey 2.1-alpha.18

#include <libFunc GUI>	; Functions: GUI

#include <FuzzSift>
class guiKeyHelp {
  __new(gTheme:="light", text_ed:="sublime_text.exe", jump2ln:=true) { ; get all vars and store their values in this.Varname as well ‘m’ map, and add aliases
    static _d:=0, _d1:=1, _d2:=2, _d3:=3
     , is_init := false
     , chU	:= keyFunc.keyCharNameU
     , chC	:= keyFunc.keyCharNameC
     , FFToolTip := guiF.FFToolTip.Bind(guiF)
    is_path_full := RegExMatch(text_ed, "i)^`"?(([a-zA-Z]:[\\/]?)|((\.\.)?[\\/])|([\\/]{2})).*")

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
    guiKeyHelp.EM_SETCUEBANNER(ED, "Search 𝕽𝔢…  ≝word-based   ,comma prefix=phrase  .dot prefix=fuzzy", 1)

    gap_el := 0

    static sys := helperSystem
    dpi🖥️	:= sys.getDPI🖥️(), dpi🖥️x:=dpi🖥️[1], dpi🖥️y:=dpi🖥️[2]	; 1) monitor dpi
    dpi_f := dpi🖥️x / 96 ; 1.5

    guiM.SetFont("s10", "Segoe UI")
    LV_Header	:= ["⇧","⎈","◆","⎇","K⃣","🅃", "AHK⃣", "🔍H", "🔣", "🔍🔖", "🔍Names","File", "l№"]
    static _:=0
     , c⇧     	:=LV_Header.IndexOf("⎈")
     , c⎈     	:=LV_Header.IndexOf("⎈")
     , c◆     	:=LV_Header.IndexOf("◆")
     , c⎇     	:=LV_Header.IndexOf("⎇")
     , cK⃣    	:=LV_Header.IndexOf("K⃣")
     , c🅃     	:=LV_Header.IndexOf("🅃")
     , cAHK⃣  	:=LV_Header.IndexOf("AHK⃣")
     , c🔍H    	:=LV_Header.IndexOf("🔍H")
     , c🔣     	:=LV_Header.IndexOf("🔣")
     , c🔍🔖     	:=LV_Header.IndexOf("🔍🔖")
     , c🔍Names	:=LV_Header.IndexOf("🔍Names")
     , cFile  	:=LV_Header.IndexOf("File")
     , cl№    	:=LV_Header.IndexOf("l№")
    static LVS_EX_DOUBLEBUFFER :=0x10000
    LV_Opt	:= leftmost " y+" gap_el " w" A_ScreenWidth/dpi_f " r20" ((gTheme = "Dark") ? " cD9D9D9 Background5B5B5B" : "")
     . " LV" LVS_EX_DOUBLEBUFFER ; Paints via double-buffering, which reduces flicker, also enables alpha-blended marquee selection on systems where it is supported
    LV	:= guiM.AddListView(LV_Opt, LV_Header)
    LV.Opt("-Redraw")
    LV.OnEvent("DoubleClick", cbLV_DoubleClick)  ; Notify the script whenever the user double clicks a row
    for ahkey, help_map in help_keys { ; Add data
      if not is_init { ;
        if help_map.Has('🔣') {
          _ch := ''
          Loop Parse, help_map['🔣'] {
            ; dbgtt(0,A_LoopField,1)
            _chi := chU(A_LoopField)
            if _chi == 'Undefined' {
              _chi := chC(A_LoopField)
            }
            if _chi {
              for repl in ['Latin ','Small ','Letter ','With '] {
                _chi := StrReplace(_chi,repl,'')
              }
              _ch .= _chi . ' ¦ '
            }
          }
          help_map['🔣name'] := StrLen(_ch) . " " . _ch
        }
      }

      LV.Add(,help_map["⇧"],help_map["⎈"],help_map["◆"],help_map["⎇"],
        help_map["c"],
       (help_map.Has("t"    	)?help_map["t"    	]:""),
        ahkey               	                  	,
       (help_map.Has("h"    	)?help_map["h"    	]:""),
       (help_map.Has("🔣"    	)?help_map["🔣"    	]:""),
       (help_map.Has("🔖s"   	)?help_map["🔖s"   	]:""),
       (help_map.Has("🔣name"	)?help_map["🔣name"	]:""),
       (help_map.Has("f"    	)?help_map["f"    	]:""),
       (help_map.Has("l№"   	)?help_map["l№"   	]:""),
      )
    }
    if not is_init {
      is_init := true
    }
    ; LV.ModifyCol(2, "Integer")  ; for sorting purposes, indicate that column 2 is an integer
    ; todo: fails autosize, still get …
    loop LV.GetCount("Col") {
      if A_Index <= c⎇ or A_Index = c🔍🔖 or A_Index = c🔍Names {
        continue
      }
      LV.ModifyCol(A_Index, "AutoHdr") ; auto-size column to fit max(contents, header text)
    }
    LV.ModifyCol(c⇧,23) ;fits ‹⇧› without …
    LV.ModifyCol(c⎈,29) ;     ‹⎈›
    LV.ModifyCol(c◆,29) ;     ‹◆›
    LV.ModifyCol(c⎇,31) ;     ‹⎇›
    LV.ModifyCol(c🔍🔖,30) ; too huge of a field
    LV.ModifyCol(c🔍Names,30) ; too huge of a field


    ; guiM.OnEvent("Escape", (*) => guiM.Hide())
    guiM.OnEvent("Escape", cbEscape)
    guiM.OnEvent("Size"  , cbGuiSize)
    ; guiM.OnEvent("Close", (*) => ExitApp)
    ; guiM.Show("AutoSize x0 y0") ; Display the window
    LV.Opt("+Redraw")
    cbEscape(*) {
      FFToolTip() ; in case was hovering over listview header
      guiM.Hide()
    }

    OnMessage(WM_KEYDOWN:=0x100, KeyDown)
    KeyDown(wParam, lParam, nmsg, hwnd) {
      static VK_UP	:= 0x26
       , VK_DOWN  	:= 0x28
       , vkF      	:= GetKeyVK('F')
       , vkS      	:= GetKeyVK('S')
      hWndLV := ControlGetHwnd(LV)  ; Handle of the ListView
      if not hWndLV == hwnd {
        return
      }
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

    OnMessage(0x200, cbMouseMove) ;WM_MOUSEMOVE
    cbMouseMove(wParam, lParam, nmsg, hwnd) {
      hWndLV := ControlGetHwnd(LV)  ; Handle of the ListView
      if not hWndLV == hwnd {
        return
      }
      🖰x :=  lParam        & 0xFFFF
      🖰y := (lParam >> 16) & 0xFFFF
      ; Check if the mouse is over the ListView header
      hdRect := guiF.lvGetHeaderRect(hWndLV)
      ; If the mouse is over the header, show the tooltip
      if (🖰y >= hdRect.↑ && 🖰y <= hdRect.↓) {
        col_i_cur := guiF.lvSubitemHitTest(hWndLV)
        ; col_i_tgt := (dbg<_d1) ? c🔣 : c🔍Names
        ; if col_i_cur = col_i_tgt {
        if col_i_cur > 0 {
          col_rect := guiF.lvGetHeaderItemRect(hWndLV, col_i_cur)
          if        col_i_cur = cFile {
            FFToolTip("2⋅🖰 to open",col_rect.←,col_rect.↑)
          } else if col_i_cur = cl№ {
            FFToolTip("2⋅🖰 to open",col_rect.←,col_rect.↑)
          } else if col_i_cur > 0 {
            FFToolTip("2⋅🖰 to 📋copy",col_rect.←,col_rect.↑)
          }
        } else {
          FFToolTip()
        }
      } else {
        FFToolTip()
      }
      ; if (🖰x >= hdRect.← && 🖰x <= (hdRect.→ - 500)&&
      ;     🖰y >= hdRect.↑ && 🖰y <= hdRect.↓) {
      ;   FFToolTip(hdRect.← "← "
      ;     .     hdRect.→ "→`t"
      ;     .     hdRect.→ - hdRect.← "w`n"
      ;     .     hdRect.↑ "↑ "
      ;     .     hdRect.↓ "↓`t"
      ;     .     hdRect.↓ - hdRect.↑ "h")
      ; } else {
      ;   FFToolTip()
      ; }
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
    cbLV_DoubleClick(LV, row№) { ; todo: open file/line number
      static F:=nativeFunc
      i_key := (dbg<_d1)?"🔣":"🔍Names" ; fallback
      hWndLV := ControlGetHwnd(LV)  ; Handle of the ListView
      col№ := guiF.lvSubitemHitTest(hWndLV)
      if col№ = 0 {
        col№ := this.LV_Header.IndexOf(i_key)
      }
      if col№ = cFile or col№ = cl№ {
        colSym := LV_Header[col№]
        fname := LV.GetText(row№, cFile)
        line  := LV.GetText(row№, cl№)
        fpath_l := A_ScriptDir "\" fname ".ahk" (jump2ln ? ":" line : "")
        if is_path_full {
          exe_path := text_ed
        } else {
          exe_path := ""
          for got_exe_path in [
            F.get_exe_path_app_cli_reg(text_ed),
            F.get_exe_path_env_var(    text_ed)] {
            if got_exe_path {
              exe_path := got_exe_path
              break
            }
          }
        }
        if exe_path {
          Run(exe_path . ' ' . fpath_l, A_ScriptDir)
          (dbg<_d1)?'':(dbgTT(0,"2·🖰 row" row№ " col" . col№ . ", opening file`n" fpath_l,🕐:=2))
        } else {
          (dbg<_d1)?'':(dbgTT(0,"2·🖰 row" row№ " col" . col№ . ", editor not found to open file`n" fpath_l,🕐:=2))
        }
      } else {
        colSym := LV_Header[col№]
        RowText := LV.GetText(row№, col№)  ; Get the text from the row's first field
        A_Clipboard := RowText
        (dbg<_d1)?'':(dbgTT(0,"2·🖰 row" row№ " col" . col№ ", copied ‘" colSym "’ . text to 📋:`n" RowText,🕐:=1))
      }
    }
    LV_Search(CtrlObj, *) {
      static timer := LV_Search_Debounced.Bind()
      SetTimer(timer, -400) ; updates the old timer
      (dbg<_d3)?'':(dbgTT(0,CtrlObj.Value "¦ LV_Search CtrlObj",🕐:=1,id:=4,0,50))
    }

    LV_Search_Debounced() {
      static fuzzyΔ := 0.5 ; ≝.7 min Fuzzy match coefficient, 1=prefect, 0=no match
       , ng_sz := 3 ; Ngram Size ≝3 length of Ngram used. 3=trigram

      LV.Opt("-Redraw")
      LV.Delete()
      (dbg<_d3)?'':(dbgTT(0,ED.Value "¦ LV_Search_Debounced ED.Value",🕐:=1,id:=19,0,90))
      pre := SubStr(ED.Value,1,1)
      skip_all := false
      if pre="," {
        if StrLen(ED.Value) < 2 {
          skip_all := true
        } else {
          re_query := SubStr(ED.Value,2)
          queryT := "literal"
          if not re_query { ; don't search when value is empty
            skip_all := true
          }
        }
      } else if pre="."{
        if StrLen(ED.Value) < 2 {
          skip_all := true
        } else {
          re_query := SubStr(ED.Value,2)
          queryT := "fuzzy"
          if not re_query { ; don't search when value is empty
            skip_all := true
          }
        }
      } else {
        if not ED.Value { ; don't search when value is empty
          skip_all := true
        } else {
          re_query_s := StrSplit(ED.Value, delim:=[" ","`t"], " `t")
          re_query := []
          for w in re_query_s { ; remove empty
            if w {
              re_query.push(w)
            }
          }
          queryT := "word"
        }
      }
      ; (dbg<_d3)?'':(dbgTT(0,"LV_Search_Debounced re_query ¦" Obj2Str(re_query) "¦ of ¦" queryT "¦ ED.Value=¦" ED.Value "¦",🕐:=2,id:=4))
      for ahkey, help_map in help_keys {
        IsFound := skip_all ? true : false
        if not IsFound {
          v := help_map["h"]
          if        queryT == "literal" {
            try {
              if (RegExMatch(v, "i)" re_query)) {
                IsFound := true
                (dbg<_d3)?'':(dbgTT(0,"🔍H found re_lit ¦" re_query "¦ in ¦" v "¦",🕐:=3))
              } else {
                (dbg<_d3)?'':(dbgTT(0,"✗H re_lit ¦" re_query "¦ in ¦" v "¦",🕐:=3))
              }
            }
          } else if queryT == "word" {
            try {
              for w in re_query {
                if w and (RegExMatch(v, "i)" w)) {
                  IsFound := true
                  (dbg<_d3)?'':(dbgTT(0,"🔍H found re_ω ¦" w "¦ in ¦" v "¦",🕐:=3))
                  break
                }
              }
            }
          } else if queryT == "fuzzy" {
            ; try { ; ;;; disable for now to track bugs
              fuzz_res := Sift_Ngram(&v, &re_query, fuzzyΔ, &hm:=false, ng_sz, fmt:="S`n")
              if fuzz_res.Length > 0 {
                IsFound := true
                (dbg<_d2)?'':(dbgTT(0,"🔍H found re_fuzz " fuzz_res[1]["Delta"] " ¦" re_query "¦ in ¦" v "¦",🕐:=3))
              } else {
                (dbg<_d2)?'':(dbgTT(0,"✗H re_fuzz ¦" re_query "¦ in ¦" v "¦",🕐:=3))
              }
            ; }
          }
        }
        if not IsFound {
          if (help_map.Has("🔣name")) {
            v := help_map["🔣name"]
            if queryT == "literal" {
              try {
                if (RegExMatch(v, "i)" re_query)) {
                  IsFound := true
                  (dbg<_d3)?'':(dbgTT(0,"🔍Name found re_lit ¦" re_query "¦ in ¦" v "¦",🕐:=3))
                }
              }
            } else if queryT == "word" {
              for w in re_query {
                try {
                  if w and (RegExMatch(v, "i)" w)) {
                    IsFound := true
                    (dbg<_d3)?'':(dbgTT(0,"🔍Name found re_ω ¦" w "¦ in ¦" v "¦",🕐:=3))
                    break
                  }
                }
              }
            } else if queryT == "fuzzy" {
              ; try {
                fuzz_res := Sift_Ngram(&v, &re_query, fuzzyΔ, &hm:=false, ng_sz, fmt:="S`n")
                if fuzz_res.Length > 0 {
                  IsFound := true
                  (dbg<_d2)?'':(dbgTT(0,"🔍Name found re_fuzz " fuzz_res[1]["Delta"] " ¦" re_query "¦ in ¦" v "¦",🕐:=3))
                } else {
                  ; (dbg<_d2)?'':(dbgTT(0,"✗🔍Name re_fuzz " fuzz_res[1]["Delta"] " ¦" re_query "¦ in ¦" v "¦",🕐:=3))
                }
              ; }
            }
          }
        }
        if not IsFound {
          if (help_map.Has("🔖")) {
            v := help_map["🔖"]
            if queryT        == "literal" {
              for tag in v {
                try {
                  if (RegExMatch(tag, "i)" re_query)) {
                    IsFound := true
                    (dbg<_d3)?'':(dbgTT(0,"🔍Name found re_lit ¦" re_query "¦ in ¦" v "¦",🕐:=3))
                    break
                  }
                }
              }
            } else if queryT == "word" {
              for tag in v {
                for w in re_query {
                  try {
                    if w and (RegExMatch(tag, "i)" w)) {
                      IsFound := true
                      (dbg<_d3)?'':(dbgTT(0,"🔍Name found re_ω ¦" w "¦ in ¦" v "¦",🕐:=3))
                      break 2
                    }
                  }
                }
              }
            } else if queryT == "fuzzy" {
              for tag in v {
                ; try {
                  fuzz_res := Sift_Ngram(&tag, &re_query, fuzzyΔ, &hm:=false, ng_sz, fmt:="S`n")
                  if fuzz_res.Length > 0 {
                    IsFound := true
                    (dbg<_d2)?'':(dbgTT(0,"🔍Name found re_fuzz " fuzz_res[1]["Delta"] " ¦" re_query "¦ in ¦" v "¦",🕐:=3))
                    break
                  } else {
                    ; (dbg<_d2)?'':(dbgTT(0,"✗🔍Name re_fuzz " fuzz_res[1]["Delta"] " ¦" re_query "¦ in ¦" v "¦",🕐:=3))
                  }
                ; }
              }
            }
          }
        }
        if not IsFound {
          continue
        }
        LV.Add(,help_map["⇧"],help_map["⎈"],help_map["◆"],help_map["⎇"],
          help_map["c"],
         (help_map.Has("t"    	)?help_map["t"    	]:""),
          ahkey               	                  	,
         (help_map.Has("h"    	)?help_map["h"    	]:""),
         (help_map.Has("🔣"    	)?help_map["🔣"    	]:""),
         (help_map.Has("🔖s"   	)?help_map["🔖s"   	]:""),
         (help_map.Has("🔣name"	)?help_map["🔣name"	]:""),
         (help_map.Has("f"    	)?help_map["f"    	]:""),
         (help_map.Has("l№"   	)?help_map["l№"   	]:""),
        )
      }
      LV.Opt("+Redraw")
    }
    this.g := guiM
    this.ED := ED
    this.LV := LV
    this.LV_Header := LV_Header
  }



  ; Messages
  static EM_SETCUEBANNER(handle, string, option := false) {
    static ECM_FIRST       := 0x1500
    static EM_SETCUEBANNER := ECM_FIRST + 1
    SendMessage(EM_SETCUEBANNER, option, StrPtr(string), handle)
  }

  ; Functions
  static HideFocusBorder(wParam, lParam := "", Msg := "", hWnd := "") {
    static Affected    	:= Map()
     , WM_UPDATEUISTATE	:= 0x0128
     , UIS_SET         	:= 1
     , UISF_HIDEFOCUS  	:= 0x1
     , SET_HIDEFOCUS   	:= UIS_SET << 16 | UISF_HIDEFOCUS
     , init            	:= OnMessage(WM_UPDATEUISTATE, guiKeyHelp.HideFocusBorder)

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

  static SetExplorerTheme(handle, WindowTheme := "Explorer") {
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


get_help(gTheme:="light") { ; Show a listview with all the registered hk🛈 hotkeys and their help🛈
  static is_init := false
   , _d:=0, _d1:=1, _d2:=2, _d3:=3
   , guiC := guiKeyHelp(gTheme)
   , guiM := guiC.g
   , ED := guiC.ED
   , LV := guiC.LV
   ; , constT := 'embed' ;embed mmap
   ; , winAPI	:= winAPIconst_loader.load(constT)
   ; , cC    	:= winAPI.getKey_Any.Bind(winAPI)
   ; , EM_SETSEL := cC("EM_SETSEL")
   , EM_SETSEL  := 177

  guiM.Show("AutoSize x0 y0") ; Display the window
  guiKeyHelp.HideFocusBorder(guiM.Hwnd)
  ; Focus search box and select previous query
  ControlFocus(guiC.ED)
  PostMessage(EM_SETSEL, 0, -1,, guiC.ED)


  if   (VerCompare(A_OSVersion, "10.0.17763") >= 0) && (gTheme = "Dark") {
      DWMWA_USE_IMMERSIVE_DARK_MODE := 19
    if (VerCompare(A_OSVersion, "10.0.18985") >= 0) {
      DWMWA_USE_IMMERSIVE_DARK_MODE := 20
    }
    DllCall("dwmapi\DwmSetWindowAttribute", "Ptr",guiM.hWnd, "Int",DWMWA_USE_IMMERSIVE_DARK_MODE, "int*",true, "Int",4)
    guiKeyHelp.SetExplorerTheme(LV.hWnd, "DarkMode_Explorer")
  } else {
    guiKeyHelp.SetExplorerTheme(LV.hWnd)
  }
}

