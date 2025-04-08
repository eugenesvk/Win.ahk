#Requires AutoHotKey 2.1-alpha.18

hk🛈(key, act, opt:="", help) { ; same as Builtin Hotkey, but can use ⇧ and add help message
  static k	:= keyConstant._map ; various key name constants, gets vk code to avoid issues with another layout
   , s    	:= helperString
   , pre  	:= '$~' ; use $kbd hook and don't ~block input to avoid typing lag
   , k→a := s.key→ahk.Bind(helperString)  ; ⎇⇧c or !+c ⟶ !+vk43
  k_ahk := k→a(key)
  if help_keys.has(k_ahk) {
    throw ValueError("Duplicate hotkey being registered!", -1, key " or " k_ahk)
  } else {
    help['k'] := key
    help['vk'] := "x" ; todo: convert key to helper format automatically, no need to require explicit ⌥⇧c​
    help_keys[k_ahk] := help
  }
  HotKey(k_ahk, act, opt)
}

get_help() { ; Show a listview with all the registered hk🛈 hotkeys and their help🛈
  _d:=0
  ; todo: add separate columns for modifier to make them sorted and a column for key
  guiKeyHelp := Gui()
  LV := guiKeyHelp.Add("ListView", "r20 w700", ["Key", "AHKey", "H", "File", "l№"])
  LV.OnEvent("DoubleClick", LV_DoubleClick)  ; Notify the script whenever the user double clicks a row
  for ahkey, help_map in help_keys {
    LV.Add(, help_map["k"], ahkey, help_map["h"], help_map["f"], help_map["l№"])
  }
  LV.ModifyCol()  ; Auto-size each column to fit its contents.
  ; LV.ModifyCol(2, "Integer")  ; for sorting purposes, indicate that column 2 is an integer
  guiKeyHelp.Show() ; Display the window

  LV_DoubleClick(LV, RowNumber) { ; todo: open file/line number
    RowText := LV.GetText(RowNumber)  ; Get the text from the row's first field
    dbgTT(0, "Double-clicked row " RowNumber ". Text: '" RowText "'")
  }
}
