#Requires AutoHotKey 2.1-alpha.4

class oApp { ; defines a single app as a class with a custom Enum so that you can use it as fn(oApp*) in fn(arg1,arg2,...)
  static prop_name	:= ['app'	,'WorkDir'	,'Size'	,'Title'	,'PosFix'	,'Menu'	,'Match'	,'cli']
  static prop_def 	:= [''   	,''       	,''    	, 1     	, 0      	, 1    	,'exe'  	,''       ]
  __Enum(varCount) {
    static maxLen := oApp.prop_name.Length, prop_name := oApp.prop_name
    i:=0
    EnumElements(                &el) {
      if ++i > maxLen {
        return false
      } else {
        el := this.%prop_name[i]%
        return true
      }
    }
    EnumIndexAndElements(&index, &el) {
      if ++i > maxLen {
        return false
      } else {
        index := i
        el    := this.%prop_name[i]%
        return true
      }
    }
    return (varCount = 1) ? EnumElements : EnumIndexAndElements
  }
  __New(arg*) {
    if not arg.Length = oApp.prop_name.Length {
      throw ValueError("Expecting ‘" oApp.prop_name.Length "’ arguments, not ‘" arg.Length "’", -1)
    }
    for i,p_name in oApp.prop_name {
      this.%p_name% := arg.Get(i,oApp.prop_def[i])
    }
  }
}
