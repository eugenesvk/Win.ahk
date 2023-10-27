#Requires AutoHotKey 2.1-alpha.4

class numFunc {
  static bit2ⁿ−1(n) {
    return 2**n - 1
  }
  static ɵ(c) {
    return this.bit2ⁿ−1(8*c)
  }
}
