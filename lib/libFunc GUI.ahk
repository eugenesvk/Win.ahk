#Requires AutoHotKey 2.1-alpha.4

#include <libFunc Dbg>   	; Functions: Debug
#include <libFunc Native>	; Functions: Native

class guiF {
  static _:=0
   , LVM_GETHEADER := 0x101F
   , LVM_SUBITEMHITTEST := 0x1039

  static lvGetHeaderRect(hWndLV) { ; Get the header rectangle (left, top, right, bottom)
    ; Send the message to get the header handle
    hWndHeader := DllCall("SendMessage", "Ptr",hWndLV, "UInt",this.LVM_GETHEADER, "UInt",0, "Ptr",0, "Ptr")
    ; Get the header rectangle (in screen coordinates)
    headerRect := Buffer(16,0) ; sizeof(RECT) = 16
    DllCall("GetClientRect", "Ptr",hWndHeader, "Ptr",headerRect)
    DllCall("GetClientRect", "ptr",hWndHeader, "ptr",headerRect)
    ; Adjust the position of the rectangle to the header area
    hdRect := {}
    hdRect.← := NumGet(headerRect,  0, "int") ; always 0 in own client coord
    hdRect.↑ := NumGet(headerRect,  4, "int")
    hdRect.→ := NumGet(headerRect,  8, "int")
    hdRect.↓ := NumGet(headerRect, 12, "int")
    hdRect.w := hdRect.→ - hdRect.←
    hdRect.h := hdRect.↓ - hdRect.↑
    return hdRect
  }
  static lvSubitemHitTest(hLV) { ; hLV - ListView's HWND
    POINT := Buffer(8, 0)
    DllCall("User32.dll\GetCursorPos"  , "Ptr",POINT) ; Pointer position in screen coordinates
    DllCall("User32.dll\ScreenToClient", "Ptr",hLV, "Ptr",POINT) ; Convert to client coordinates related to the ListView
    LVHITTESTINFO := Buffer(24, 0) ; Create a LVHITTESTINFO structure
      /* typedef struct _LVHITTESTINFO {
        POINT pt;
        UINT  flags;
        int   iItem;
        int   iSubItem;
        int   iGroup;
      } LVHITTESTINFO, *LPLVHITTESTINFO;
      */
    ; Store the relative mouse coordinates
    NumPut("Int", NumGet(POINT, 0, "Int"), LVHITTESTINFO, 0)
    NumPut("Int", NumGet(POINT, 4, "Int"), LVHITTESTINFO, 4)
    try {
      err_ret := SendMessage(this.LVM_SUBITEMHITTEST, 0, LVHITTESTINFO, , "ahk_id " hLV)
      if (err_ret = -1) { ; if no item was found on this position, the return value is -1
        return 0
      }
    } catch Error as e {
      return 0
    }
    Subitem := NumGet(LVHITTESTINFO, 16,"Int") + 1 ; Get the corresponding subitem (column)
    Return Subitem
  }
}
