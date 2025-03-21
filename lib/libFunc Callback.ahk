#Requires AutoHotKey 2.1-alpha.4

#include <WinEvent>
#include <libFunc Dbg>
; ————————————————————————— WinEvent callback Functions —————————————————————————
cbCreate_Borderless(winID, evt, tick) { ; apply borderless style to a window
  static _d := 1
  loop 10 {
    sleep(A_Index*25)
    if WinExist(winID) {
      Win_TitleToggle(0,winId, "-")
      (dbg<_d)?'':dbgTL(_d,evt.MatchCriteria[1] '`niter ' A_Index '@ ' tick ' withID= ' winID ' `ntype=' evt.EventType ' #' evt.count,{🕐:5,x:0}) ;' match=' Obj→Str(evt.MatchCriteria), 5)
      break
    }
  }
}
