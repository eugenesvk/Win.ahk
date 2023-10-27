#Requires AutoHotKey 2.0.10
; win32	:= win32Constant ; various win32 API constants
; win32.wm.input
; win32.wm_input
; win32.m['wm']['input']
; win32.m['wm_input']
class win32Constant { ; Various win32 API constants
  ; , mapAlias := Map('WindowMessage','wm') ; adds subgroups like win32.wm in addition to adding vars to the global space

  static replace_at_start(&where, &replace_map) {
    if type(replace_map) = "Map" {
      for  s_from, s_to in replace_map {
        if s_from =       SubStr(where, 1,  StrLen(s_from)) { ; beginning matches
          where := s_to . SubStr(where, 1 + StrLen(s_from))   ; replace the beginning
          return true ; replace once
        }
      }
    }
  }
  static replace_anywhere(&where, &replace_map) {
    static replaceAll := -1
    if type(replace_map) = "Map" {
      found := false
      for  s_from, s_to in replace_map {
        if InStr(where, s_from) {
          where := StrReplace(where, s_from, s_to, isCase:=1,,replaceAll)
          found := true
        }
      }
      if found {
        return true
      }
    }
  }

  static __new() { ; get all vars and store their values in this.Varname as well ‘m’ map, and add aliases
    static clsNames := ['Messages','Input','Misc','Component_Object_Model']
     , m := Map()
     , mReplace_start := Map(
        '1WM_' 	,''
      , 'xxxxx'	,''
      )
    , mReplace_all := Map(
        'LOCALE_' 	,''
      , 'ENGLISH' 	,'En'
      , '_'       	,''
      , 'HEADER'  	,'Hd'
      , 'DEFAULT' 	,'Def'
      , 'CODEPAGE'	,'CPg'
      , 'NUMBER'  	,'Num'
      , 'NAME'    	,'Nm'
      , 'LANGUAGE'	,'Lng'
      , 'WINDOWS' 	,'Win'
      )
    m.CaseSense := 0 ; make key matching case insensitive

    dbgTxt := ""
    dbgWarn := ""
    for i,_cls in clsNames {                    	; Messages
      for mapNm in %_cls%.mapNames {            	; WindowMessage
        if %_cls%.mapAlias.Has(mapNm) {         	;
          mapAlias := %_cls%.mapAlias.Get(mapNm)	; WindowMessage → wm
          hasAlias := true                      	;
          if m.Has(mapAlias) {
            dbgWarn .= "`n" . "Duplicate alias [" . mapAlias . "]"
          }
          this.%mapAlias%                     	:= Object() ; add sub-object to allow nested search
          m[mapAlias]                         	:= Map() ; add sub-map    to allow nested search
          m[mapAlias].CaseSense               	:= 0 ; make key matching case insensitive
        }                                     	;
        for mapKey, mapVal in %_cls%.%mapNm% {	; WM_INPUT, 0x0FF
          if type(mapVal) = "String" {        	; local variable is a string
            val := m.Get(mapVal,mapVal)       	; so can refer to an already existing local variable (hopefully it was defined earlier)
            ; val := this.%mapVal%
          } else {
            val := mapVal
          }
          keys := []
          if m.Has(mapKey) {
            dbgWarn .= "`n" . "Duplicate [" . mapKey . "]"
          }
          keys.push(mapKey) ; WM_INPUT
          if (this.replace_at_start(&mapKey,&mReplace_start) = true) {
            if m.Has(mapKey) {
              dbgWarn .= "`n" . "Duplicate [" . mapKey . "]"
            }
            keys.push(mapKey) ; INPUT
          }
          if (this.replace_anywhere(&mapKey,&mReplace_all) = true) {
            if m.Has(mapKey) {
              dbgWarn .= "`n" . "Duplicate [" . mapKey . "]"
            }
            keys.push(mapKey) ; IN
          }
          for key in keys {
            this.%key%	:= val
            m[key]    	:= val
            if hasAlias := true {
              alias_keys := []
              alias_keys.push(key)
              ; dbgTxt .= "mapAlias=" . mapAlias . "`n"
              ; dbgTxt .= "pushed key=" . key . "`n"
              mReplace_start_alias := Map(mapAlias . "_","")
              if (this.replace_at_start(&key,&mReplace_start_alias) = true) {
                if m[mapAlias].Has(key) {
                  dbgWarn .= "`n" . "Duplicate [" . mapAlias . "][" . key . "]"
                }
                alias_keys.push(key)
                ; dbgTxt .= "pushed mReplace_start_alias=" . key . "`n"
              }
              for alias_key in alias_keys {
                ; dbgTxt .= "alias_key=" . alias_key . "`n"
                this.%mapAlias%.%alias_key%	:= val
                m[mapAlias][alias_key]     	:= val
              }
              ; dbgTT(0,dbgTxt,T:=3)
              ; dbgTT(0,dbgTxt,T:=3)
            }
          }
        }
      }
    }
    this.m := m
    if not dbgWarn = "" {
      msgbox(dbgWarn, 'Duplicate keys!', '0x30')
    }
  }
}
class Messages {
  static mapNames := ['WindowMessage']
  , mapAlias := Map('WindowMessage','wm')
  , WindowMessage := Map(
      'WM_INPUT'                 	, 0x0FF 	;
    , 'WM_INPUTLANGCHANGEREQUEST'	, 0x0050	;
  )
}

class Input {
  static mapNames := ['RawInput']
  , mapAlias := Map('RawInput','rid')
  , RawInput := Map(
      'RID_HEADER'     	, 0x10000005 ; Get the header information from the RAWINPUT structure
    , 'RID_INPUT'      	, 0x10000003 ; Get the raw data           from the RAWINPUT structure
    , 'RIDEV_INPUTSINK'	, 0x00000100
    , 'RIDEV_REMOVE'   	, 0x00000001
  )
}

class Misc {
  static mapNames := ['Misc1','Misc1_alias','GUI_C']
  , mapAlias := Map('Misc1','Misc' ,'GUI_C','gui')
  , Misc1 := Map(
      'LR_DEFAULTCOLOR'    	, 0x00000000	; default, does nothing, just means "not lrMONOCHROME".
    , 'LR_CREATEDIBSECTION'	, 0x00002000	; When the uType parameter specifies IMAGE_BITMAP, causes the function to return a DIB section bitmap rather than a compatible bitmap. This flag is useful for loading a bitmap without mapping it to the colors of the display device
    , 'LR_DEFAULTSIZE'     	, 0x00000040	; Uses the width or height specified by the system metric values for cursors or icons, if the cxDesired or cyDesired values are set to zero. If this flag is not specified and cxDesired and cyDesired are set to zero, the function uses the actual resource size. If the resource contains multiple images, the function uses the size of the first image
    , 'LR_LOADFROMFILE'    	, 0x00000010	; Loads the standalone image from the file specified by name (icon, cursor, or bitmap file).
    , 'LR_LOADMAP3DCOLORS' 	, 0x00001000	; Searches the color table for the image and replaces the following shades of gray with the corresponding 3-D color.
     ; Dk Gray             	            	, RGB(128,128,128) with COLOR_3DSHADOW
     ; Gray                	            	, RGB(192,192,192) with COLOR_3DFACE
     ; Lt Gray             	            	, RGB(223,223,223) with COLOR_3DLIGHT
                           	            	; Do not use this option if you are loading a bitmap with a color depth greater than 8bpp.
    , 'LR_LOADTRANSPARENT' 	, 0x00000020	; Retrieves the color value of the first pixel in the image and replaces the corresponding entry in the color table with the default window color (COLOR_WINDOW). All pixels in the image that use that entry become the default window color. This value applies only to images that have corresponding color tables.
                           	            	; Do not use this option if you are loading a bitmap with a color depth greater than 8bpp.
                           	            	; If fuLoad includes both the lrLoadTransparent and lrLOADMAP3DCOLORS values, lrLoadTransparent takes precedence. However, the color table entry is replaced with COLOR_3DFACE rather than COLOR_WINDOW.
    , 'LR_MONOCHROME'      	, 0x00000001	; Load/Create image in black and white
    , 'LR_SHARED'          	, 0x00008000	; Shares image handle when image loaded multiple times, otherwise 2nd call for the same resource will load the image again and return a different handle. System will destroy the resource when it is no longer needed Finds the first image in the cache with the requested resource name, regardless of the size requested
                           	            	; Do not use for images that have non-standard sizes, that may change after loading, or that are loaded from a file
                           	            	; MUST When loading a system icon/cursor
    , 'LR_VGACOLOR'        	, 0x00000080	;Uses true VGA colors.
    , 'LR_COPYDELETEORG'   	, 0x00000008	; Copy: Deletes the original image after creating the copy.
    , 'LR_COPYFROMRESOURCE'	, 0x00004000	; Copy: Tries to reload an icon or cursor resource from the original resource file rather than simply copying the current image. This is useful for creating a different-sized copy when the resource file contains multiple sizes of the resource. Without this flag, CopyImage stretches the original image to the new size. If this flag is set, CopyImage uses the size in the resource file closest to the desired size. This will succeed only if hImage was loaded by LoadIcon or LoadCursor, or by LoadImage with the LR_SHARED flag.	:= LR_COPYRETURNORG	:= 0x00000004	; Returns the original hImage if it satisfies the criteria for the copy—that is, correct dimensions and color depth—in which case the LR_COPYDELETEORG flag is ignored. If this flag is not specified, a new object is always created.	:= LR_CREATEDIBSECTION	:= 0x00002000	; If this is set and a new bitmap is created, the bitmap is created as a DIB section. Otherwise, the bitmap image is created as a device-dependent bitmap. This flag is only valid if uType is IMAGE_BITMAP.

    , 'imgBitmap'        	, 0   	; Loads/Copies bitmap
    , 'imgIcon'          	, 1   	; Loads/Copies icon
    , 'imgCursor'        	, 2   	; Loads/Copies cursor
    , 'SPI_SETCURSORS'   	, 0x57	; SPI_SETCURSORS Reloads the system cursors. Set the uiParam parameter to zero and the pvParam parameter to NULL
    , 'MDT_EFFECTIVE_DPI'	, 0   	; effective DPI. This value should be used when determining the correct scale factor for scaling UI elements. This incorporates the scale factor set by the user for this specific display.
    , 'MDT_ANGULAR_DPI'  	, 1   	; angular DPI. This DPI ensures rendering at a compliant angular resolution on the screen. This does not include the scale factor set by the user for this specific display.
    , 'MDT_RAW_DPI'      	, 2   	; raw DPI. This value is the linear DPI of the screen as measured on the screen itself. Use this value when you want to read the pixel density and not the recommended scaling setting. This does not include the scale factor set by the user for this specific display and is not guaranteed to be a supported DPI value.

    , 'DPI_AWARENESS_CONTEXT_UNAWARE'             	, -1	; ((DPI_AWARENESS_CONTEXT)-1) window does not scale for DPI changes and is always assumed to have a scale factor of 100% (96 DPI).
    , 'DPI_AWARENESS_CONTEXT_SYSTEM_AWARE'        	, -2	; ((DPI_AWARENESS_CONTEXT)-2) window does not scale for DPI changes. It will query for the DPI once and use that value for the lifetime of the process.
    , 'DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE'   	, -3	; ((DPI_AWARENESS_CONTEXT)-3) This window checks for the DPI when it is created and adjusts the scale factor whenever the DPI changes.
    , 'DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2'	, -4	; ((DPI_AWARENESS_CONTEXT)-4) ↑ improved
    , 'DPI_AWARENESS_CONTEXT_UNAWARE_GDISCALED'   	, -5	; ((DPI_AWARENESS_CONTEXT)-5)

    , 'SM_CXCURSOR'	, 13	; nominal px width  of a cursor
    , 'SM_CYCURSOR'	, 14	; nominal px height of a cursor
  )
  , Misc1_alias := Map(
      'lrDIB'      	, 'LR_CREATEDIBSECTION'	;
    , 'lrDefSz'    	, 'LR_DEFAULTSIZE'     	;
    , 'lrVGA'      	, 'LR_VGACOLOR'        	;
    , 'lrCcDelOrig'	, 'LR_COPYDELETEORG'   	;
    , 'lrCcSrc'    	, 'LR_COPYFROMRESOURCE'	;

    , 'MDT_DEFAULT'	, 'MDT_EFFECTIVE_DPI'	; default DPI setting for a monitor is MDT_EFFECTIVE_DPI
    , 'curReload'  	, 'SPI_SETCURSORS'   	;
    , 'dpiEff'     	, 'MDT_EFFECTIVE_DPI'	;
    , 'dpiAng'     	, 'MDT_ANGULAR_DPI'  	;
    , 'dpiRaw'     	, 'MDT_RAW_DPI'      	;
    , 'dpiDef'     	, 'MDT_DEFAULT'      	;

    , 'dpiAwareNo'   	, 'DPI_AWARENESS_CONTEXT_UNAWARE'             	;
    , 'dpiAwareSys'  	, 'DPI_AWARENESS_CONTEXT_SYSTEM_AWARE'        	;
    , 'dpiAwareMon'  	, 'DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE'   	;
    , 'dpiAwareMon2' 	, 'DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2'	;
    , 'dpiAwareNoGDI'	, 'DPI_AWARENESS_CONTEXT_UNAWARE_GDISCALED'   	;

    , 'curW'	, 'SM_CXCURSOR'	;
    , 'curH'	, 'SM_CYCURSOR'	;
  )
  ; The predefined image identifiers are defined in Winuser.h and have the following prefixes
    ; OBM_		OEM bitmaps
    ; OIC_		OEM icons
    ; OCR_		OEM cursors
    ; IDI_		Standard icons
    ; IDC_		Standard cursors
  , GUI_C := Map(
      'GUI_CARETBLINKING' 	, 0x00000001	; caret's blink        state, set if the caret is visible
    , 'GUI_INMENUMODE'    	, 0x00000004	; thread's menu        state, set if the thread is in menu mode
    , 'GUI_INMOVESIZE'    	, 0x00000002	; thread's move        state, set if the thread is in a move or size loop
    , 'GUI_POPUPMENUMODE' 	, 0x00000010	; thread's pop-up menu state, set if the thread has an active pop-up menu
    , 'GUI_SYSTEMMENUMODE'	, 0x00000008	; thread's system menu state, set if the thread is in a system menu mode
  )
  , GUI_C_alias := Map(
      'lrDIB'  	, 'LR_CREATEDIBSECTION'	;
    , 'lrDefSz'	, 'LR_DEFAULTSIZE'     	;
  )
}


class Component_Object_Model {
  static mapNames := ['ComType','ComTypeAlias','IID']
  , mapAlias := Map('ComTypeAlias','comT', 'IID','IID')
  , ComType := Map( ; learn.microsoft.com/en-us/openspecs/windows_protocols/ms-oaut/3fe7db9f-5803-4dc4-9d14-5425d3f5461f
      'VT_EMPTY'      	, 0x0000	;
    , 'VT_NULL'       	, 0x0001	;
    , 'VT_I2'         	, 0x0002	;
    , 'VT_I4'         	, 0x0003	;
    , 'VT_R4'         	, 0x0004	;
    , 'VT_R8'         	, 0x0005	;
    , 'VT_CY'         	, 0x0006	;
    , 'VT_DATE'       	, 0x0007	;
    , 'VT_BSTR'       	, 0x0008	;
    , 'VT_DISPATCH'   	, 0x0009	;
    , 'VT_ERROR'      	, 0x000A	;
    , 'VT_BOOL'       	, 0x000B	;
    , 'VT_VARIANT'    	, 0x000C	;
    , 'VT_UNKNOWN'    	, 0x000D	;
    , 'VT_DECIMAL'    	, 0x000E	;
    , 'VT_I1'         	, 0x0010	;
    , 'VT_UI1'        	, 0x0011	;
    , 'VT_UI2'        	, 0x0012	;
    , 'VT_UI4'        	, 0x0013	;
    , 'VT_I8'         	, 0x0014	;
    , 'VT_UI8'        	, 0x0015	;
    , 'VT_INT'        	, 0x0016	;
    , 'VT_UINT'       	, 0x0017	;
    , 'VT_VOID'       	, 0x0018	;
    , 'VT_HRESULT'    	, 0x0019	;
    , 'VT_PTR'        	, 0x001A	;
    , 'VT_SAFEARRAY'  	, 0x001B	;
    , 'VT_CARRAY'     	, 0x001C	;
    , 'VT_USERDEFINED'	, 0x001D	;
    , 'VT_LPSTR'      	, 0x001E	;
    , 'VT_LPWSTR'     	, 0x001F	;
    , 'VT_RECORD'     	, 0x0024	;
    , 'VT_INT_PTR'    	, 0x0025	;
    , 'VT_UINT_PTR'   	, 0x0026	;
    , 'VT_ARRAY'      	, 0x2000	;
    , 'VT_BYREF'      	, 0x400 	;
  )
  , ComTypeAlias := Map(
      'none'       	, 'VT_EMPTY'      	;	No value
    , 'null'       	, 'VT_NULL'       	;	SQL-style Null
    , 'iarch'      	, 'VT_INT'        	;	machine signed int
    , 'i8'         	, 'VT_I1'         	;	 8-bit  signed int
    , 'i16'        	, 'VT_I2'         	;	16-bit  signed int
    , 'i32'        	, 'VT_I4'         	;	32-bit  signed int
    , 'i64'        	, 'VT_I8'         	;	64-bit  signed int
    , 'uarch'      	, 'VT_UINT'       	;	machine unsigned int
    , 'u8'         	, 'VT_UI1'        	;	 8-bit  unsigned int
    , 'u16'        	, 'VT_UI2'        	;	16-bit  unsigned int
    , 'u32'        	, 'VT_UI4'        	;	32-bit  unsigned int
    , 'u64'        	, 'VT_UI8'        	;	64-bit  unsigned int
    , 'f32'        	, 'VT_R4'         	;	32-bit floating-point number
    , 'f64'        	, 'VT_R8'         	;	64-bit floating-point number
    , 'bool'       	, 'VT_BOOL'       	;	Boolean True (-1) or False (0)
    , 'str'        	, 'VT_BSTR'       	;	COM string (Unicode string with length prefix)
    , 'cur'        	, 'VT_CY'         	;	Currency
    , 'date'       	, 'VT_DATE'       	;	Date
    , 'Dispatch'   	, 'VT_DISPATCH'   	;	COM object
    , 'err'        	, 'VT_ERROR'      	;	Error code (32-bit integer)
    , 'var'        	, 'VT_VARIANT'    	;	VARIANT (must be combined with VT_ARRAY or VT_BYREF)
    , 'un'         	, 'VT_UNKNOWN'    	;	IUnknown interface pointer
    , 'arr'        	, 'VT_ARRAY'      	;	SAFEARRAY
    , 'arrSafe'    	, 'VT_SAFEARRAY'  	;
    , 'arrC'       	, 'VT_CARRAY'     	;
    , 'byref'      	, 'VT_BYREF'      	;	Pointer to another : of value
    , 'dec'        	, 'VT_DECIMAL'    	;	(not supported)
    , 'rec'        	, 'VT_RECORD'     	;	User-defined type -- NOT SUPPORTED
    , 'pi32'       	, 0x4003          	; byref|i32 Pointer to 32-bit signed int
    , 'pi64'       	, 0x4014          	; byref|i64 Pointer to 64-bit signed int
    , 'arrvar'     	, 0x200C          	; arr  |var Array variant
    , 'pvar'       	, 0x400C          	; byref|var Pointer to Variant
    , 'i32|64'     	, 'VT_INT_PTR'    	; 4-byte or 8-byte   signed integer (platform specific, determines the system pointer size value)
    , 'ui32|64'    	, 'VT_UINT_PTR'   	; 4-byte or 8-byte unsigned integer (platform specific, determines the system pointer size value)
    , 'isys'       	, 'VT_INT_PTR'    	; ↑
    , 'uisys'      	, 'VT_UINT_PTR'   	; ↑
    , 'iptr'       	, 'VT_INT_PTR'    	; ↑
    , 'uiptr'      	, 'VT_UINT_PTR'   	; ↑
    , 'void'       	, 'VT_VOID'       	;
    , 'hRes'       	, 'VT_HRESULT'    	;
    , 'ptr'        	, 'VT_PTR'        	; unique pointer
    , 'USERDEFINED'	, 'VT_USERDEFINED'	;
    , 'LPSTR'      	, 'VT_LPSTR'      	;
    , 'LPWSTR'     	, 'VT_LPWSTR'     	;
  )
  , IID := Map( ; COM interface IDs
     'IAccessible'	, '{618736e0-3c3d-11cf-810c-00aa00389b71}' ;
    ,'IDispatch'  	, '{00020400-0000-0000-C000-000000000046}'

    ; , 'pvar'	, ''	;
  )
}
