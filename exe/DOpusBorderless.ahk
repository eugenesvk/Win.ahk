#Requires AutoHotKey 2.0.10

; BorderLess window
WinTitleToggle(PosFix:="noPosFix") {
  local Monitor_DefaultToNearest  := 0x00000002
  local WS_Caption                := 0x00C00000
  local WS_SizeBox                := 0x00040000
  local WS_Borderless             := WS_Caption|WS_SizeBox ; Bitwise OR (logical inclusive OR)
  matchWin                        := "ahk_id " WinGetID("A")
  MinMax                          := WinGetMinMax("A") ; Min -1, Max 1, Neither 0
  bOffset                         := 11
  Style                           := WinGetStyle(matchWin)
  StyleHex                        := Format("{1:#x}", Style)

  WinSetStyle("^" WS_Borderless, "A")
  WinGetPos &X,&Y,&W,&H, matchWin
  If (PosFix = "noPosFix") { ; avoid visual artifacts from adding/removing borders, no pos/size change
    If (MinMax = 1) { ; If Maximized, Restore and Maximize back
      WinRestore matchWin
      WinMaximize matchWin
    } Else { ; If NOT Maximized, Maximize and Restore
      WinMove ,,W-1,, matchWin
      WinMove ,,W,, matchWin
      ; Alternative way (but more noticeablele): Maximize and Restore
      ; WinMaximize matchWin
      ; WinRestore matchWin
      ; WinActivate matchWin

      ; WinRestore matchWin ; NOT reliable, sometimes restores in the background
      ; Doesn't work: WinRedraw/WinHide/WinShow "A"
    }
  } Else {  ; change position/size to make border/-less windows the same
    If (MinMax = 1) { ; If Maximized, Restore and Maximize back
      ; WinMove 0,0,A_ScreenWidth,H-25, matchWin ; X+13,Y+13,W-26,H-26 ;Still acts like maximized e.g. after Alt+Tab
      WinRestore matchWin
      WinMaximize matchWin
    } Else { ; If NOT Maximized
      ; WinMove ,,W,, matchWin
      If (Style & WS_Caption) { ; has Title
        ; move Right by 1×, decrease Width by 2× and Height by 1×  BorderOffset
        if (debug)
          MsgBox("Has title WS_CAPTION 0x00C00000, var.StyleHex={" StyleHex "}", "Debug", "T2")
        WinMove X+bOffset,,W-bOffset*2,H-bOffset, matchWin
      } Else { ; Borderless
        ; move Left by 1×, increase Width by 2× and Height by 1× BorderOffset
        if (debug)
          MsgBox("Else, var.StyleHex={" StyleHex "}", "Debug", "T2")
        WinMove X-bOffset,,W+bOffset*2,H+bOffset, matchWin
      }
    }
  }
}

RunActivMin(App, WorkingDir:="", winSize:="", winTitle:="", PosFix:="noPosFix", winMatch:="ahk_exe") {
  SplitPath(App, &ExeFile)
  PID := ProcessExist(ExeFile)
  Run(App, WorkingDir, winSize)
  If (winTitle = "noTitle") {
    If WinWaitActive("ahk_class dopus.lister", , "10") {
      WinTitleToggle("noPosFix")
    }
  }
}
RunActivMin("C:\path\2\dopus.exe",,,"noTitle", "noPosFix", "ahk_class dopus.lister")
ExitApp
