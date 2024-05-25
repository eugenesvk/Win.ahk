#Requires AutoHotKey 2.0.10

; ————————————————————————— Debugging Functions —————————————————————————
dbgMsg(dbgMin:=0, Text:="", Title:="", Options:="") {
  if (dbg >= dbgMin) {
    MsgBox(Text, Title, Options)
  }
}

log(dbgMin:=0, Text:="", fn:='',idTT:=0,X:=0,Y:=0) { ; print to debug, so leave unused vars as well
  if (dbg >= dbgMin) {
    OutputDebug(Text (idTT?idTT ': ':'') (fn?' @' fn:''))
  }
}
dbgTT(dbgMin:=0, Text:="", Time:= .5,idTT:=0,X:=-1,Y:=-1) {
  if (dbg >= dbgMin) {
    TT(Text, Time,idTT,X,Y)
  }
}
dbgTL(dbgMin:=0, Text:="", named?) { ; show tooltip and print to debug
  static def := {🕐:.5, id:0, x:-1, y:-1, fn:''}
  if (dbg >= dbgMin) {
    Time	:= HasProp(named,'Time')?named.Time:(HasProp(named,'t' )?named.t :(HasProp(named,'🕐')?named.🕐:def.Time))
    id  	:= HasProp(named,'idTT')?named.idTT:(HasProp(named,'id')?named.id:                               def.id  )
    x   	:= HasProp(named,'x'   )?named.x   :                                                             def.x
    y   	:= HasProp(named,'y'   )?named.y   :                                                             def.y
    fn  	:= HasProp(named,'fn'  )?named.fn  :                                                             def.fn
    TT(Text,Time,id,x,y)
    OutputDebug(Text (id?id ': ':'') (fn?' @' fn:''))
  }
}
TT(Text:="", Time:= .5,idTT:=0,X:=-1,Y:=-1) {
  static id_last := 0, id_max := 20
  , timers := Map()
  if idTT = 0 { ; no id given, increase by 1 to have multiple calls have different ids
    (id_last>=id_max) ? id_last:=1 : id_last+=1 ; reset id over max
    id := id_last
  } else {
    id := idTT
  }
  if timers.Has(id) {
    SetTimer(timers.Delete(id), 0) ;, log(0,'del timer id=' id)
  ; } else {
    ; log(0,' starting timer id ' id ' idTT=' idTT)
  }

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
    ToolTip(Text, X             , Y             ,id)
  } else if (X>=0) {
    ToolTip(Text, X             ,mY+stepY*(id-1),id)
  } else if (Y>=0) {
    ToolTip(Text,mX+stepX*(id-1), Y             ,id)
  } else {
    ToolTip(Text,mX+stepX*(id-1),mY+stepY*(id-1),id)
  }
  if Text != ''{
    if not Time = '∞' {
      SetTimer(timers[id] := %A_ThisFunc%.Bind(,,id), -Time*1000) ;, log(0,'set timer id=' id ' for f=')
    }
  }
}

err2str(err,f:='rme') { ; convert Error to a string (test whether a field exists before using it)
  dbgtxt := ''
  fields := ['Reason','Message','Extra','What']
  len := fields.Length
  for i, field in fields {
    ch1 := SubStr(field,1,1)
    if (err.HasOwnProp(field)) {
      if InStr(f,ch1) {
        dbgtxt .= err.%field% (i=len?'':' ¦ ')
      }
    }
  }
  return dbgtxt
}
