#Requires AutoHotKey 2.0.10

class nativeFunc {
  static GetSystemTimePreciseAsFileTime() {
    /* learn.microsoft.com/en-us/windows/win32/api/sysinfoapi/nf-sysinfoapi-getsystemtimepreciseasfiletime
    retrieves the current system date and time with the highest possible level of precision (<1us)
    FILETIME structure contains a 64-bit value representing the number of 100-nanosecond intervals since January 1, 1601 (UTC)
    100 ns  ->  0.1 µs  ->  0.001 ms  ->  0.00001 s
    1     sec  ->  1000 ms  ->  1000000 µs
    0.1   sec  ->   100 ms  ->   100000 µs
    0.001 sec  ->    10 ms  ->    10000 µs
    */
    static interval2sec := (10 * 1000 * 1000) ; 100ns * 10 → µs * 1000 → ms * 1000 → sec
    DllCall("GetSystemTimePreciseAsFileTime", "int64*",&ft:=0)
    return ft / interval2sec
  }

  static QueryPerformanceFrequency() {
    DllCall("QueryPerformanceFrequency","Int64*",&frequency:=0)
    return frequency
  }
  static MCode(mcode) { ; http://ahkscript.org/boards/viewtopic.php?f=7&t=32
    ; create c/c++ function from mcode, and return the function address
    ; static MCode(hex) {
    ;   static reg := "^([12]?).*" (A_PtrSize = 8 ? "x64" : "x86") ":([A-Za-z\d+/=]+)"
    ;   if (RegExMatch(hex, reg, &m))
    ;     hex := m[2], flag := m[1] = "1" ? 4 : m[1] = "2" ? 1 : hex ~= "[+/=]" ? 1 : 4
    ;   else flag := hex ~= "[+/=]" ? 1 : 4
    ;   if (!DllCall("crypt32\CryptStringToBinary", "str", hex, "uint", 0, "uint", flag, "ptr", 0, "uint*", &s := 0, "ptr", 0, "ptr", 0))
    ;     throw OSError(A_LastError)
    ;   if (DllCall("crypt32\CryptStringToBinary", "str", hex, "uint", 0, "uint", flag, "ptr", p := (code := Buffer(s)).Ptr, "uint*", &s, "ptr", 0, "ptr", 0) && DllCall("VirtualProtect", "ptr", code, "uint", s, "uint", 0x40, "uint*", 0))
    ;     return (this.Prototype.caches[p] := code, p)
    ;   throw OSError(A_LastError)
    ; }
    ; dwFlags                         	          	;
    ; CRYPT_STRING_BASE64HEADER       	0x00000000	Base64 between lines of the form `-----BEGIN ...-----` and `-----END ...-----`. See Remarks below.
    ; CRYPT_STRING_BASE64             	0x00000001	Base64, without headers.
    ; CRYPT_STRING_BINARY             	0x00000002	Pure binary copy.
    ; CRYPT_STRING_BASE64REQUESTHEADER	0x00000003	Base64 between lines of the form `-----BEGIN ...-----` and `-----END ...-----`. See Remarks below.
    ; CRYPT_STRING_HEX                	0x00000004	Hexadecimal only format
    ; CRYPT_STRING_HEXASCII           	0x00000005	Hexadecimal format with ASCII character display.
    ; CRYPT_STRING_BASE64_ANY         	0x00000006	Tries the following, in order:
      ;                               	          	CRYPT_STRING_BASE64HEADER
      ;                               	          	CRYPT_STRING_BASE64
    ; CRYPT_STRING_ANY                	0x00000007	Tries the following, in order:
      ;                               	          	CRYPT_STRING_BASE64HEADER
      ;                               	          	CRYPT_STRING_BASE64
      ;                               	          	CRYPT_STRING_BINARY
    ; CRYPT_STRING_HEX_ANY            	0x00000008	Tries the following, in order:
      ;                               	          	CRYPT_STRING_HEXADDR
      ;                               	          	CRYPT_STRING_HEXASCIIADDR
      ;                               	          	CRYPT_STRING_HEX
      ;                               	          	CRYPT_STRING_HEXRAW
      ;                               	          	CRYPT_STRING_HEXASCII
    ; CRYPT_STRING_BASE64X509CRLHEADER	0x00000009	Base64 between lines of the form `-----BEGIN ...-----` and `-----END ...-----`. See Remarks below.
    ; CRYPT_STRING_HEXADDR            	0x0000000a	Hex, with address display.
    ; CRYPT_STRING_HEXASCIIADDR       	0x0000000b	Hex, with ASCII character and address display.
    ; CRYPT_STRING_HEXRAW             	0x0000000c	A raw hexadecimal string. Windows Server 2003 and Windows XP:  This value is not supported.
    ; CRYPT_STRING_STRICT             	0x20000000	Set this flag for Base64 data to specify that the end of the binary data contain only white space and at most three equals "=" signs. Windows Server 2008, Windows Vista, Windows Server 2003 and Windows XP:  This value is not supported

    static e := {1:4, 2:1}, c := (A_PtrSize=8) ? "x64" : "x86"
    m:=0,op:=0
    if (not regexmatch(mcode, "^([0-9]+),(" c ":|.*?," c ":)([^,]+)", &m)) {
      return
    }
    ; get required size first by passing pbBinary=0
    if (not DllCall("crypt32\CryptStringToBinary" ; BOOL converts a formatted string into an array of bytes learn.microsoft.com/en-us/windows/win32/api/wincrypt/nf-wincrypt-cryptstringtobinaryw
      , "str" ,m[3]    	;i     	LPCWSTR	 pszString	pointer to a string that contains the formatted string to be converted
      ,"uint" ,0       	;i     	DWORD  	 cchString	number of characters of the formatted string to be converted, not including the terminating NULL character. =0 pszString is considered to be a null-terminated string
      ,"uint" ,e.%m[1]%	;i     	DWORD  	 dwFlags  	format of the string to be converted. This can be one of the following values
      , "ptr" ,0       	;i     	BYTE   	*pbBinary 	pointer to a buffer that receives the returned sequence of bytes. If this parameter is NULL, the function calculates the length of the buffer needed and returns the size, in bytes, of required memory in the DWORD pointed to by pcbBinary
      ,"uint*",&s:=0   	;io    	DWORD  	*pcbBinary	pointer to a DWORD variable that, on entry, contains the size, in bytes, of the pbBinary buffer. After the function returns, this variable contains the number of bytes copied to the buffer. If this value is not large enough to contain all of the data, the function fails and GetLastError returns ERROR_MORE_DATA pbBinary is NULL, the DWORD pointed to by pcbBinary is ignored
      , "ptr" ,0       	; o    	DWORD  	*pdwSkip  	pointer to a DWORD value that receives the number of characters skipped to reach the beginning of the -----BEGIN ...----- header. If no header is present, then the DWORD is set to zero. This parameter is optional and can be NULL if it is not needed.
      , "ptr" ,0)) {   	; o opt	DWORD  	*pdwFlags 	(NULL if not needed) A pointer to a DWORD value that receives the flags actually used in the conversion. These are the same flags used for the dwFlags parameter. In many cases, these will be the same flags that were passed in the dwFlags parameter. If dwFlags contains one of the following flags, this value will receive a flag that indicates the actual format of the string
        ;              	       	same flags as ↑ CRYPT_STRING_ANY, CRYPT_STRING_BASE64_ANY, CRYPT_STRING_HEX_ANY
      return
    }
    ; msgbox('m[1] ' m[1] '`n' e.%m[1]% '`t' 'string format e.%m[1]%' '`n' s '`t size s' '`n' m[3] '`t' 'code m[3]'
      ; . '`n' DllCall("kernel32.dll\GetLastError"))
    ; ERROR_INVALID_DATA 13 (0xD) The data is invalid
    p := DllCall("GlobalAlloc", "uint",0, "ptr",s, "ptr")
    if (c="x64") {
      DllCall("VirtualProtect", "ptr",p, "ptr",s, "uint",0x40, "uint*",&op)
    }
    ; do the actual conversion
    if (DllCall("crypt32\CryptStringToBinary"
      , "str" ,m[3]
      ,"uint" ,0
      ,"uint" ,e.%m[1]%
      , "ptr" ,p
      ,"uint*",s
      , "ptr" ,0
      , "ptr" ,0)) {
      ; msgbox('returning type ' type(p) '`n' p)
      return p
    }
    DllCall("GlobalFree", "ptr",p)
  }
}
