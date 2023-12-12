/*
test_winTypes()
test_winTypes() {
  winT	:= winTypes.m ; winT types and their ahk types for DllCalls and structs
  winTnm := 'PCWSTR'
  msgbox(''                   	'`t 32'                       	'`t 64'
   '`n' winT[winTnm]['ahk']   	'`t ' winT[winTnm]['ahk32']   	'`t ' winT[winTnm]['ahk64'] '`tahk'
   '`n' winT[winTnm]['struct']	'`t ' winT[winTnm]['struct32']	'`t ' winT[winTnm]['struct64'] '`tstruct'
   '`n' winT[winTnm]['dll']   	'`t ' winT[winTnm]['dll32']   	'`t ' winT[winTnm]['dll64'] '`tdll'
   '`n' winT[winTnm]['size']  	'`t ' winT[winTnm]['size32']  	'`t ' winT[winTnm]['size64'] '`tsize'
   '`n' winT[winTnm]['dllAlt'][1] '`t`t`tdllAlt'
  )

test_winTypesStruct() { ; for use with dynamically created structs using copy&pasted windows types
  winT  	:= winTypes.struct ; winT types and their ahk types Calls and structs
  Point := Class(Object)  ; Specify the base class so a Prototype is created automatically
  Point.Prototype.DefineProp 'x', {type: winT['LONG']]} ; Specifies the x-coordinate of the point
  Point.Prototype.DefineProp 'y', {type: winT['LONG']]} ; Specifies the y-coordinate of the point
  ;           		typedef struct tagPOINT {
  ; 0:0, "Int"	  LONG x;
  ; 4:4, "Int"	  LONG y;
  ;           		} POINT, *PPOINT;
  ; 8:8
  pt             	:= Point() ; insantiate a new object
  WindowFromPoint	:= DllCall.Bind("WindowFromPoint", Point,unset, "uptr") ; Use the class itself to pass by value
  GetCursorPos   	:= DllCall.Bind("GetCursorPos",    "ptr",unset) ; Use "ptr" to pass by reference
  GetCursorPos(pt)
  MsgBox(WinGetClass(WindowFromPoint(pt)))

  ; alternative
  ; winT	:= winTypes.m ; winT types and their ahk types for DllCalls and structs
  ; Point.Prototype.DefineProp 'x', {type: winT['LONG']['struct']} ; Specifies the x-coordinate of the point
}
*/
class winTypes { ; from github.com/jNizM/AutoHotkey_MSDN_Types
  static mapNames := ['DataType1','DataType2']
  , mapAlias := Map('DataType','T')
  , DataType1 := [
     ["ATOM"            	,"UShort"       	,""                 	,2,2  	,"typedef WORD ATOM"]
    ,["BOOL"            	,"Int"          	,""                 	,4,4  	,"typedef int BOOL"]
    ,["BOOLEAN"         	,"UChar"        	,""                 	,1,1  	,"typedef BYTE BOOLEAN"]
    ,["BYTE"            	,"UChar"        	,""                 	,1,1  	,"typedef unsigned char BYTE"]
    ,["CCHAR"           	,"Char"         	,""                 	,1,1  	,"typedef char CCHAR"]
    ,["CHAR"            	,"Char"         	,""                 	,1,1  	,"typedef char CHAR"]
    ,["COLORREF"        	,"UInt"         	,""                 	,4,4  	,"typedef DWORD COLORREF"]
    ,["DWORD"           	,"UInt"         	,""                 	,4,4  	,"typedef unsigned long DWORD"]
    ,["DWORDLONG"       	,"Int64"        	,""                 	,8,8  	,"typedef unsigned __int64 DWORDLONG"]
    ,["DWORD_PTR"       	,"UPtr"         	,""                 	,4,8  	,"typedef ULONG_PTR DWORD_PTR"]
    ,["DWORD32"         	,"UInt"         	,""                 	,4,4  	,"typedef unsigned int DWORD32"]
    ,["DWORD64"         	,"Int64"        	,""                 	,8,8  	,"typedef unsigned __int64 DWORD64"]
    ,["FLOAT"           	,"Float"        	,""                 	,4,4  	,"typedef float FLOAT"]
    ,["HACCEL"          	,"Ptr"          	,""                 	,4,8  	,"typedef HANDLE HACCEL"]
    ,["HALF_PTR"        	,"Short | Int"  	,""                 	,2,4  	,"typedef short HALF_PTR | typedef int HALF_PTR"]
    ,["HANDLE"          	,"Ptr"          	,""                 	,4,8  	,"typedef PVOID HANDLE"]
    ,["HBITMAP"         	,"Ptr"          	,""                 	,4,8  	,"typedef HANDLE HBITMAP"]
    ,["HBRUSH"          	,"Ptr"          	,""                 	,4,8  	,"typedef HANDLE HBRUSH"]
    ,["HCOLORSPACE"     	,"Ptr"          	,""                 	,4,8  	,"typedef HANDLE HCOLORSPACE"]
    ,["HCONV"           	,"Ptr"          	,""                 	,4,8  	,"typedef HANDLE HCONV"]
    ,["HCONVLIST"       	,"Ptr"          	,""                 	,4,8  	,"typedef HANDLE HCONVLIST"]
    ,["HCURSOR"         	,"Ptr"          	,""                 	,4,8  	,"typedef HICON HCURSOR"]
    ,["HDC"             	,"Ptr"          	,""                 	,4,8  	,"typedef HANDLE HDC"]
    ,["HDDEDATA"        	,"Ptr"          	,""                 	,4,8  	,"typedef HANDLE HDDEDATA"]
    ,["HDESK"           	,"Ptr"          	,""                 	,4,8  	,"typedef HANDLE HDESK"]
    ,["HDROP"           	,"Ptr"          	,""                 	,4,8  	,"typedef HANDLE HDROP"]
    ,["HDWP"            	,"Ptr"          	,""                 	,4,8  	,"typedef HANDLE HDWP"]
    ,["HENHMETAFILE"    	,"Ptr"          	,""                 	,4,8  	,"typedef HANDLE HENHMETAFILE"]
    ,["HFILE"           	,"Int"          	,""                 	,4,8  	,"typedef int HFILE"]
    ,["HFONT"           	,"Ptr"          	,""                 	,4,8  	,"typedef HANDLE HFONT"]
    ,["HGDIOBJ"         	,"Ptr"          	,""                 	,4,8  	,"typedef HANDLE HGDIOBJ"]
    ,["HGLOBAL"         	,"Ptr"          	,""                 	,4,8  	,"typedef HANDLE HGLOBAL"]
    ,["HHOOK"           	,"Ptr"          	,""                 	,4,8  	,"typedef HANDLE HHOOK"]
    ,["HICON"           	,"Ptr"          	,""                 	,4,8  	,"typedef HANDLE HICON"]
    ,["HINSTANCE"       	,"Ptr"          	,""                 	,4,8  	,"typedef HANDLE HINSTANCE"]
    ,["HKEY"            	,"Ptr"          	,""                 	,4,8  	,"typedef HANDLE HKEY"]
    ,["HKL"             	,"Ptr"          	,""                 	,4,8  	,"typedef HANDLE HKL"]
    ,["HLOCAL"          	,"Ptr"          	,""                 	,4,8  	,"typedef HANDLE HLOCAL"]
    ,["HMENU"           	,"Ptr"          	,""                 	,4,8  	,"typedef HANDLE HMENU"]
    ,["HMETAFILE"       	,"Ptr"          	,""                 	,4,8  	,"typedef HANDLE HMETAFILE"]
    ,["HMODULE"         	,"Ptr"          	,""                 	,4,8  	,"typedef HINSTANCE HMODULE"]
    ,["HMONITOR"        	,"Ptr"          	,""                 	,4,8  	,"typedef HANDLE HMONITOR"]
    ,["HPALETTE"        	,"Ptr"          	,""                 	,4,8  	,"typedef HANDLE HPALETTE"]
    ,["HPEN"            	,"Ptr"          	,""                 	,4,8  	,"typedef HANDLE HPEN"]
    ,["HRESULT"         	,"Int"          	,""                 	,4,4  	,"typedef LONG HRESULT"]
    ,["HRGN"            	,"Ptr"          	,""                 	,4,8  	,"typedef HANDLE HRGN"]
    ,["HRSRC"           	,"Ptr"          	,""                 	,4,8  	,"typedef HANDLE HRSRC"]
    ,["HSZ"             	,"Ptr"          	,""                 	,4,8  	,"typedef HANDLE HSZ"]
    ,["HWINSTA"         	,"Ptr"          	,""                 	,4,8  	,"typedef HANDLE WINSTA"]
    ,["HWND"            	,"Ptr"          	,""                 	,4,8  	,"typedef HANDLE HWND"]
    ,["INT"             	,"Int"          	,""                 	,4,4  	,"typedef int INT"]
    ,["INT_PTR"         	,"Ptr"          	,""                 	,4,8  	,"typedef int INT_PTR / __int64 INT_PTR"]
    ,["INT8"            	,"Char"         	,""                 	,1,1  	,"typedef signed char INT8"]
    ,["INT16"           	,"Short"        	,""                 	,2,2  	,"typedef signed short INT16"]
    ,["INT32"           	,"Int"          	,""                 	,4,4  	,"typedef signed int INT32"]
    ,["INT64"           	,"Int64"        	,""                 	,8,8  	,"typedef signed __int64 INT64"]
    ,["LANGID"          	,"UShort"       	,""                 	,2,2  	,"typedef WORD LANGID"]
    ,["LCID"            	,"UInt"         	,""                 	,4,4  	,"typedef DWORD LCID"]
    ,["LCTYPE"          	,"UInt"         	,""                 	,4,4  	,"typedef DWORD LCTYPE"]
    ,["LGRPID"          	,"UInt"         	,""                 	,4,4  	,"typedef DWORD LGRPID"]
    ,["LONG"            	,"Int"          	,""                 	,4,4  	,"typedef long LONG"]
    ,["LONGLONG"        	,"Int64"        	,""                 	,8,8  	,"typedef __int64 LONGLONG"]
    ,["LONG_PTR"        	,"Ptr"          	,""                 	,4,8  	,"typedef long LONG_PTR / __int64 LONG_PTR"]
    ,["LONG32"          	,"Int"          	,""                 	,4,4  	,"typedef signed int LONG32"]
    ,["LONG64"          	,"Int64"        	,""                 	,8,8  	,"typedef __int64 LONG64"]
    ,["LPARAM"          	,"Ptr"          	,""                 	,4,8  	,"typedef LONG_PTR LPARAM"]
    ,["LPBOOL"          	,"Ptr"          	,"IntP"             	,4,8  	,"typedef BOOL far *LPBOOL"]
    ,["LPBYTE"          	,"Ptr"          	,"UCharP"           	,4,8  	,"typedef BYTE far *LPBYTE"]
    ,["LPCOLORREF"      	,"Ptr"          	,"UIntP"            	,4,8  	,"typedef DWORD *LPCOLORREF"]
    ,["LPCSTR"          	,"Ptr"          	,"Str / AStr"       	,4,8  	,"typedef __nullterminated CONST CHAR *LPCST"]
    ,["LPCTSTR"         	,"Ptr"          	,"Str"              	,4,8  	,"typedef LPCSTR LPCTSTR / LPCWSTR LPCTSTR"]
    ,["LPCVOID"         	,"Ptr"          	,"PtrP"             	,4,8  	,"typedef CONST void *LPCVOID"]
    ,["LPCWSTR"         	,"Ptr"          	,"Str / WStr"       	,4,8  	,"typedef CONST WCHAR *LPCWSTR"]
    ,["LPDWORD"         	,"Ptr"          	,"UIntP"            	,4,8  	,"typedef DWORD *LPDWORD"]
    ,["LPHANDLE"        	,"Ptr"          	,"PtrP"             	,4,8  	,"typedef HANDLE *LPHANDLE"]
    ,["LPINT"           	,"Ptr"          	,"IntP"             	,4,8  	,"typedef int *LPINT"]
    ,["LPLONG"          	,"Ptr"          	,"IntP"             	,4,8  	,"typedef long *LPLONG"]
    ,["LPSTR"           	,"Ptr"          	,"Str / AStr"       	,4,8  	,"typedef CHAR *LPSTR"]
    ,["LPTSTR"          	,"Ptr"          	,"Str"              	,4,8  	,"typedef LPSTR LPTSTR / LPWSTR LPTSTR"]
    ,["LPVOID"          	,"Ptr"          	,"PtrP"             	,4,8  	,"typedef void *LPVOID"]
    ,["LPWORD"          	,"Ptr"          	,"UShortP"          	,4,8  	,"typedef WORD *LPWORD"]
    ,["LPWSTR"          	,"Ptr"          	,"Str / WStr"       	,4,8  	,"typedef WCHAR *LPWSTR"]
    ,["LRESULT"         	,"Ptr"          	,""                 	,4,8  	,"typedef LONG_PTR LRESULT"]
    ,["PBOOL"           	,"Ptr"          	,"IntP"             	,4,8  	,"typedef BOOL *PBOOL"]
    ,["PBOOLEAN"        	,"Ptr"          	,"CharP"            	,4,8  	,"typedef BOOLEAN *PBOOLEAN"]
    ,["PBYTE"           	,"Ptr"          	,"UCharP"           	,4,8  	,"typedef BYTE *PBYTE"]
    ,["PCHAR"           	,"Ptr"          	,"CharP"            	,4,8  	,"typedef CHAR *PCHAR"]
    ,["PCSTR"           	,"Ptr"          	,"Str / AStr"       	,4,8  	,"typedef CONST CHAR *PCSTR"]
    ,["PCTSTR"          	,"Ptr"          	,"Str"              	,4,8  	,"typedef LPCSTR PCTSTR / LPCWSTR PCTSTR"]
    ,["PCWSTR"          	,"Ptr"          	,"Str / WStr"       	,4,8  	,"typedef CONST WCHAR *PCWSTR"]
    ,["PDWORD"          	,"Ptr"          	,"UIntP"            	,4,8  	,"typedef DWORD *PDWORD"]
    ,["PDWORDLONG"      	,"Ptr"          	,"Int64P"           	,4,8  	,"typedef DWORDLONG *PDWORDLONG"]
    ,["PDWORD_PTR"      	,"Ptr"          	,"UPtrP"            	,4,8  	,"typedef DWORD_PTR *PDWORD_PTR"]
    ,["PDWORD32"        	,"Ptr"          	,"UIntP"            	,4,8  	,"typedef DWORD32 *PDWORD3"]
    ,["PDWORD64"        	,"Ptr"          	,"Int64P"           	,4,8  	,"typedef DWORD64 *PDWORD64"]
    ,["PFLOAT"          	,"Ptr"          	,"FloatP"           	,4,8  	,"typedef FLOAT *PFLOAT"]
    ,["PHALF_PTR"       	,"Short | Int"  	,"ShortP | IntP"    	,4,8  	,"typedef HALF_PTR *PHALF_PTR | typedef HALF_PTR *PHALF_PTR"]
    ,["PHANDLE"         	,"Ptr"          	,"PtrP"             	,4,8  	,"typedef HANDLE *PHANDLE"]
    ,["PHKEY"           	,"Ptr"          	,"PtrP"             	,4,8  	,"typedef HKEY *PHKEY"]
    ,["PINT"            	,"Ptr"          	,"IntP"             	,4,8  	,"typedef int *PINT"]
    ,["PINT_PTR"        	,"Ptr"          	,"PtrP"             	,4,8  	,"typedef INT_PTR *PINT_PTR"]
    ,["PINT8"           	,"Ptr"          	,"CharP"            	,4,8  	,"typedef INT8 *PINT8"]
    ,["PINT16"          	,"Ptr"          	,"ShortP"           	,4,8  	,"typedef INT16 *PINT16"]
    ,["PINT32"          	,"Ptr"          	,"IntP"             	,4,8  	,"typedef INT32 *PINT32"]
    ,["PINT64"          	,"Ptr"          	,"Int64P"           	,4,8  	,"typedef INT64 *PINT64"]
    ,["PLCID"           	,"Ptr"          	,"UIntP"            	,4,8  	,"typedef PDWORD PLCID"]
    ,["PLONG"           	,"Ptr"          	,"IntP"             	,4,8  	,"typedef LONG *PLONG"]
    ,["PLONGLONG"       	,"Ptr"          	,"Int64P"           	,4,8  	,"typedef LONGLONG *PLONGLONG"]
    ,["PLONG_PTR"       	,"Ptr"          	,"PtrP"             	,4,8  	,"typedef LONG_PTR *PLONG_PTR"]
    ,["PLONG32"         	,"Ptr"          	,"IntP"             	,4,8  	,"typedef LONG32 *PLONG32"]
    ,["PLONG64"         	,"Ptr"          	,"Int64P"           	,4,8  	,"typedef LONG64 *PLONG64"]
    ,["POINTER_32"      	,"Int"          	,""                 	,"",""	,"#define POINTER_32 __ptr32"]
    ,["POINTER_64"      	,"Int64"        	,""                 	,"",""	,"#define POINTER_64 __ptr64"]
    ,["POINTER_SIGNED"  	,"Ptr"          	,""                 	,"",""	,"#define POINTER_SIGNED __sptr"]
    ,["POINTER_UNSIGNED"	,"UPtr"         	,""                 	,"",""	,"#define POINTER_UNSIGNED __uptr"]
    ,["PSHORT"          	,"Ptr"          	,"ShortP"           	,4,8  	,"typedef SHORT *PSHORT"]
    ,["PSIZE_T"         	,"Ptr"          	,"UPtrP"            	,4,8  	,"typedef SIZE_T *PSIZE_T"]
    ,["PSSIZE_T"        	,"Ptr"          	,"PtrP"             	,4,8  	,"typedef SSIZE_T *PSSIZE_T"]
    ,["PSTR"            	,"Ptr"          	,"Str / AStr"       	,4,8  	,"typedef CHAR *PSTR"]
    ,["PTBYTE"          	,"Ptr"          	,"ShortP"           	,4,8  	,"typedef TBYTE *PTBYTE | typedef TBYTE *PTBYTE"]
    ,["PTCHAR"          	,"Ptr"          	,"ShortP"           	,4,8  	,"typedef TCHAR *PTCHAR | typedef TCHAR *PTCHAR"]
    ,["PTSTR"           	,"Ptr"          	,"Str / AStr / WStr"	,4,8  	,"typedef LPSTR PTSTR / LPWSTR PTSTR"]
    ,["PUCHAR"          	,"Ptr"          	,"UCharP"           	,4,8  	,"typedef UCHAR *PUCHAR"]
    ,["PUHALF_PTR"      	,"UShort | UInt"	,"UShortP | UIntP"  	,4,8  	,"typedef UHALF_PTR *PUHALF_PTR | typedef UHALF_PTR *PUHALF_PTR"]
    ,["PUINT"           	,"Ptr"          	,"UIntP"            	,4,8  	,"typedef UINT *PUINT"]
    ,["PUINT_PTR"       	,"UPtr"         	,"UPtrP"            	,4,8  	,"typedef UINT_PTR *PUINT_PTR"]
    ,["PUINT8"          	,"Ptr"          	,"UCharP"           	,4,8  	,"typedef UINT8 *PUINT8"]
    ,["PUINT16"         	,"Ptr"          	,"UShortP"          	,4,8  	,"typedef UINT16 *PUINT16"]
    ,["PUINT32"         	,"Ptr"          	,"UIntP"            	,4,8  	,"typedef UINT32 *PUINT32"]
    ,["PUINT64"         	,"Ptr"          	,"Int64P"           	,4,8  	,"typedef UINT64 *PUINT64"]
    ,["PULONG"          	,"Ptr"          	,"UIntP"            	,4,8  	,"typedef ULONG *PULONG"]
    ,["PULONGLONG"      	,"Ptr"          	,"Int64P"           	,4,8  	,"typedef ULONGLONG *PULONGLONG"]
    ,["PULONG_PTR"      	,"UPtr"         	,"UPtrP"            	,4,8  	,"typedef ULONG_PTR *PULONG_PTR"]
    ,["PULONG32"        	,"Ptr"          	,"UIntP"            	,4,8  	,"typedef ULONG32 *PULONG32"]
    ,["PULONG64"        	,"Ptr"          	,"Int64P"           	,4,8  	,"typedef ULONG64 *PULONG64"]
    ,["PUSHORT"         	,"Ptr"          	,"UShortP"          	,4,8  	,"typedef USHORT *PUSHORT"]
    ,["PVOID"           	,"Ptr"          	,"PtrP"             	,4,8  	,"typedef void *PVOID"]
    ,["PWCHAR"          	,"Ptr"          	,"UShortP"          	,4,8  	,"typedef WCHAR *PWCHAR"]
    ,["PWORD"           	,"Ptr"          	,"UShortP"          	,4,8  	,"typedef WORD *PWORD"]
    ,["PWSTR"           	,"Ptr"          	,"Str / WStr"       	,4,8  	,"typedef WCHAR *PWSTR"]
    ]
  static DataType2 := [
     ["QWORD"                	,"Int64"        	,""    	,"",""	,"typedef unsigned __int64 QWORD"]
    ,["SC_HANDLE"            	,"Ptr"          	,""    	,4,8  	,"typedef HANDLE SC_HANDLE"]
    ,["SC_LOCK"              	,"Ptr"          	,"PtrP"	,4,8  	,"typedef LPVOID SC_LOCK"]
    ,["SERVICE_STATUS_HANDLE"	,"Ptr"          	,""    	,4,8  	,"typedef HANDLE SERVICE_STATUS_HANDLE"]
    ,["SHORT"                	,"Short"        	,""    	,2,2  	,"typedef short SHORT"]
    ,["SIZE_T"               	,"UPtr"         	,""    	,4,8  	,"typedef ULONG_PTR SIZE_T"]
    ,["SSIZE_T"              	,"Ptr"          	,""    	,4,8  	,"typedef LONG_PTR SSIZE_T"]
    ,["TBYTE"                	,"UShort"       	,""    	,1,1  	,"typedef unsigned char TBYTE | typedef WCHAR TBYTE"]
    ,["TCHAR"                	,"UShort"       	,""    	,1,1  	,"typedef char TCHAR | typedef WCHAR TCHAR"]
    ,["UCHAR"                	,"UChar"        	,""    	,1,1  	,"typedef unsigned char UCHAR"]
    ,["UHALF_PTR"            	,"UShort | UInt"	,""    	,2,4  	,"typedef unsigned short UHALF_PTR | typedef unsigned int UHALF_PTR"]
    ,["UINT"                 	,"UInt"         	,""    	,4,4  	,"typedef unsigned int UINT"]
    ,["UINT_PTR"             	,"UPtr"         	,""    	,4,8  	,"typedef unsigned int UINT_PTR / unsigned __int64 UINT_PTR"]
    ,["UINT8"                	,"UChar"        	,""    	,1,1  	,"typedef unsigned char UINT8"]
    ,["UINT16"               	,"UShort"       	,""    	,2,2  	,"typedef unsigned short UINT16"]
    ,["UINT32"               	,"UInt"         	,""    	,4,4  	,"typedef unsigned int UINT32"]
    ,["UINT64"               	,"Int64"        	,""    	,8,8  	,"typedef unsigned __int 64 UINT64"]
    ,["ULONG"                	,"UInt"         	,""    	,4,4  	,"typedef unsigned long ULONG"]
    ,["ULONGLONG"            	,"Int64"        	,""    	,8,8  	,"typedef unsigned __int64 ULONGLONG"]
    ,["ULONG_PTR"            	,"UPtr"         	,""    	,4,8  	,"typedef unsigned long ULONG_PTR / unsigned __int64 ULONG_PTR"]
    ,["ULONG32"              	,"UInt"         	,""    	,4,4  	,"typedef unsigned int ULONG32"]
    ,["ULONG64"              	,"Int64"        	,""    	,8,8  	,"typedef unsigned __int64 ULONG64"]
    ,["USHORT"               	,"UShort"       	,""    	,2,2  	,"typedef unsigned short USHORT"]
    ,["USN"                  	,"Int64"        	,""    	,8,8  	,"typedef LONGLONG USN"]
    ,["VOID"                 	,"Ptr"          	,""    	,4,8  	,"#define VOID void"]
    ,["WCHAR"                	,"UShort"       	,""    	,2,2  	,"typedef wchar_t WCHAR"]
    ,["WORD"                 	,"UShort"       	,""    	,2,2  	,"typedef unsigned short WORD"]
    ,["WPARAM"               	,"UPtr"         	,""    	,4,8  	,"typedef UINT_PTR WPARAM"]
      ]
  , ahk→struct := Map( ;??? map AHK types to AHK typed property types (= structs)
      'Char' 	, 'i8'  	, 'UChar' 	, 'u8'
    , 'Short'	, 'i16' 	, 'UShort'	, 'u16'
    , 'Int'  	, 'i32' 	, 'UInt'  	, 'u32'
    , 'Int64'	, 'i64' 	, 'UInt64'	, 'u64'
    , 'Ptr'  	, 'iptr'	, 'UPtr'  	, 'uptr'
    , 'Float'	, 'f32'
  )

  static __new() { ; get all vars and store their values in a ‘m’ map
    static m      	:= Map()
    , ms          	:= Map() ; store structs
    , mahk        	:= Map() ; store Ahk types
    m.CaseSense   	:= 0 ; make key matching case insensitive
    ms.CaseSense  	:= 0 ;
    mahk.CaseSense	:= 0 ;

    for i,arrTName in this.mapNames { ; DataType1
      for j,arrT in this.%arrTName% {
        ; ["PCWSTR","Ptr","Str / WStr",4,8,"typedef CONST WCHAR *PCWSTR"]
        ; ["PHALF_PTR","Short | Int","ShortP | IntP",4,8,"typedef HALF_PTR *PHALF_PTR | typedef HALF_PTR *PHALF_PTR"]
        mT          	:= Map()
        mT.CaseSense	:= 0
        mT['win']   	:= arrT[1] ; HALF_PTR
        typeAhkNm   	:= arrT[2]
        type32¦64   	:= StrSplit(typeAhkNm, '|', A_Space) ; Short | Int
        if type32¦64.Length > 1 {
          mT['ahk32']	:= type32¦64[1] ; ShortP
          mT['ahk64']	:= type32¦64[2] ; IntP
          mT['ahk']  	:= (A_PtrSize = 4) ? type32¦64[1] : type32¦64[2]
        } else       	{
          mT['ahk']  	:= mT['ahk32'] := mT['ahk64'] := typeAhkNm
        }
        mahk[mT['win']]	:= mT['ahk']
        typeDll        	:= arrT[3] ; Str / WStr or ShortP | IntP
        typeDll32¦64   	:= StrSplit(typeDll, '|', A_Space)
        if typeDll32¦64.Length > 1 {
          ; msgbox(arrT[1] '`n' typeDll32¦64[1] '`n' typeDll32¦64[2])
          mT['dll32']	:= typeDll32¦64[1] ; ShortP
          mT['dll64']	:= typeDll32¦64[2] ; IntP
          mT['dll']  	:= (A_PtrSize = 4) ? typeDll32¦64[1] : typeDll32¦64[2]
        } else {
          mT['dll']	:= mT['dll32'] := mT['dll64'] := typeDll
        }
        ; split ANSI/Unicodes
        typeDllA⁄B  	:= StrSplit(typeDll, '/', A_Space)
        mT['dllAlt']	:= []
        if typeDllA⁄B.Length > 1 {
          for i,dllT in typeDllA⁄B {
            if i = 1 {
              mT['dll']	:= mT['dll32'] := mT['dll64'] := typeDllA⁄B[i] ; Str
            } else {
              mT['dllAlt'].Push(typeDllA⁄B[i]) ; or WStr or ..
            }
          }
        } else {
          mT['dllAlt'].Push('')
        }
        mT['size']    	:= (A_PtrSize = 4) ? arrT[4] : arrT[5]
        mT['size32']  	:= arrT[4] ; 2
        mT['size64']  	:= arrT[5] ; 4
        mT['struct32']	:= this.ahk→struct[mT['ahk32']]
        mT['struct64']	:= this.ahk→struct[mT['ahk64']]
        mT['struct']  	:= (A_PtrSize = 4) ? mT['struct32'] : mT['struct64']
        mT['def']     	:= arrT[6] ; typedef ...
        m[arrT[1]]    	:= mT
        ms[mT['win']] 	:= mT['struct']
      }
    }
    this.m     	:= m
    this.struct	:= ms
    this.ahk   	:= mahk
  }
}
