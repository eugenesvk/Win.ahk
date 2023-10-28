#Requires AutoHotKey 2.1-alpha.4

class numFunc {
  static bitmax(n) {
    return 2**n - 1
  }
  static ɵ(c) {
    return this.bitmax(8*c)
  }
}
