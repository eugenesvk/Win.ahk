#Requires AutoHotKey 2.0.10

class numFunc {
  static bitmax(n) {
    return 2**n - 1
  }
  static ɵ(c) {
    return this.bitmax(8*c)
  }

  static bin→dec(num) {
    return numFunc.nbase(num, 2,10)
  }
  static dec→bin(num) {
    return numFunc.nbase(num,10, 2)
  }
  static nbase(num,bIn:=10,bOut:=2) {
    ; base("100"	,2 	,10)	→ 100 binary  to    4 decimal
    ; base("10" 	,10	,2) 	→  10 decimal to 1010 binary
    ; base("15" 	,10	,16)	→  15 decimal to    f hexadecimal
    ; base("f"  	,16	,2) 	→   f decimal to 1111 binary
      ; unsigned __int64 _wcstoui64 (
      ;   const wchar_t	*strSource	Null-terminated string to convert
      ;         wchar_t	**endptr  	Pointer to character that stops scan
      ;         int    	base      	Number base to use
    bIn→dec := DllCall('msvcrt\_wcstoui64', 'Str'   ,num    , 'Ptr',0               , 'Int',bIn , 'Cdecl Int64')
    DllCall(           'msvcrt\_i64tow'   , 'UInt64',bIn→dec, 'Ptr',buf:=Buffer(128), 'Int',bOut, 'Cdecl')
      ; wchar_t * _i64tow(long long value, wchar_t *buffer, int radix)
    dec→bOut := StrGet(buf)
    return dec→bOut
  }
}
