#Requires AutoHotKey 2.0

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
  , timers := Map()
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
  if timers.Has(id) {
    SetTimer(timers.Delete(id), 0) ;, log(0,'del timer id=' id)
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
    ToolTip(Text, X,Y,id)
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

Object2Str(Var){ ; autohotkey.com/boards/viewtopic.php?f=82&t=111713
  Output := ""
  if !(Type(Var) ~="Map|Array|Object|String|Number|Integer|Float"){
    throw Error("Object type not supported.", -1, Format("<Object at 0x{:p}>", Type(Var)))
  }
  if (Type(Var)="Array"){
    Output .= "["
    For Index, Value in Var{
      Output .= ((Index=1) ? "" : ",") Object2Str(Value)
    }
    Output .= "]"
  } else if (Type(Var)="Map"){
    Output .= "Map("
    For Key , Value in Var {
      Output .= ((A_index=1) ? "" : ",") Key "," Object2Str(Value)
    }
    Output .= ")"
  } else if (Type(Var)="Object"){
    Output .= "{"
    For Key , Value in Var.Ownprops() {
      Output .= ((A_index=1) ? "" : ",") Key ":" Object2Str(Value)
    }
    Output .= "}"
  } else if (Type(Var)="String"){

    ; Quotes := InStr(Var,"'") ? '"' : "'"
    ; MsgBox(Var "`n" Quotes )
    Output := IsNumber(Var) ? Var : InStr(Var,"'") ? '"' Var '"' : "'" StrReplace(Var,"'","``'") "'"
  } else {
    Output := Var
  }
  if (Type(Var) ~="Map|Array" and ObjOwnPropCount(Var)>0){
    Output .= "{"
    For Key , Value in Var.Ownprops() {
      Output .= ((A_index=1) ? "" : ",") Key ":" Object2Str(Value)
    }
    Output .= "}"
  }

  Return Output
}
Str2Object(Input){
  Input := Trim(Input)
  Skipnext := 0
  aLevel := Array()
  Var :=""

  if Regexmatch(Input, "i)^(\[|array\().*"){
    EndArrayChar := "]"
    if Regexmatch(Input, "i)^array\(.*"){
      EndArrayChar := ")"
      Input := RegExReplace(Input,"i)^array\((.*)", "[$1")
    }
    aInput := StrSplit(Input)
    Output := Array()

    aLevel.Push(EndArrayChar)

    Loop aInput.Length {
      if (A_index=1 and aInput[A_index]="["){
        continue
      } else if (Skipnext=1){
        Skipnext := 0
      } else if (aInput[A_index] ~= "``"){
        Skipnext := 1
      } else if (aLevel.length >1 and aLevel[aLevel.length]=aInput[A_index]){
        aLevel.RemoveAt(aLevel.length)
      } else if (aLevel[aLevel.length]='"' or aLevel[aLevel.length]="'"){
        ; skip
      } else if (aInput[A_index]='"'){
        aLevel.Push('"')
        ; continue
      } else if (aInput[A_index]="'"){
        aLevel.Push("'")
        ; continue
      } else if (aInput[A_index]='{'){
        aLevel.Push('}')
      } else if (aInput[A_index]='['){
        aLevel.Push(']')
      } else if (aInput[A_index]='('){
        aLevel.Push(')')
      } else if (aLevel.length =1 and aInput[A_index]=","){
        Output.Push(Str2Object(Var))
        Var :=""
        continue
      } else if (aLevel.length =1 and aInput[A_index]=aLevel[aLevel.length]){
        Output.Push(Str2Object(Var))
        Rest := Trim(Substr(Input,A_Index+1))
        if (Rest!=""){
          ; Hack, if an object is defined afther the array, add them as properties
          Output := AddProperties(Output,Rest)
        }
        break
      }
      if (StrLen(Var)=0 and aInput[A_index]=" "){
        continue
      }
      Var .= aInput[A_index]
    }
  } else if Regexmatch(Input, "i)^(map\().*"){
    Output := Map()
    Input := RegExReplace(Input,"i)^map\((.*)", "$1")
    aInput := StrSplit(Input)

    Key :=""

    aLevel.Push(")")
    Loop aInput.Length {
      if (aLevel.length >1 and aLevel[aLevel.length]=aInput[A_index]){
        aLevel.RemoveAt(aLevel.length)
      } else if (Skipnext=1){
        Skipnext := 0
      } else if (aInput[A_index] ~= "``"){
        Skipnext := 1
      } else if (aLevel.length >1 and aLevel[aLevel.length]='"' or aLevel[aLevel.length]="'"){
        ; skip
      } else if (aInput[A_index]='"'){
        aLevel.Push('"')
      } else if (aInput[A_index]="'"){
        aLevel.Push("'")
      } else if (aInput[A_index]='{'){
        aLevel.Push('}')
      } else if (aInput[A_index]='['){
        aLevel.Push(']')
      } else if (aInput[A_index]='('){
        aLevel.Push(')')
      } else if (aLevel.length =1 and aInput[A_index]=","){
        if (Key=""){
          Key := RegexReplace(Var, "`"|'")
        } else {
          Output[Key] := Str2Object(Var)
          Key := ""
        }
        Var :=""
        continue
      } else if (aLevel.length =1 and aInput[A_index]=aLevel[aLevel.length]){
        if (Key=""){
          Key := RegexReplace(Var, "`"|'")
        } else {
          Output[Key] := Str2Object(Var)
          Key := ""
        }
        Rest := Trim(Substr(Input,A_Index+1))
        if (Rest!=""){
          ; Hack, if an object is defined afther the map, add them as properties
          Output := AddProperties(Output,Rest)
        }
        break
      }
      if (StrLen(Var)=0 and aInput[A_index]=" "){
        continue
      }
      Var .= aInput[A_index]
    }
  } else if Regexmatch(Input, "i)^({).*"){
    Output := Object()
    Input := RegExReplace(Input,"i)^{(.*)", "$1")
    aInput := StrSplit(Input)

    Key :=""

    aLevel.Push("}")

    Loop aInput.Length {
      if (aLevel.length >1 and aLevel[aLevel.length]=aInput[A_index]){
        aLevel.RemoveAt(aLevel.length)
      } else if (Skipnext=1){
        Skipnext := 0
      } else if (aInput[A_index] ~= "``"){
        Skipnext := 1
      } else if (aLevel.length >1 and aLevel[aLevel.length]='"' or aLevel[aLevel.length]="'"){
        ; skip
      } else if (aInput[A_index]='"'){
        aLevel.Push('"')
      } else if (aInput[A_index]="'"){
        aLevel.Push("'")
      } else if (aInput[A_index]='{'){
        aLevel.Push('}')
      } else if (aInput[A_index]='['){
        aLevel.Push(']')
      } else if (aInput[A_index]='('){
        aLevel.Push(')')
      } else if (aLevel.length =1 and aInput[A_index]=":"){
        Key := Trim(Var)
        Var :=""
        continue
      } else if (aLevel.length =1 and aInput[A_index]=","){
        Output.%Key% := Str2Object(Var)
        Var :=""
        continue
      } else if (aLevel.length =1 and aInput[A_index]=aLevel[aLevel.length]){
        Output.%Key% := Str2Object(Var)
        Rest := Trim(Substr(Input,A_Index+1))
        if (Rest!=""){
          MsgBox(Rest)
        }
        break
      }
      if (StrLen(Var)=0 and aInput[A_index]=" "){
        continue
      }
      Var .= aInput[A_index]
    }
  } else{
    ;
    Output := RegExReplace(Input, '^\"(.*)\"$' , "$1", &Count)
    if (Count=0){
      Output := RegExReplace(Input, "^\'(.*)\'$" , "$1", &Count)
    }
    OutputDebug(Output)
    Output := Output
  }

  return Output

  AddProperties(Output,PropString){
    if Regexmatch(PropString, "i)^({).*"){
      ;Output := Object()
      PropString := RegExReplace(PropString,"i)^{(.*)", "$1")
      aInput := StrSplit(PropString)

      Key :=""
      Var := ""

      aLevel := Array()
      aLevel.Push("}")

      Loop aInput.Length {
        if (aLevel.length >1 and aLevel[aLevel.length]=aInput[A_index]){
          aLevel.RemoveAt(aLevel.length)
        } else if (aLevel.length >1 and aLevel[aLevel.length]='"' or aLevel[aLevel.length]="'"){
          ; skip
        } else if (aInput[A_index]='"'){
          aLevel.Push('"')
        } else if (aInput[A_index]="'"){
          aLevel.Push("'")
        } else if (aInput[A_index]='{'){
          aLevel.Push('}')
        } else if (aInput[A_index]='['){
          aLevel.Push(']')
        } else if (aInput[A_index]='('){
          aLevel.Push(')')
        } else if (aLevel.length =1 and aInput[A_index]=":"){
          Key := Trim(Var)
          Var :=""
          continue
        } else if (aLevel.length =1 and aInput[A_index]=","){
          Output.%Key% := Str2Object(Var)
          Var :=""
          continue
        } else if (aLevel.length =1 and aInput[A_index]=aLevel[aLevel.length]){
          Output.%Key% := Str2Object(Var)
          Rest := Trim(Substr(PropString,A_Index+1))
          if (Rest!=""){
            MsgBox(Rest)
          }
          break
        }
        if (StrLen(Var)=0 and aInput[A_index]=" "){
          continue
        }
        Var .= aInput[A_index]
      }
    }
    return output
  }
}
Obj_Gui(Array, ParentID := "") { ; Displays the content of the variable autohotkey.com/boards/viewtopic.php?f=83&t=103437
  static ogcTreeView
  if !ParentID {
    myGui := Gui()
    myGui.Opt("+Resize")
    myGui.OnEvent("Size", Gui_Size)
    myGui.MarginX := "0", myGui.MarginY := "0"
    if (IsObject(Array)){
      ogcTreeView := myGui.AddTreeView("w300 h300")
      ogcTreeView.OnEvent("ContextMenu", ContextMenu_TreeView)
      ItemID := ogcTreeView.Add("(" type(Array) ")", 0, "+Expand")
      Obj_Gui(Array, ItemID)
    }
    else {
      ogcEdit := myGui.AddEdit("w300 h200 +multi", Array)
    }
    myGui.Title := "Gui (" Type(Array) ")"

    ;Reload menu for testing
    ; Menus := MenuBar()
    ; Menus.Add("&Reload", (*) => (Reload()))
    ; myGui.MenuBar := Menus

    myGui.Show()
    return
  }
  if (type(Array)="Array"){
    For Key, Value in Array{
      if (IsObject(Value)){
        ItemID := ogcTreeView.Add("[" Key "] (" type(Value) ")", ParentID, "Expand")
        Obj_Gui(Value, ItemID)
      }
      else{
        ogcTreeView.Add("[" Key "] (" type(Value) ")  =  " Value, ParentID, "Expand")
      }
    }
  }
  if (type(Array) = "Map") {
    For Key, Value in Array {
      if (IsObject(Value)) {
        ItemID := ogcTreeView.Add('["' Key '"] (' type(Value) ')', ParentID, "Expand")
        Obj_Gui(Value, ItemID)
      } else {
        ogcTreeView.Add('["' Key '"] (' type(Value) ')  =  ' Value, ParentID, "Expand")
      }
    }
    aMethods := ["Count", "Capacity", "CaseSense", "Default", "__Item"]
    for index, PropName in aMethods {
      try ogcTreeView.Add("." PropName " (" type(Array.%PropName%) ")  =  " Array.%PropName%, ParentID, "Expand")
    }

  }
  try{
    For PropName, PropValue in Array.OwnProps(){
      if (IsObject(PropValue)){
        ItemID := ogcTreeView.Add("." PropName " (" type(PropValue) ")", ParentID, "Expand")
        Obj_Gui(PropValue, ItemID)
      }
      else{
        ogcTreeView.Add("." PropName " (" type(PropValue) ")  =  " PropValue, ParentID, "Expand")
      }
    }
  }
  if (type(Array) = "Func"){
    aMethods := ["Name", "IsBuiltIn", "IsVariadic", "MinParams", "MaxParams"]
    for index, PropName in aMethods{
      ogcTreeView.Add("." PropName " (" type(Array.%PropName%) ")  =  " Array.%PropName%, ParentID, "Expand")
    }
  }
  if (type(Array) = "Buffer"){
    aMethods := ["Prt","Size"]
    for index, PropName in aMethods{
      try ogcTreeView.Add("." PropName " (" type(Array.%PropName%) ")  =  " Array.%PropName%, ParentID, "Expand")
    }
  }
  if (type(Array) = "Gui"){
    aMethods := ["BackColor", "FocusedControl", "Hwnd", "MarginX", "MarginY", "Name", "Title"]
    for index, PropName in aMethods{
      try ogcTreeView.Add("." PropName " (" type(Array.%PropName%) ")  =  " Array.%PropName%, ParentID, "Expand")
    }
    For Hwnd, oCtrl in Array{
      ItemID := ogcTreeView.Add("__Enum[" Hwnd "] (" Type(oCtrl) ")", ParentID, "Expand")
      Obj_Gui(oCtrl, ItemID)
    }
  }
  if (SubStr(type(Array),1,4)="Gui."){
    aMethods := ["ClassNN", "Enabled", "Focused", "Hwnd", "Name", "Text", "Type", "Value", "Visible"]
    for index, PropName in aMethods {
      try ogcTreeView.Add("." PropName " (" type(Array.%PropName%) ")  =  " Array.%PropName%, ParentID, "Expand")
    }
    ogcTreeView.Add(".Gui (Gui)", ParentID, "Expand")
  }

  return

  Gui_Size(thisGui, MinMax, Width, Height) {
    if MinMax = -1	; The window has been minimized. No action needed.
      return
    DllCall("LockWindowUpdate", "Uint", thisGui.Hwnd)
    For Hwnd, GuiCtrlObj in thisGui {
      GuiCtrlObj.GetPos(&cX, &cY, &cWidth, &cHeight)
      GuiCtrlObj.Move(, , Width - cX, Height -cY)
    }
    DllCall("LockWindowUpdate", "Uint", 0)
  }

  ContextMenu_TreeView(GuiCtrlObj , Item, IsRightClick, X, Y){
    SelectedItemID := GuiCtrlObj.GetSelection()
    RetrievedText := GuiCtrlObj.GetText(SelectedItemID)
    Value := RegExReplace(RetrievedText,".*?\)\s\s=\s\s(.*)","$1")
    ItemID := SelectedItemID

    ParentText := ""
    ParentItemID := ItemID
    loop{
      if (ParentItemID=0){
        break
      }
      RetrievedParentText := GuiCtrlObj.GetText(ParentItemID)
      ParentText := RegExReplace(RetrievedParentText, "(.*?)\s.*", "$1") ParentText
      ParentItemID := GuiCtrlObj.GetParent(ParentItemID)
    }

    Menu_TV := Menu()
    if(InStr(RetrievedText, ")  =  ")){
      Menu_TV.Add("Copy [" Value "]",(*)=>(A_Clipboard:= Value, Tooltip2("Copied [" Value "]")))
      Menu_TV.SetIcon("Copy [" Value "]", "Shell32.dll", 135)
    }
    Menu_TV.Add("Copy [" ParentText "]", (*) => (A_Clipboard := ParentText, Tooltip2("Copied [" ParentText "]")))
    Menu_TV.SetIcon("Copy [" ParentText "]", "Shell32.dll", 135)
    Menu_TV.Show()
  }

  Tooltip2(Text := "", X := "", Y := "", WhichToolTip := "") {
    ToolTip(Text, X, Y, WhichToolTip)
    SetTimer () => ToolTip(), -3000
  }
}
EditGui(Input){
  Output := Input
  Gui_Edit := Gui()
  Gui_Edit.Opt("+Resize")
  Gui_Edit.OnEvent("Size", Gui_Size)
  Gui_Edit.OnEvent("Close", Gui_Close)
  Gui_Edit.MarginX := "0", Gui_Edit.MarginY := "0"
  if (Type(Input)="Array") {
    ogcEdit := Gui_Edit.AddListView("w300 r" Input.Length+2 " -ReadOnly -Sort -Hdr",["Edit"])
    ogcEdit.OnEvent("ContextMenu", LV_ContextMenu)
    for Index, Value in Input{
      ogcEdit.Add(, Value)
    }
    ogcEdit.ModifyCol(1,300-5)
  } else if (!IsObject(Input)){
    ogcEdit := Gui_Edit.AddEdit("w300 h200 +multi", Input)
  } else{
    MsgBox("Input with type [" type(Input) "] is not yet supported.")
    return Input
  }
  Gui_Edit.Title := "Edit Gui (" Type(Input) ")"

  ;Reload menu for testing
  ; Menus := MenuBar()
  ; Menus.Add("&Reload", (*) => (Reload()))
  ; Gui_Edit.MenuBar := Menus

  Gui_Edit.Show()
  HotIfWinActive "ahk_id " Gui_Edit.Hwnd
  Hotkey "Delete", ClearRows
  WinWaitClose(Gui_Edit)
  Hotkey "Delete", "Off"
  return Output

  Gui_Size(thisGui, MinMax, Width, Height) {
    if MinMax = -1	; The window has been minimized. No action needed.
      return
    DllCall("LockWindowUpdate", "Uint", thisGui.Hwnd)
    if (Type(Input) = "Array"){
      ogcEdit.ModifyCol(1, Width - 5)
    }
    For Hwnd, GuiCtrlObj in thisGui {
      GuiCtrlObj.GetPos(&cX, &cY, &cWidth, &cHeight)
      GuiCtrlObj.Move(, , Width - cX, Height - cY)
    }
    DllCall("LockWindowUpdate", "Uint", 0)
  }
  Gui_Close(thisGui){
    if (Type(Input) = "Array"){
      Loop ogcEdit.GetCount()
      {
        Output[A_index] := ogcEdit.GetText(A_Index)
      }
    }
    else{
      Output := ogcEdit.text
    }
  }
  LV_ContextMenu(LV, Item, IsRightClick, X, Y){
    Rows := LV.GetCount()
    Row := LV.GetNext()
    ContextMenu := Menu()
    ContextMenu.Add("Edit", (*) => (PostMessage(LVM_EDITLABEL := 0x1076, Row - 1, 0, , "ahk_id " LV.hwnd)))
    ContextMenu.SetIcon("Edit","shell32.dll", 134)
    ((Rows = 0 or row=0) && ContextMenu.Disable("Edit"))
    ContextMenu.Add()
    ContextMenu.Add("Insert item", (*)=> (LV.Modify(, "-Select -focus"), LV.Insert(Row, "Select", ""), Output.InsertAt(Row,""),PostMessage(LVM_EDITLABEL := 0x1076, Row-1, 0, , "ahk_id " LV.hwnd)))
    ContextMenu.SetIcon("Insert item", "netshell.dll", 98)
    ((Rows = 0 or row = 0) && ContextMenu.Disable("Insert item"))
    ContextMenu.Add("Insert item below", (*)=> (Row:= LV.GetNext() + 1, LV.Modify(, "-Select -focus"),LV.Insert(Row, "Select", ""), Output.InsertAt(Row, ""),PostMessage(LVM_EDITLABEL := 0x1076, Row - 1, 0, , "ahk_id " LV.hwnd)))
    ContextMenu.SetIcon("Insert item below", "comres.dll", 5)
    ContextMenu.Add()
    ContextMenu.Add("Delete", ClearRows)
    ContextMenu.SetIcon("Delete", "Shell32.dll", 132)
    ((Rows = 0 or row = 0) && ContextMenu.Disable("Delete"))
    ContextMenu.Show()
  }
  ClearRows(*) {
    RowNumber := 0	; This causes the first iteration to start the search at the top.
    Loop {
      RowNumber := ogcEdit.GetNext(RowNumber - 1)
      if not RowNumber	; The above returned zero, so there are no more selected rows.
        break
      ogcEdit.Delete(RowNumber)	; Clear the row from the ListView.
      Output.RemoveAt(RowNumber)
    }
  }
}

dbgvar(args*) { ; autohotkey.com/boards/viewtopic.php?f=83&t=123206#p547596
  static LogFunc          	:= {msg:MsgBox, tt:Tooltip, print:(x)=>FileAppend(x,"*"), dbg:OutputDebug, log:(x)=>FileAppend(x,"tmp.log")}.msg
    , t                   	:= "txt"
    , SerializeFunc       	:= (t="txt") ? Object2Str : Obj_Gui
    , FormatFunc          	:= {Terse:(info)=>Format("{1} ⟹ {2}",info.expression,info.value), Verbose:(info)=>SerializeFunc(info)}.Terse
    , ReadLineFromFile    	:= (file,lineNo)=>StrSplit(FileRead(file),"`n","`r")[lineNo]
    , funcName            	:= A_ThisFunc
    , FindExpressionInLine	:= ((line) => RegExMatch(line, "^\s*" funcName " (.+)$", &mo) ? mo[1] : RegExMatch(line, "\b" funcName "\(((?:[^()]+|(?>\((?1)\)))+)\)", &mo) ? Substr(mo[0], StrLen(funcName) + 2, -1) : "Expression not found; line context = " line)
    , Cache               	:= Map()
  try throw Error(, -1)
  catch as err {
    valStr := SerializeFunc(args) , args.length ? valStr := SubStr(valStr,2,-1) : 0
    if not Cache.Has(fileLineKey := err.File "//" err.Line) {
      Cache.Set(fileLineKey, Trim(ReadLineFromFile(err.File, err.Line)))
    }
    if t = "txt" {
      LogFunc(FormatFunc({
        expression	: FindExpressionInLine(Cache[fileLineKey]),
        value     	: valStr,
        file      	: err.File,
        lineNo    	: err.Line,
        lineText  	: Cache[fileLineKey] }))
    }
  }
  return args.length == 1 ? args[1] : args
}
dbgvar_o(args*) { ; autohotkey.com/boards/viewtopic.php?f=83&t=123206#p547596
  static LogFunc          	:= {msg:MsgBox, tt:Tooltip, print:(x)=>FileAppend(x,"*"), dbg:OutputDebug, log:(x)=>FileAppend(x,"tmp.log")}.msg
    , t                   	:= "obj"
    , SerializeFunc       	:= (t="txt") ? Object2Str : Obj_Gui
    , FormatFunc          	:= { Terse: (info) => Format("{1} ⟹ {2}", info.expression, info.value), Verbose: (info) => SerializeFunc(info) }.Terse
    , ReadLineFromFile    	:= (file, lineNo) => StrSplit(FileRead(file), "`n", "`r")[lineNo]
    , funcName            	:= A_ThisFunc
    , FindExpressionInLine	:= ((line) => RegExMatch(line, "^\s*" funcName " (.+)$", &mo) ? mo[1] : RegExMatch(line, "\b" funcName "\(((?:[^()]+|(?>\((?1)\)))+)\)", &mo) ? Substr(mo[0], StrLen(funcName) + 2, -1) : "Expression not found; line context = " line)
    , Cache               	:= Map()
  try throw Error(, -1)
  catch as err {
    valStr := SerializeFunc(args), args.length ? valStr := SubStr(valStr, 2, -1) : 0
    if not Cache.Has(fileLineKey := err.File "//" err.Line)
      Cache.Set(fileLineKey, Trim(ReadLineFromFile(err.File, err.Line)))
    if t = "txt" {
      LogFunc(FormatFunc({
        expression	: FindExpressionInLine(Cache[fileLineKey]),
        value     	: valStr,
        file      	: err.File,
        lineNo    	: err.Line,
        lineText  	: Cache[fileLineKey] }))
    }
  }
  return args.length == 1 ? args[1] : args
}
