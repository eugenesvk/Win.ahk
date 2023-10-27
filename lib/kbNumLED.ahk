#Requires AutoHotKey 2.1-alpha.4
/* v2.9@20-07
  KeyboardLED("LED", Cmd, Kbd) autohotkey.com/forum/viewtopic.php?p=468000#468000
    LEDvalue  Scroll=1, Num=2, Caps=4, Num+Caps=6, All=7, other = passthru
    Cmd       1/0/-1 (On/Off/Toggle)
    Kbd       index of keyboard (usually 0/2, see HKLM\Hardware\DeviceMap\Keyboardclass)
*/

NumLockReverse() {
  Sleep(10) ; improve reliability of setting LED state sometimes
  if (GetKeyState("Numlock","T")) {
    KeyboardLED("Num",0)
  } else {
    KeyboardLED("Num",1)
  }
  }
NumLockRestore() {
  Sleep(10) ; improve reliability of setting LED state sometimes
  if (GetKeyState("Numlock","T")) {
    KeyboardLED("Num",1)
  } else {
    KeyboardLED("Num",0)
  }
  }

KeyboardLED(LED, Cmd, Kbd:=unset) {      ; loop through indices to find Gigabyte Osmium
  ; HKEY_LOCAL_MACHINE\HARDWARE\DEVICEMAP\KeyboardClass adds new numbers when you re-plug a keyboard, don't know how to find the proper one
  ; HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\kbdclass\Enum
    ; removes/ads these values on unplug/plug, but not sure whether I can get the KeyboardClass# from these
    ; 5 HID\VID_0665&PID_6000&MI_00\9&28bf34e4&0&0000
    ; 6 HID\VID_0665&PID_6000&MI_02\9&34d2e661&0&0000
    ; 7 HID\VID_1044&PID_7A03&MI_00\9&3b1e84ce&0&0000
  if IsSet(Kbd) {
    KeyboardLEDid(LED, Cmd, Kbd)
  } else {
    for i in [0,1,2,3,4,5,6,7,8,9] {
    ; loop 25 { ; alternative way, loop all currently the highest number of \Device\KeyboardClass25
      ; i := A_Index
      KeyboardLEDid(LED, Cmd, i)
    }
  }
}

KeyboardLEDid(LED, Cmd, Kbd:=23) {      ; index 3 for Gigabyte Osmium
  if LED = "Scroll" {
    LEDvalue:=1
  } else if ((LED = "Num") OR (LED = "NumLock")) {
    LEDvalue:=2
  } else if ((LED = "Caps") OR (LED = "CapsLock")) {
    LEDvalue:=4
  } else if ((LED = "Num+Caps") OR (LED = "NumCaps") OR (LED = "NumLock+CapsLock")) {
    LEDvalue:=6
  } else if ((LED = "All") OR (LED = "NumCapsScroll") OR (LED = "Num+Caps+Scroll") OR (LED = "NumLock+CapsLock+ScrollLock")){
    LEDvalue:=7
  } else {
    LEDvalue:=LED
  }
  SetUnicodeStr(&fn,"\Device\KeyBoardClass" Kbd)

  hDevice:=NtCreateFile(&fn,0+0x00000100+0x00000080+0x00100000,1,1,0x00000040+0x00000020,0)
  If Cmd=-1 ; toggles every LED according to LEDvalue
    KeyLED := LEDvalue ; KeyLED := 14
  If Cmd=1  ; forces chosen LEDs to ON (LEDvalue= 0 ->LED's according to keystate)
    KeyLED := LEDvalue | (GetKeyState("ScrollLock","T") + 2*GetKeyState("NumLock","T") + 4*GetKeyState("CapsLock","T"))
  If Cmd=0  {  ; forces chosen LEDs to OFF (LEDvalue= 0 ->LED's according to keystate)
    LEDvalue	:= LEDvalue ^ 7
    KeyLED  	:= LEDvalue & (GetKeyState("ScrollLock","T") + 2*GetKeyState("NumLock","T") + 4*GetKeyState("CapsLock","T"))
  }
  output_actual := 0 ; Fix 1.06 autohotkey.com/boards/viewtopic.php?&t=70600&p=305016
  success := DllCall("DeviceIoControl"
    ,  "ptr"	, hDevice
    , "uint"	, CTL_CODE(	  0x0000000b ; FILE_DEVICE_KEYBOARD
            	           	, 2
            	           	, 0          ; METHOD_BUFFERED
            	           	, 0 )        ; FILE_ANY_ACCESS
    , "int*"	, KeyLED << 16
    , "uint"	, 4
    ,  "ptr"	, 0
    , "uint"	, 0
    , "ptr*"	, output_actual
    ,  "ptr"	, 0 )
  NtCloseFile(hDevice)
  return success
  }
CTL_CODE( p_device_type, p_function, p_method, p_access ) {
  Return ( p_device_type << 16 ) | ( p_access << 14 ) | ( p_function << 2 ) | p_method
  }
NtCreateFile(&wfilename,desiredaccess,sharemode,createdist,flags,fattribs) {
  capObjattrib	:= VarSetStrCapacity(&objattrib	, 6*A_PtrSize)	; 48
  capIo       	:= VarSetStrCapacity(&io       	, 2*A_PtrSize)	; 16
  capPus      	:= VarSetStrCapacity(&pus      	, 2*A_PtrSize)	; 16
  ptrObjattrib	:= StrPtr(Objattrib)           	              	;
  ptrIo       	:= StrPtr(io)                  	              	;
  ptrPus      	:= StrPtr(pus)                 	              	;
  DllCall("ntdll\RtlInitUnicodeString", "ptr",StrPtr(pus), "ptr",StrPtr(wfilename))
  NumPut("int",capObjattrib	, ptrObjattrib, 0)
  NumPut("int",ptrPus      	, ptrObjattrib, 2*A_PtrSize)
  filehandle :=0 ; Fix 1.06 autohotkey.com/boards/viewtopic.php?&t=70600&p=305016
  status := DllCall("ntdll\ZwCreateFile"
    , "ptr*"	, filehandle
    , "UInt"	, desiredaccess
    , "ptr" 	, ptrObjattrib
    , "ptr" 	, ptrPus
    , "ptr" 	, 0
    , "UInt"	, fattribs
    , "UInt"	, sharemode
    , "UInt"	, createdist
    , "UInt"	, flags
    , "ptr" 	, 0
    , "UInt"	, 0
    , "UInt")
  return(filehandle)
  }
NtCloseFile(handle) {
  return DllCall("ntdll\ZwClose", "ptr",handle)
  }
SetUnicodeStr(&out, str_) {
  VarSetStrCapacity(&out, 2*StrPut(str_,"utf-16"))
  StrPut(str_,StrPtr(out),"utf-16")
  }

KeyboardLED("Num",0)	; Turn NumLock LED indicator Off
