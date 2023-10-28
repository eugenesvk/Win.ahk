#Requires AutoHotKey 2.0.10

; BorderLess window
RunActiv(Program, WorkingDir:="", WindowSize:="", WinTitle:="", WinFrame:="") {
  SplitPath(Program, &ExeFile)
  PID := ProcessExist(ExeFile)
  Run(Program, WorkingDir, WindowSize)
  If (WinTitle = "noTitle") {
    If WinWaitActive("ahk_class dopus.lister", , "10") {
      WinSetStyle "-0xC40000", "ahk_class dopus.lister"
    }
  }
}
RunActiv("C:\path\to\dopus.exe", , , "noTitle")
ExitApp
