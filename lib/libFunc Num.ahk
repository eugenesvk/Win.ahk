#Requires AutoHotKey 2.0.10

class numFunc {
  static bit2ⁿ−1(n) {
    return 2**n - 1
  }
  static ɵ(c) {
    return this.bit2ⁿ−1(8*c)
  }
  static bin→dec := (n) => (StrLen(n) > 1 ? numFunc.bin→dec(SubStr(n,1,-1)) << 1 : 0) | SubStr(n,-1) ; autohotkey.com/board/topic/49990-binary-and-decimal-conversion
}
