#Requires AutoHotKey 2.1-alpha.4

class guiF {
  static _:=0
   , LVM_GETHEADER := 0x101F
   , LVM_SUBITEMHITTEST := 0x1039
   , HDM_GETITEMRECT := 0x1207

  static lvGetHeaderRect(hWndLV) { ; Get the header rectangle (left, top, right, bottom)
    ; Send the message to get the header handle
    hWndHeader := DllCall("SendMessage", "Ptr",hWndLV, "UInt",this.LVM_GETHEADER, "UInt",0, "Ptr",0, "Ptr")
    ; Get the header rectangle (in screen coordinates)
    headerRect := Buffer(16,0) ; sizeof(RECT) = 16
    DllCall("GetClientRect", "ptr",hWndHeader, "ptr",headerRect)
    ; Get the position of the rectangle
    hdRect := {}
    hdRect.← := NumGet(headerRect,  0, "int") ; always 0 in own client coord
    hdRect.↑ := NumGet(headerRect,  4, "int")
    hdRect.→ := NumGet(headerRect,  8, "int")
    hdRect.↓ := NumGet(headerRect, 12, "int")
    hdRect.w := hdRect.→ - hdRect.←
    hdRect.h := hdRect.↓ - hdRect.↑
    return hdRect
  }
  static lvGetHeaderItemRect(hWndLV,item_i) { ; Get header's item rectangle (left, top, right, bottom)
    ; Send the message to get the header handle
    hWndHeader := DllCall("SendMessage", "Ptr",hWndLV, "UInt",this.LVM_GETHEADER, "UInt",0, "Ptr",0, "Ptr")
    ; Get the header item rectangle (in screen coordinates)
    headerItemRect := Buffer(16,0) ; sizeof(RECT) = 16
    res_ := DllCall("SendMessage", "Ptr",hWndHeader, "UInt",this.HDM_GETITEMRECT, "UInt",item_i-1, "Ptr",headerItemRect, "Ptr")
    ; Get the position of the rectangle
    hditemRect := {}
    hditemRect.← := NumGet(headerItemRect,  0, "int") ; always 0 in own client coord?
    hditemRect.↑ := NumGet(headerItemRect,  4, "int")
    hditemRect.→ := NumGet(headerItemRect,  8, "int")
    hditemRect.↓ := NumGet(headerItemRect, 12, "int")
    hditemRect.w := hditemRect.→ - hditemRect.←
    hditemRect.h := hditemRect.↓ - hditemRect.↑
    return hditemRect
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

  static FFToolTip(Text?, X?, Y?, WhichToolTip := 1) { ; Creates a tooltip window on any screen in a single or multiple-monitor environment. Unlike the built-in ToolTip function, calling this function repeatedly will not cause the tooltip window to flicker. Otherwise, it behaves much the same way, except around the bottom-right corner of each monitor. If neither coordinate is specified, the tooltip window will not cover any part of the taskbar.
    ; Text to display ↑ in the tooltip. `n for multiline. if blank/omitted, destroy the existing  tooltip
    ; X / Y position of the tooltip relative to ≝active window / its client area / screen depending on the coordinate mode (see CoordMode). Without both show @ mouse pointer)
    ; WhichToolTip ≝1–20 to indicate which tooltip window to operate upon
    ;→Return: handle of the tooltip window or 0 if Text is blank/omitted
    ; iPhilip autohotkey.com/boards/viewtopic.php?f=6&t=62607
    static TTS	:= []
     , ΔX     	:= 16  ; Horizontal gap between the mouse and the left   edge of the tooltip window
     , ΔY     	:= 16  ; Vertical   gap between the mouse and the top    edge of the tooltip window
     , ΔZ     	:= 3   ; Vertical   gap between the mouse and the bottom edge of the tooltip window when in the bottom-right corner of the screen
     , Flags  	:= 0x10040  ; TPM_WORKAREA = 0x10000 | TPM_VERTICAL = 0x0040
     , POS    	:= Buffer(16)
     , EXC    	:= Buffer(16)
     , OUT    	:= Buffer(16)

    if !TTS.Length {
      TTS.Length := 20
    }
    if !IsSet(Text) || Text = '' {  ; Destroy the tooltip.
      hwnd := ToolTip( , , , WhichToolTip)
      TTS.Delete(WhichToolTip)
    } else if !   TTS.Has(WhichToolTip)
      || Text !== TTS[   WhichToolTip].Text {  ; First call or tooltip text changed
      hwnd := ToolTip(Text, X?, Y?, WhichToolTip)
      WinGetPos(&X, &Y, &W, &H, hwnd)
      TTS[WhichToolTip] := {X:X, Y:Y, W:W, H:H, hwnd:hwnd, Text:Text}
    } else {  ; The tooltip is being repositioned.
      IsSetX := IsSet(X)
      IsSetY := IsSet(Y)
      if !IsSetX || !IsSetY {
        DllCall('GetCursorPos', 'Ptr',POS, 'Int')
        MouseX := NumGet(POS, 0,'Int')
        MouseY := NumGet(POS, 4,'Int')
      }
      if        A_CoordModeToolTip = 'Window' { ; Convert input coordinates to screen coordinates
        WinGetPos(&WinX, &WinY, , , 'A')
        X := IsSetX ? X + WinX : MouseX
        Y := IsSetY ? Y + WinY : MouseY
      } else if A_CoordModeToolTip = 'Client' {
        NumPut 'Int', X ?? 0, 'Int', Y ?? 0, POS
        DllCall('ClientToScreen', 'Ptr',WinExist('A'), 'Ptr',POS, 'Int')
        X := IsSetX ? NumGet(POS, 0,'Int') : MouseX
        Y := IsSetY ? NumGet(POS, 4,'Int') : MouseY
      } else {  ; A_CoordModeToolTip = 'Screen'
        X := X ?? MouseX
        Y := Y ?? MouseY
      }
      W := TTS[WhichToolTip].W
      H := TTS[WhichToolTip].H
      ; If neither coordinate is specified, force the tooltip window to be within the working area of the monitors.
      if !IsSetX && !IsSetY
        && DllCall('SetRect', 'Ptr',POS, 'Int',X + ΔX, 'Int',Y + ΔY, 'Int',W     , 'Int',H     , 'Int')
        && DllCall('SetRect', 'Ptr',EXC, 'Int',X - ΔZ, 'Int',Y - ΔZ, 'Int',X + ΔX, 'Int',Y + ΔY, 'Int')
        && DllCall('CalculatePopupWindowPosition', 'Ptr',POS, 'Ptr',POS.Ptr + 8, 'UInt',Flags, 'Ptr',EXC, 'Ptr',OUT, 'Int') {
        X := NumGet(OUT, 0,'Int'), Y := NumGet(OUT, 4,'Int')
      }
      hwnd := TTS[WhichToolTip].hwnd ; If necessary, store the coordinates and move the tooltip window
      if   X != TTS[WhichToolTip].X
        || Y != TTS[WhichToolTip].Y {
        TTS[WhichToolTip].X := X
        TTS[WhichToolTip].Y := Y
        DllCall('MoveWindow', 'Ptr',hwnd, 'Int',X, 'Int',Y, 'Int',W, 'Int',H, 'Int',false, 'Int')
      }
    }
    return hwnd
  }
}
