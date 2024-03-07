#Requires AutoHotKey 2.1-alpha.4

; ————————————————————————— App-specific Functions —————————————————————————
TotalCMD_CD(CDTo) {
  ; RunActivMin("c:\Dev\totalcmd\TOTALCMD64.EXE") ; avoding dupliate TC instance done via /O
  ; replace the following with native New-Tab command not to depend on keyboard shortcuts
  ;Sleep 100
  ;SendInput ^{vk54}     ;t vk54  ; not needed anymore as opening a new tab by TC
  Run("C:\Dev\totalcmd\TOTALCMD64.EXE /O /S /T " CDTo)
  Sleep 300   ; a simple wait until TC is launched (too short to bother with a cond check)
  Run("C:\Dev\totalcmd\Addons\TCFS2\TCFS2.exe /ef eval(tcd(``" CDTo "```,`,S)+msg($433`,3009`,`,1))")
  Sleep 100
  SendInput '{UP}{ENTER}'   ; Ingores user's keys
}

OpusDir_CD(CDTo) { ; AppDOpus
  ;AppDOpusRt /acmd Go LASTACTIVELISTER
  ;AppDOpusRt /acmd Go LASTACTIVELISTER NEW
  ; DopusWinID := WinExist(WinTitle, WinText, ExcludeTitle, ExcludeText)
  SplitPath(AppDOpus, &ExeFileName)
  PID := ProcessExist(ExeFileName)
  if (PID := 0) {
    ; dbgTT(3,"Debug:`nPID=0 1) Run " AppDOpus "`n2) Sleep 1000",dbgT,2,TTx,TTy+TTyOff*(2-2))
    Run('"' . AppDOpus . '"')
    Sleep 1000
  } else {
      if WinExist("ahk_class dopus.lister") {
        ; dbgTT(3,"Debug:`nElse 1) WinExist ahk_class dopus.lister`n2) WinActivate",dbgT,2,TTx,TTy+TTyOff*(2-2))
        WinActivate  ; Uses the last found window
      } else {
        Run('"' . AppDOpusRt . '"' . " /acmd Go LASTACTIVELISTER NEW")
        Sleep 1000 ; wait untill new Lister is launched
      }
    Run('"' . AppDOpusRt . '"' . " /acmd Go " '"' CDTo '"' " NewTab=findexisting,tofront")
    Sleep 300
    Run('"' . AppDOpusRt . '"' . " /acmd CloseTabSiblings")
  }
  ;Quit Opus or OpusRT from scripts
  ;AppDOpusRt /dblclk=off
  ;AppDOpusRt /CMD Close PROGRAM
}
