#Requires AutoHotKey 2.0.10
NewTextFile() {
  FullPath := WinGetText("A")	; Get full path from open Explorer window
  MsgBox FullPath, "File status"
  PathArray := StrSplit(FullPath, "`n")	; Split up result (it returns paths seperated by newlines)
  Loop(PathArray.Length()) {           	; Find line with backslash which is the path
    pos := InStr(PathArray[a_index], "\")
    if (pos > 0) {
      FullPath := PathArray[a_index]
      Break
    }
  }
  FullPath := RegExReplace(FullPath, "(^.+?: )", "")                      	; Clean up result
  FullPath := StrReplace(FullPath, "`r")                                  	; Remove return characters
  ;FullPath := RegExReplace(FullPath, "^.*`nAddress: ([^`n]+)`n.*$", "$1")	;
  SetWorkingDir(FullPath)                                                 	; Change working directory
  ; ErrorLevel removed, exceptions are thrown now                         	;
  ; If ErrorLevel                                                         	; Stop if an error occurred with the SetWorkingDir directive
    ; Return
  UserInput := InputBox("(md if no extension)", "Create a New File", "W400 H120")	; Get user input
  ; If ErrorLevel                                                                	; Stop if user cancels
    ; Return
  FileList := list_files(FullPath)                                          	; get list of files in the current directory
  SplitPath(UserInput, &oName, &oDir, &UserInputExtension, &oNmExt, &oDrive)	; get extension for the new file
  If (UserInputExtension = "") {                                            	; add default one (.md) if no extension
    UserInput := UserInput . ".md"
  }
  If InStr(FileList, "`n" . UserInput . "`n") = 0 {	; check if file already exists
    FileAppend('', UserInput)                      	; create new file if it doesn't
    Run(AppST " " UserInput)                       	; Open the file in Sublime Text
    Return
  } else {	; warn that file already exists
    Result := MsgBox("File already exists!`nOpen in " . AppST . "?", "File status", "YesNo")
    If Result = "Yes" {
      Run(AppST " " UserInput)
      Return
    }
  }
  Return
}

list_files(Directory) { ; Get a list of files in a folder, separated by EoL
  FileList := ""
  Loop Files, Directory . "\*.*" {
    FileList .= A_LoopFileName "`n"
  }
  Return FileList
}
