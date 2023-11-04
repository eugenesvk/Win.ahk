#Requires AutoHotKey 2.0.10

; ————————————————————————— Debugging Functions —————————————————————————
dbgMsg(dbgMin:=0, Text:="", Title:="", Options:="") {
  if (dbg >= dbgMin) {
    MsgBox(Text, Title, Options)
  }
}

log(dbgMin:=0, Text:="", fn:='',idTT:=0,X:=0,Y:=0) { ; print to debug, so leave unused vars as well
  if (dbg >= dbgMin) {
    OutputDebug((idTT?idTT ': ':'') Text (fn?' @' fn:''))
  }
}
dbgTT(dbgMin:=0, Text:="", Time:= .5,idTT:=0,X:=-1,Y:=-1) {
  if (dbg >= dbgMin) {
    TT(Text, Time,idTT,X,Y)
  }
}
TT(Text:="", Time:= .5,idTT:=0,X:=-1,Y:=-1) {
  static id_last := 0
  if idTT = 0 { ; no id given, increase by 1 to have multiple calls have different ids
    id_last += 1
  } else {
    id_last := idTT
  }
  if id_last <  1 or
     id_last > 20 { ; reset id
    id_last := 1
  }
  id := id_last
  MouseGetPos(&mX, &mY, &mWin, &mControl)
    ; mWin This optional parameter is the name of the variable in which to store the unique ID number of the window under the mouse cursor. If the window cannot be determined, this variable will be made blank.
    ; mControl This optional parameter is the name of the variable in which to store the name (ClassNN) of the control under the mouse cursor. If the control cannot be determined, this variable will be made blank.
  stepX := 0, stepY := 50 ; offset each subsequent ToolTip # from mouse cursor
  xFlag := SubStr(X, 1,1), yFlag := SubStr(Y, 1,1)
  if (xFlag="o") {
    stepX := SubStr(X, 2), X := -1
  }
  if (yFlag="o") {
    stepY := SubStr(Y, 2), Y := -1
  }
  dbgMsg(6,"X=" X " | xFlag=" xFlag " | stepX=" stepX "`n"
           "Y=" Y " | yFlag=" yFlag " | stepY=" stepY "`n"
           "SubStr:" SubStr("o200", 2) )
  if        (X>=0
          && Y>=0) {
    ToolTip(Text, X,Y,id)
  } else if (X>=0) {
    ToolTip(Text, X             ,mY+stepY*(id-1),id)
  } else if (Y>=0) {
    ToolTip(Text,mX+stepX*(id-1), Y             ,id)
  } else {
    ToolTip(Text,mX+stepX*(id-1),mY+stepY*(id-1),id)
  }
  if not Time = '∞' {
    SetTimer () => ToolTip(,,,id), -Time*1000
  }
}

