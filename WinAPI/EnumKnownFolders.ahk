#Requires AutoHotKey 2.1-alpha.4
; v1 @ autohotkey.com/boards/viewtopic.php?t=82925
; v2 @ autohotkey.com/boards/viewtopic.php?f=83&t=97513
global Borderless	:= True
  , WS_Caption   	:= 0x00C00000 ; Title bar (WS_BORDER + WS_DLGFRAME)
  , WS_SizeBox   	:= 0x00040000 ; Sizing border (=WS_THICKFRAME)
  , WS_Borderless	:= WS_Caption|WS_SizeBox ; BitwiseOR (logical inclusive OR)

KFProps := ["Name","GUID","CSIDL","LocalizedName","Category","Path"
  ,"ParsingName","Parent","RelativePath","Description","ToolTip","Icon"
  ,"Security","Attributes","Flags","Type"]
; --------------------------------------------------
KF := EnumKnownFolders()
; --------------------------------------------------
LVMainColName:= ["#","GUID","CSIDL","Name","Name (Localized)","Category"]
gMain := Gui()
mainStyle := ""
  , mainStyle .= " " (Borderless ? "-" WS_Borderless : "")
  ; , mainStyle .= " " "-Border"
  ; , mainStyle .= " " "+Resize"
gMain.Opt(mainStyle)
gMain.MarginX := 0, gMain.MarginY := 0 ; Disables padding
gMain.Title := "KnownFolders"
gMain.OnEvent("Close", gMainClose)
gMain.SetFont("s10", "Lucida Console")
lvS := "" ; ListView style
  , lvS .= ' ' "LV0x10000"	; Paints via double-buffering, which reduces flicker
  , lvS .= ' ' "LV0x100"  	; Enables flat scroll bars
  ; , lvS .= ' ' "x0 y0"  	; Disables left/top padding
gMainLV := gMain.Add("ListView", opt:="w1000 r30 Grid Count200" lvS, col:=LVMainColName)
gMainLV.OnEvent("DoubleClick", gMainLV_DoubleClick)
For i, P in KF {
  gMainLV.Add("",i,P["GUID"],P["CSIDL"],P["Name"],P["LocalizedName"],P["Category"])
}
Loop gMainLV.GetCount("Column")
  gMainLV.ModifyCol(A_Index, "AutoHdr")
gMainLV.ModifyCol(1, "Integer")
gMain.Show()
; --------------------------------------------------
LVPropColName := ["Property","Value"]
gProp := Gui()
gProp.Opt("+Owner" gMain.Hwnd)
gProp.OnEvent("Close" , gPropClose)
gProp.OnEvent("Escape", gPropClose)
gProp.SetFont("s10", "Lucida Console")
gPropLV := gProp.Add("ListView", "w1100 r20 Grid Count20", LVPropColName)
Return
; --------------------------------------------------
gMainLV_DoubleClick(gMainLV, rowNu) {
  gPropLV.Delete()
  FolderProps := KF[rowNu]
  for i, p in KFProps {
    field := FolderProps.Has(p) ? FolderProps[p] : ""
    gPropLV.Add("", p, field)
  }
  gPropLV.ModifyCol(1, "AutoHdr")
  gPropLV.ModifyCol(2, "AutoHdr")
  gProp.Title := "Properties"
  gMain.Opt("+Disabled")
  gProp.Opt("-Disabled")
  gProp.Show()
  }
; --------------------------------------------------
gPropClose(thisGui) {
  gMain.Opt("-Disabled")
  gProp.Opt("+Disabled")
  gProp.Hide()
  gMain.Show()
  }
gMainClose(thisGui) {
  ExitApp()
  }
; ==================================================
EnumKnownFolders() {
  Static Categories	:= ["VIRTUAL","FIXED","COMMON","PERUSER"]
  Static Δs        	:= [A_PtrSize,A_PtrSize,A_PtrSize, 16 ,A_PtrSize
    ,A_PtrSize,A_PtrSize,A_PtrSize,A_PtrSize,A_PtrSize
    , 4 ,4]
  Δ:=0, IKFM:=0, IKF:=0, KFID:=0, CID:=0, CSIDL:=0, KFD:=Buffer(40+(A_PtrSize*9), 0)
  if !(IKFM := IKnownFoldersManager_Create())
    return False
  if !IKnownFoldersManager_GetFolderIds(IKFM, &KFID, &CID)
    return False
  KnownFolders := Map()
  pKNID := KFID ; pointer to the current KNOWNFOLDERID
  Loop CID {
    if !IKnownFoldersManager_GetFolder(IKFM, pKNID, &IKF)
      Continue
    Properties := Map("GUID", GUID2→str(pKNID))
    if IKnownFoldersManager_FolderIdToCsidl(IKFM, pKNID, &CSIDL) {
      Properties["CSIDL"] := CSIDL
    } else {
      Properties["CSIDL"] := ""
    }
    if IKnownFolder_GetFolderDefinition(IKF, &KFD) {
      addr                       	:= NumGet(KFD, Δ:=0     , "UInt")
      Properties["Category"]     	:= addr ? Categories[addr]      : ""
      addr                       	:= NumGet(KFD, Δ+=Δs[1] , "UPtr")
      Properties["Name"]         	:= addr ? StrGet(addr,"UTF-16") : ""
      addr                       	:= NumGet(KFD, Δ+=Δs[2] , "UPtr")
      Properties["Description"]  	:= addr ? StrGet(addr,"UTF-16") : ""
      Properties["Parent"]       	:= GUID2→str(KFD.Ptr+(Δ+=Δs[3]))
      addr                       	:= NumGet(KFD, Δ+=Δs[4] , "UPtr")
      Properties["RelativePath"] 	:= addr ? StrGet(addr,"UTF-16") : ""
      addr                       	:= NumGet(KFD, Δ+=Δs[5] , "UPtr")
      Properties["ParsingName"]  	:= addr ? StrGet(addr,"UTF-16") : ""
      addr                       	:= NumGet(KFD, Δ+=Δs[6] , "UPtr")
      ToolTip                    	:= addr ? StrGet(addr,"UTF-16") : ""
      if (SubStr(ToolTip,1,1)    	= "@")
        ToolTip                  	:= GetMUIString(ToolTip)
      Properties["ToolTip"]      	:= ToolTip
      addr                       	:= NumGet(KFD, Δ+=Δs[7], "UPtr")
      LocalName                  	:= addr ? StrGet(addr,"UTF-16") : ""
      if (SubStr(LocalName,1,1)  	= "@")
        LocalName                	:= GetMUIString(LocalName)
      Properties["LocalizedName"]	:= LocalName
      addr                       	:= NumGet(KFD, Δ+=Δs[8], "UPtr")
      Properties["Icon"]         	:= addr ? StrGet(addr,"UTF-16") : ""
      addr                       	:= NumGet(KFD, Δ+=Δs[9], "UPtr")
      Properties["Security"]     	:= addr ? StrGet(addr,"UTF-16") : ""
      addr                       	:= NumGet(KFD, Δ+=Δs[10], "UInt")
      Properties["Attributes"]   	:= Format("0x{:08X}",addr)
      addr                       	:= NumGet(KFD, Δ+=Δs[11], "UInt")
      Properties["Flags"]        	:= Format("0x{:08X}",addr)
      Properties["Type"]         	:= GUID2→str(KFD.Ptr+(Δ+=Δs[12]))
      FreeKnownFolderDefinitionFields(KFD.Ptr)
    }
    if IKnownFolder_GetPath(IKF, &Path)
      Properties["Path"] := Path
    KnownFolders[A_Index] := Properties
    ObjRelease(IKF)
    pKNID += 16 ; switch to the next KNOWNFOLDERID
  }
  DllCall("Ole32.dll\CoTaskMemFree", "Ptr",KFID)
  return KnownFolders
  }
IKnownFoldersManager_Create() { ; IKnownFoldersManager interface docs.microsoft.com/en-us/windows/win32/api/shobjidl_core/nn-shobjidl_core-iknownfoldermanager
  ; Creates a IKNOWNFOLDERSMANAGER interface and returns its pointer on success.
  Static SCLSID_KnownFoldersManager := "{4DF0C730-DF9D-4AE3-9153-AA6B82E9795A}"
    ,    SIID_IKnownFoldersManager  := "{8BE2D872-86AA-4d47-B776-32CCA40C7018}"
  if !(IKFM := ComObject(SCLSID_KnownFoldersManager, SIID_IKnownFoldersManager))
    return False
  return IKFM
  }
IKnownFoldersManager_FolderIdToCsidl(IKFM, pKNID, &CSIDL) {
  ; Gets the legacy CSIDL value that is the equivalent of a given KNOWNFOLDERID docs.microsoft.com/en-us/windows/win32/api/shobjidl_core/nf-shobjidl_core-iknownfoldermanager-folderidtocsidl
  IKFM0 := ComObjValue(IKFM)
  FolderIdToCsidl := NumGet(NumGet(IKFM0, "Uptr"), A_PtrSize*4, "UPtr")
  return !DllCall(FolderIdToCsidl, "Ptr",IKFM, "Ptr",pKNID, "Int*",&CSIDL, "UInt")
  }
IKnownFoldersManager_GetFolderIds(   IKFM, &KFID, &CID) {
  ; Gets an array of all registered known folder IDs. This can be used in enumerating all known folders. docs.microsoft.com/en-us/windows/win32/api/shobjidl_core/nf-shobjidl_core-iknownfoldermanager-getfolderids
  IKFM0 := ComObjValue(IKFM)
  GetFolderIds := NumGet(NumGet(IKFM0, "Uptr"), A_PtrSize*5, "UPtr")
  return !DllCall(GetFolderIds, "Ptr",IKFM, "Ptr*",&KFID, "Int*",&CID, "UInt")
  }
IKnownFoldersManager_GetFolder(      IKFM, pFolderID, &IKF) {
  ; Gets an object that represents a known folder identified by its KNOWNFOLDERID. docs.microsoft.com/en-us/windows/win32/api/shobjidl_core/nf-shobjidl_core-iknownfoldermanager-getfolder
  IKFM0 := ComObjValue(IKFM)
  GetFolder := NumGet(NumGet(IKFM0, "Uptr"), A_PtrSize*6, "UPtr")
  return !DllCall(GetFolder, "Ptr",IKFM, "Ptr",pFolderID, "Ptr*",&IKF, "UInt")
  }
IKnownFoldersManager_Release(        IKFM) { ; Releases the IKNOWNFOLDERSMANAGER interface
  return ObjRelease(IKFM)
  }

; IKnownFolder interface docs.microsoft.com/en-us/windows/win32/api/shobjidl_core/nn-shobjidl_core-iknownfolder; docs.microsoft.com/en-us/windows/win32/api/shobjidl_core/nf-shobjidl_core-iknownfolder-getfolderdefinition
IKnownFolder_GetFolderDefinition(IKF, &KFD) {
  ; Retrieves a structure that contains the defining elements of a known folder, which includes the folder's category, name, path, description, tooltip, icon, and other properties.
  GetFolderDefinition := NumGet(NumGet(IKF, "Uptr"), A_PtrSize*11, "UPtr")
  KFD := Buffer(40+(A_PtrSize*9), 0)
  return !DllCall(GetFolderDefinition, "Ptr",IKF, "Ptr",KFD.Ptr, "UInt")
  }
IKnownFolder_GetPath(IKF, &Path, Flags := 0) { ; Retrieves the path of a known folder as a string. ; docs.microsoft.com/en-us/windows/win32/api/shobjidl_core/nf-shobjidl_core-iknownfolder-getpath
  Path:= "", KFP:=0
  GetPath	:= NumGet(NumGet(IKF, "Uptr"), A_PtrSize*6, "UPtr")
  HR     	:= DllCall(GetPath, "Ptr",IKF, "UInt",Flags, "Ptr*",&KFP, "UInt")
  if !(HR) {
    Path := StrGet(KFP, "UTF-16")
    DllCall("Ole32.dll\CoTaskMemFree", "Ptr",KFP)
  }
  return !HR
  }

; Auxiliary functions
ExpandEnvironmentStrings(Str) {
  Chars:=DllCall("ExpandEnvironmentStrings", "Ptr",StrPtr(Str), "Ptr",0  , "UInt",0   , "Int")
  if (Chars) {
    VarSetStrCapacity(&Exp, ++Chars << !!1)
    DllCall(     "ExpandEnvironmentStrings", "Ptr",StrPtr(Str), "Str",Exp, "UInt",Chars, "Int")
    return Exp
  }
  return Str
  }
FreeKnownFolderDefinitionFields(KFD) {
  Static OffSets := [A_PtrSize,A_PtrSize,A_PtrSize+16,A_PtrSize,A_PtrSize,A_PtrSize,A_PtrSize,A_PtrSize]
  Offset := 0
  for i, v in Offsets {
    Offset += v
    DllCall("Ole32.dll\CoTaskMemFree", "Ptr",NumGet(KFD + OffSet, "UPtr"))
  }
  }
GetMUIString(ResPath) {
  if InStr(ResPath, "%")
    ResPath := ExpandEnvironmentStrings(ResPath)
  ResStr:="", ResPtr:=0
  ResSplit := StrSplit(ResPath, [",", ";"], "@-")
  idRes2   := IsInteger(ResSplit[2]) ? ResSplit[2] : 0
  HMUI := DllCall("LoadLibraryEx", "Str",ResSplit[1], "Ptr",0, "UInt",0x00000020, "UPtr")
  Size := DllCall("LoadStringW"  , "Ptr",HMUI, "UInt",idRes2, "Ptr*",&ResPtr, "Int",0, "Int")
  if (Size)
    ResStr := StrGet(ResPtr, Size, "UTF-16")
  DllCall("FreeLibrary", "Ptr",HMUI)
  return (ResStr ? ResStr : ResPath)
  }
GUID2→str(PGUID) {
  SGUID := Buffer(128, 0)
  CC    := DllCall("Ole32.dll\StringFromGUID2", "Ptr",PGUID, "Ptr",SGUID.Ptr, "Int",64, "Int")
  return StrGet(SGUID.Ptr, CC, "UTF-16")
  }
