#Requires AutoHotKey 2.0.10
/* use winAPIconst via a loader class
  winAPI	:= winAPIconst_loader.load('embed')
  cC    	:= winAPI.getKey_Any   .Bind(winAPI)
  cLoc  	:= winAPI.getKey_Locale.Bind(winAPI)
  cCLS  	:= winAPI.getKey_CLSID .Bind(winAPI)
  cIID  	:= winAPI.getKey_IID   .Bind(winAPI)

  res_Str := cIID('ActiveDesktop')
  ; winAPIconst_loader.unload('embed') ; to conserve memory, the DLL may be unloaded after using it
 */

class winAPIconst_loader {
  static m := Map(
    'mmap' ,Map(
      'c',0,
      'libPath','lib\',
      'libName','winAPIconst_mmap'),
    'embed',Map(
      'c',0,
      'libPath','lib\',
      'libName','winAPIconst_embed')
  )
  static load(t) {
    if        t == "mmap" {
      if winAPIconst_loader.m['mmap']['c'] == 0 {
         winAPIconst_loader.m['mmap']['c'] := winAPIconst(winAPIconst_loader.m['mmap']['libPath'], winAPIconst_loader.m['mmap']['libName'])
      }
      return winAPIconst_loader.m['mmap']['c']
    } else if t == "embed" {
      if winAPIconst_loader.m['embed']['c'] == 0 {
         winAPIconst_loader.m['embed']['c'] := winAPIconst(winAPIconst_loader.m['embed']['libPath'], winAPIconst_loader.m['embed']['libName'])
      }
      return winAPIconst_loader.m['embed']['c']
    } else {
      throw ValueError('‘' t '’' " doesn't exist, use ‘mmap’ or ‘embed’")
    }
  }
  static unload(t) {
    if        t == "mmap" {
      winAPIconst_loader.m['mmap']['c'].unload()
      winAPIconst_loader.m['mmap']['c'] := 0
    } else if t == "embed" {
      winAPIconst_loader.m['embed']['c'].unload()
      winAPIconst_loader.m['embed']['c'] := 0
    } else {
      throw ValueError('‘' t '’' " doesn't exist, use ‘mmap’ or ‘embed’")
    }
  }
}
class winAPIconst { ; Various win32 API constants from a memory-mapped file
  __new(libPath,libNm) {
    this.libPath  	:= libPath
     ,this.libNm  	:= libNm
     ,this.ℯsz    	:= 100 ; max limit of error size to get
     ,this.hModule	:= 0
     ,this.lib𝑓   	:= this.libNm '\' 'get_win32_const'
     ,this.any    	:= DllCall.Bind(this.lib𝑓, 'Str',''      , 'Str',unset, 'UInt',this.ℯsz,'Ptr',unset, 'Ptr')
     ,this.CLSID  	:= DllCall.Bind(this.lib𝑓, 'Str','CLSID' , 'Str',unset, 'UInt',this.ℯsz,'Ptr',unset, 'Ptr')
     ,this.IID    	:= DllCall.Bind(this.lib𝑓, 'Str','IID_I' , 'Str',unset, 'UInt',this.ℯsz,'Ptr',unset, 'Ptr')
     ,this.Locale 	:= DllCall.Bind(this.lib𝑓, 'Str','LOCALE', 'Str',unset, 'UInt',this.ℯsz,'Ptr',unset, 'Ptr')
     ,this.free   	:= DllCall.Bind(this.libNm '\dealloc_lib_str', 'Ptr',unset)

     ,this.Loc            	:= this.Locale
     ,this.dealloc_lib_str	:= this.free

    if this.hModule == 0 {
      this.load()
      ; msgbox('loaded in new ' this.lib𝑓 '`n' this.libPath '`n' this.libNm)
    ; } else {
      ; msgbox(this.hModule)
    }
  }
  getKey_Any(key) {
    𝑓:=this.any
    return this.getKey(𝑓,key)
  }
  getKey_Locale(key) {
    𝑓:=this.Locale
    return this.getKey(𝑓,key)
  }
  getKey_Loc(key) {
    𝑓:=this.Locale
    return this.getKey(𝑓,key)
  }
  getKey_CLSID(key) {
    𝑓:=this.CLSID
    return this.getKey(𝑓,key)
  }
  getKey_IID(key) {
    𝑓:=this.IID
    return this.getKey(𝑓,key)
  }
  getKey(𝑓,key) {
    ℯ:=Buffer(this.ℯsz),res_Str:='',err_msg:=''
    ,cFree	:= this.free
    if res_ptr := 𝑓(key,ℯ) {
      res_Str	:= StrGet(res_ptr), cFree(res_ptr) ; need to free the string generated within the library to avoid memory leak
      return res_Str
    } else {
      ℯmsg	:= StrGet(ℯ) ; no need to dealloc since AHK created the buffer
      throw ValueError('‘' key '’ ' ℯmsg, -2) ; -1 AHK bug? corrupts display '✗ Value', when calling getKey(𝑓,key) directly, displays fine
    }
  }
  load() {
    hModule	:= DllCall("LoadLibrary", "Str",this.libPath this.libNm '.dll', "Ptr")  ; Avoids the need for DllCall in the loop to load the library
    this.hModule:=hModule
    ; msgbox('loaded')
  }
  unload() {
    DllCall("FreeLibrary", "Ptr",this.hModule)  ; to conserve memory, the DLL may be unloaded after using it
    this.hModule:=0
  }
  ;__delete() { ; uncomment to autodelete
  ;  if this.hModule != 0 {
  ;    this.unload()
  ;    ; msgbox('__delete')
  ;  } else {
  ;    ; msgbox('__delete already no hModule')
  ;  }
  ;}
}
