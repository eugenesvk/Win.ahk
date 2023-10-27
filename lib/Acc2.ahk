/* Acc.ahk Standard Library
  by Sean
  Updated by jethrow:
    Modified ComObjEnwrap params from (9,pacc) --> (9,pacc,1)
    Changed ComObjUnwrap to ComObjValue in order to avoid AddRef (thanks fincs)
    Added Acc_GetRoleText & Acc_GetStateText
    Added additional functions - commented below
    Removed original Acc_Children function
  v1 last updated 2/19/2012
  Converted to v2 by eugenesv 2021-12-03, last updated 2023-09-07:
    converter helpers:
      github.com/mmikeww/AHK-v2-script-converter
      github.com/FuPeiJiang/ahk_parser.js
    some notable changes:
    Removed a lot of inlining as it made the code unreadable
    ComObjEnwrap(9,pacc,1) → ComObjFromPtr(pacc)
    Added from another other Acc version @ github.com/Drugoy/Autohotkey-scripts-.ahk/blob/master/Libraries/Acc.ahk
      + Acc_ChildrenByRole
      + Acc_Get
      + Acc_SetWinEventHook
      + Acc_UnhookWinEvent
    Fixed a bunch of critical, but silent errors
  ; Used in a working example, should be ok? :)
    Acc_GetRoleText
    Acc_Role
    Acc_ChildrenByRole
    Acc_Children
    Acc_ObjectFromWindow
    Acc_Get
    Acc_Query
    Acc_Location

    Acc_Error
    Acc_Init
  ; not used
    Acc_ObjectFromEvent
    Acc_ObjectFromPoint
    Acc_WindowFromObject
    Acc_GetStateText
    Acc_SetWinEventHook
    Acc_UnhookWinEvent
    Acc_State
    Acc_Parent
    Acc_Child

*/
#Include <constWin32alt>
#DllLoad oleacc

Acc_Init(){
  static h	:= 0
  If Not h {
    h := DllCall("LoadLibrary", "Str","oleacc", "Ptr")
  }
}
Acc_ObjectFromEvent(&_idChild_, hWnd, idObject, idChild){
  Acc_Init()
  vChild := Buffer(8+2*A_PtrSize, 0)
  If DllCall("oleacc\AccessibleObjectFromEvent"
    , "Ptr" 	, hWnd      	;   [in]  HWND        hwnd
    , "UInt"	, idObject  	;   [in]  DWORD       dwId
    , "UInt"	, idChild   	;   [in]  DWORD       dwChildId
    , "Ptr*"	, &pacc:=0  	;   [out] IAccessible **ppacc
    , "Ptr" 	, vChild.Ptr	;   [out] VARIANT     *pvarChild
    )=0
  _idChild_ := NumGet(vChild, 8, "UInt")
  return ComObjFromPtr(pacc)
}

Acc_ObjectFromPoint(&_idChild_:="", x:="",y:=""){
  Acc_Init()
  DllCall("GetCursorPos", "Int64*",&pt:=0)
  if not (x==""||y=="")
    pt := x&0xFFFFFFFF|y<<32
  vChild	:= Buffer(8+2*A_PtrSize, 0)
  accObj := DllCall("oleacc\AccessibleObjectFromPoint"
    , "Int64"	, pt
    , "Ptr*" 	, &pacc:=0
    , "Ptr"  	, vChild.Ptr)
  if (accObj = 0) {
    _idChild_ := NumGet(vChild, 8, "UInt")
    Return ComObjFromPtr(pacc)
  }
}

Acc_ObjectFromWindow(hWnd, idObject:=-4){ ; OBJID_WINDOW:=0, OBJID_CLIENT:=-4
  Acc_Init()
  capIID     	:= 16
  bIID       	:= Buffer(capIID)
  idObject   	&= 0xFFFFFFFF
  numberA    	:= idObject==0xFFFFFFF0 ? 0x0000000000020400 : 0x11CF3C3D618736E0
  numberB    	:= idObject==0xFFFFFFF0 ? 0x46000000000000C0 : 0x719B3800AA000C81
  addrPostIID	:= NumPut("Int64",numberA, bIID)
  addrPPIID  	:= NumPut("Int64",numberB, addrPostIID)
  gotObject  	:= DllCall("oleacc\AccessibleObjectFromWindow"
    , "Ptr"  	, hWnd
    , "UInt" 	, idObject
    , "Ptr"  	, -capIID + addrPPIID
    , "Ptr*" 	, &pacc:=0
    )
  if (gotObject = 0) {
    return ComObjFromPtr(pacc)
  }
}

Acc_WindowFromObject(pacc){
  static win32:=win32Constant, com:=win32.comT, IID:=win32.IID ; win32 API COM/IID constants
  ; AccPtr := ComObjValue(pacc)
  AccPtr := ComObjQuery(pacc, IID.IAccessible)	; (for DllCall) Pointer to the container object's IAccessible interface
  If DllCall("oleacc\WindowFromAccessibleObject"
    , "Ptr" 	, IsObject(pacc) ? AccPtr : pacc
    , "Ptr*"	, &hWnd:=0
    )=0
    return hWnd
}

Acc_GetRoleText(nRole){
  if !IsInteger(nRole) { ; autohotkey.com/boards/viewtopic.php?t=93790&view=unread#p438664
    return "Unknown object" ;;; bug in Acc_Role?, shouldn't Acc.accRole(ChildId) always return a number?
  }
  nSize := DllCall("oleacc\GetRoleText"
    , "Uint"	, nRole
    , "Ptr" 	, 0
    , "Uint"	, 0)
  VarSetStrCapacity(&sRole, 2*nSize)
  DllCall("oleacc\GetRoleText"
    , "Uint"	, nRole
    , "str" 	, sRole
    , "Uint"	, nSize+1)
  return sRole
}

Acc_GetStateText(nState){
  nSize := DllCall("oleacc\GetStateText"
    , "Uint"	, nState
    , "Ptr" 	, 0
    , "Uint"	, 0)
  VarSetStrCapacity(&sState, 2*nSize)
  DllCall("oleacc\GetStateText"
    , "Uint"	, nState
    , "str" 	, sState
    , "Uint"	, nSize+1)
  return sState
}
Acc_SetWinEventHook(eventMin, eventMax, pCallback) {
  Return  DllCall("SetWinEventHook", "Uint", eventMin, "Uint", eventMax, "Uint", 0, "Ptr", pCallback, "Uint", 0, "Uint", 0, "Uint", 0)
}
Acc_UnhookWinEvent(hHook) {
  Return  DllCall("UnhookWinEvent", "Ptr", hHook)
}
/* Win Events:
  pCallback := RegisterCallback("WinEventProc")
  WinEventProc(hHook, event, hWnd, idObject, idChild, eventThread, eventTime) {
    Critical
    Acc := Acc_ObjectFromEvent(_idChild_, hWnd, idObject, idChild)
    ; Code Here:
  }
*/

; Written by jethrow
Acc_Role(Acc, ChildId:=0) {
  try return ComObjType(Acc,"Name")="IAccessible"?Acc_GetRoleText(Acc.accRole(ChildId)):"invalid object"
}
Acc_State(Acc, ChildId:=0) {
  try return ComObjType(Acc,"Name")="IAccessible"?Acc_GetStateText(Acc.accState(ChildId)):"invalid object"
}
Acc_Error(p:="") {
  static setting:=0
  return p = "" ? setting : setting:=p
}
Acc_Children(Acc) { ;;; sometimes errors with 0xc0000005, reason unknown
  static win32:=win32Constant, com:=win32.comT, IID:=win32.IID ; win32 API COM/IID constants
  if (ComObjType(Acc,"Name") != "IAccessible") {
    NewError := Error("Invalid IAccessible Object" , -1)
  } else {
    Acc_Init()
    cChildren 	:= Acc.accChildCount
    retCountCh	:= 0
    if (cChildren=0) {
      return 0
    }
    Children   	:= []
    sizeVariant	:= (8+2*A_PtrSize) ; VARIANT=24:16
    vChildren  	:= Buffer(cChildren*sizeVariant, 0) ;;;VARIANT* pArray = new VARIANT[childCount];

    avChildren := ComObjArray(com.var, cChildren) ;
    ; AccPtr := ComObjValue(Acc)               	; (for DllCall) Pointer to the container object's IAccessible interface
    AccPtr := ComObjQuery(Acc, IID.IAccessible)	; (for DllCall) Pointer to the container object's IAccessible interface
    gotChildren := DllCall("oleacc\AccessibleChildren"
      , "Ptr" 	, AccPtr        	; IAccessible	*paccContainer
      , "Int" 	, 0             	; LONG       	 iChildStart
      , "Int" 	, cChildren     	; LONG       	 cChildren
      , "Ptr" 	, vChildren.Ptr 	; VARIANT    	*rgvarChildren
      , "Int*"	, &retCountCh:=0	; LONG       	*pcObtained
      )

    VARIANT_preUnion_Sz := 2+3*2 ; docs.microsoft.com/en-us/windows/win32/api/oaidl/ns-oaidl-variant
      ; typedef unsigned short VARTYPE
      ; 3×WORD    wReserved1,2,3;
    if (gotChildren = 0) {
      ; return [avChildren*]  ; Create an Array from the SAFEARRAY instead of querying each child autohotkey.com/boards/viewtopic.php?f=82&t=107471#p478792
      Loop retCountCh {
        i     	:= (A_Index-1)*sizeVariant + VARIANT_preUnion_Sz
        child 	:= NumGet(vChildren, i  , "Int64") ; llVal ?
        childX	:= NumGet(vChildren, i-8, "Int64") ; vt ?
        if (childX = 9) {
          AccChild := Acc_Query(child)
          Children.Push(AccChild)
          dbgRC := ObjRelease(child)
        } else {
          Children.Push(child)
        }
      }
      return Children.Length ? Children : 0
    } else {
      NewError := Error("AccessibleChildren DllCall Failed" , -1)
    }
  }
  NewError := Error("" , -1)
  if Acc_Error() {
    throw NewError
  }
  msgResult:=MsgBox("File:  " NewError.file "`nLine: " NewError.line "`n`nContinue Script?", , 262420)
  if (msgResult = "No") {
    ExitApp()
  }
}
Acc_ChildrenByRole(Acc, Role) {
  static win32:=win32Constant, com:=win32.comT, IID:=win32.IID ; win32 API COM/IID constants
  if (ComObjType(Acc,"Name") != "IAccessible") {
    NewError := Error("Invalid IAccessible Object" , -1)
  } else {
    Acc_Init()
    cChildren := Acc.accChildCount
    Children  := []
    vChildren := Buffer(cChildren*(8+2*A_PtrSize), 0)
    ; AccPtr := ComObjValue(Acc)               	; (for DllCall) Pointer to the container object's IAccessible interface
    AccPtr := ComObjQuery(Acc, IID.IAccessible)	; (for DllCall) Pointer to the container object's IAccessible interface
    gotChildren := DllCall("oleacc\AccessibleChildren"
      , "Ptr" 	, AccPtr
      , "Int" 	, 0
      , "Int" 	, cChildren
      , "Ptr" 	, vChildren.Ptr
      , "Int*"	, &cChildren)
    if (gotChildren = 0) {
      Loop cChildren {
        i     	:= (A_Index-1)*(A_PtrSize*2+8)+8
        child 	:= NumGet(vChildren, i  , "Int64")
        childX	:= NumGet(vChildren, i-8, "Int64")
        if (childX = 9) {
          AccChild := Acc_Query(child), dbgRC := ObjRelease(child)
          if (Acc_Role(AccChild) = Role) {
            Children.Push(AccChild)
          }
        } else {
          if (Acc_Role(Acc,child) = Role) {
            Children.Push(child)
          }
        }
      }
      NewError := 0
      return Children.Length ? Children : 0
    } else {
      NewError := Error("AccessibleChildren DllCall Failed" , -1)
    }
  }
  if Acc_Error() {
    throw NewError ; Exception(ErrorLevel,-1)
  }
}
Acc_Get(Cmd, ChildPath:="", ChildID:=0, WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="") {
  com	:= win32Constant.comT ; various COM win32 API constants
  static properties := Map()
    properties["Action"  ] := "DefaultAction"
    properties["DoAction"] := "DoDefaultAction"
    properties["Keyboard"] := "KeyboardShortcut"
  if IsObject(WinTitle) {
    AccObj := WinTitle
  } else {
    AccObj := Acc_ObjectFromWindow(WinExist(WinTitle,WinText,ExcludeTitle,ExcludeText), 0)
  }
  if (ComObjType(AccObj,"Name") != "IAccessible") {
    NewError := Error("Could not access an IAccessible Object" , -1)
  } else {
    ChildPath := StrReplace(ChildPath, "_", A_Space)
    AccError:=Acc_Error(), Acc_Error(true)
    Loop Parse, ChildPath, ".", A_Space {
      try {
        if isDigit(A_LoopField) {
          Children := Acc_Children(AccObj)
          m := [1, A_LoopField] ; mimic "m[2]" output in else-statement
        } else {
          RegExMatch(A_LoopField, "(\D*)(\d*)", &m)
          Children := Acc_ChildrenByRole(AccObj, m[1])
          m2 := (m[2] ? m[2] : 1)
        }
        if Not Children.Has(m2) {
          throw
        }
        AccObj := Children[m2]
      } catch {
        NewError := Error("Cannot access ChildPath Item #" A_Index " -> " A_LoopField , -1, "Item #" A_Index " -> " A_LoopField)
        Acc_Error(AccError)
        if Acc_Error() {
          throw NewError
        }
        return
      }
    }
    Acc_Error(AccError)
    Cmd := StrReplace(Cmd, A_Space)
    if properties.Has(Cmd) {
      Cmd:=properties[Cmd]
    } else {
      try {
        if        (Cmd = "Object") {
          ret_val := AccObj
        } else if (Cmd ~= "^(?i:Role|State|Location)$") {
          ret_val := Acc_%Cmd%(AccObj, ChildID+0)
        } else if (Cmd ~= "^(?i:ChildCount|Selection|Focus)$") {
          ret_val := AccObj["acc" Cmd]
        } else {
          ret_val := AccObj["acc" Cmd](ChildID+0)
        }
      } catch {
        NewError := Error("'" Cmd "' command NOT implemented", -1, Cmd)
        throw Error("'" Cmd "' command NOT implemented", -1, Cmd)
        ; if Acc_Error() {
        ;   throw NewError
        ; }
        ; return
      }
      NewError := 0
      return ret_val
    }
  }
  if Acc_Error() {
    throw Error(NewError,-1)
  }
}
Acc_Location(Acc, ChildId:=0) { ; adapted from Sean's code
  com	:= win32Constant.comT ; various COM win32 API constants
  xb:=Buffer(4), yb:=Buffer(4), wb:=Buffer(4), hb:=Buffer(4)
  try {
    Acc.accLocation(
      ComValue(com.pi32, xb.Ptr)
    , ComValue(com.pi32, yb.Ptr)
    , ComValue(com.pi32, wb.Ptr)
    , ComValue(com.pi32, hb.Ptr)
    , ChildId)
  } catch {
    return
  }
  retObj:= Object()
    retObj.x   := NumGet(xb, 0, "Int")
  , retObj.y   := NumGet(yb, 0, "Int")
  , retObj.w   := NumGet(wb, 0, "Int")
  , retObj.h   := NumGet(hb, 0, "Int")
    retObj.pos := "x" retObj.x " y" retObj.y " w" retObj.w " h" retObj.h
  return retObj
}
Acc_Parent(Acc) {
  try parent:=Acc.accParent
  return parent
   ? Acc_Query(parent)
   : 0
}
Acc_Child(Acc, ChildId:=0) {
  try child := Acc.accChild(ChildId)
  return child
   ? Acc_Query(child)
   : 0
}
Acc_Query(Acc) {
  static win32:=win32Constant, com:=win32.comT, IID:=win32.IID ; win32 API COM/IID constants
  try {
    pIAcc    	:= ComObjQuery(Acc, IID.IAccessible)
    retComObj	:= ComValue(com.DISPATCH, pIAcc, 1)
    return retComObj
  }
}
