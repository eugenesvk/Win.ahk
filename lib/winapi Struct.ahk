#Requires AutoHotKey 2.1-alpha.4

; Structs (typed properties)
  ; im := lvInsertMark() ; instantiate
  ; Fields defined by a subclass are always placed after fields defined by the base class.
    ; For example, when class StructB extends StructA, the layout is the same as if StructB extends Object but begins with a nested StructA. However, inherited properties are accessed directly, not through a nested struct.
 ; Type specifier in a class definition can be:
   ; literal (unquoted) reserved type name	i32
   ; exact class name                     	MyClass.MyNestedClass
   ; integer indicating the size of the property, in which case the property's value is its address, and cannot be assigned
   ; expression enclosed in parentheses which returns a class object or a reserved type name (quoted if literal)
   ; expression starting with an identifier, optionally followed by a parameter list (making it a function call), optionally followed by any number of property or method calls
 ; i8, i16, i32 and i64 are signed integers, with i32 being 32-bit.
 ; u8, u16, u32 and u64 are unsigned integers, with u32 being 32-bit.
 ; iptr and uptr are integers; 32-bit when A_PtrSize = 4 and 64-bit when A_PtrSize = 8.
 ; f32 and f64 are floating-point numbers.

#include <constWin32T>

class winapi_Struct { ; Various win32 API constants
  static winT	:= winTypes.m ; winT types and their ahk types for DllCalls and structs

  class lvInsertMark { ; learn.microsoft.com/en-us/windows/win32/api/commctrl/ns-commctrl-lvinsertmark
    cbSize    	: (winTypes.m['UINT']['struct']) := ObjGetDataSize(this)
    dwFlags   	: (winTypes.m['DWORD']['struct'])	; Flag that specifies where the insertion point should appear. Use the following
     ;        	                                 	 LVIM_AFTER The insertion point appears after the item specified if the LVIM_AFTER flag is set; otherwise it appears before the specified item.
    iItem     	: (winTypes.m['int']['struct'])  	; Item next to which the insertion point appears. If this member contains -1, there is no insertion point
    dwReserved	: (winTypes.m['DWORD']['struct'])
  } ;  LVINSERTMARK, *LPLVINSERTMARK;

  class Point { ; learn.microsoft.com/en-us/windows/win32/api/windef/ns-windef-point
    x : (winTypes.m['LONG']['struct']) ; point's x-coordinate
    y : (winTypes.m['LONG']['struct']) ; point's y-coordinate
    ;           		typedef struct tagPOINT {
    ; 0:0, "Int"	  LONG x;
    ; 4:4, "Int"	  LONG y;
    ;           		} POINT, *PPOINT;
    ; 8:8
  }
  class CursorInfo { ; learn.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-cursorinfo
    static T   	:= winTypes.m ; winT types and their ahk types for DllCalls and structs
    cbSize     	: (this.T['DWORD']['struct']) := ObjGetDataSize(this) ; size of the structure, in bytes. The caller must set this to sizeof(CURSORINFO)
    flags      	: (this.T['DWORD']['struct']) ; cursor state. This parameter can be one of the following values.
    ;          	0                           	cursor is hidden
    ;          	CURSOR_SHOWING    0x00000001	cursor is showing
    ;          	CURSOR_SUPPRESSED 0x00000002	Windows 8: The cursor is suppressed. This flag indicates that the system is not drawing the cursor because the user is providing input through touch or pen instead of the mouse.
    hCursor    	: (this.T['HCURSOR']['struct']) ; Handle to the cursor
    ptScreenPos	: winapi_Struct.Point ; Structure that receives the screen coordinates of the cursor
  } ; CURSORINFO, *PCURSORINFO, *LPCURSORINFO
}
