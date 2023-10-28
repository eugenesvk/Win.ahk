#Requires AutoHotKey 2.1-alpha.4

launcher() { ; Autohotkey launcher, can't #include conditionally, so launch a new script instead
  scriptDir := '"' . A_AhkPath . '"' . " " A_WorkingDir . "/"
  if (DriveGetLabel("C:") = "BOOTCAMP") {
    Run(scriptDir "[Mac].ahk")
  } else {
    Run(scriptDir "[PCH].ahk")
  }
}
launcher()
ExitApp()
