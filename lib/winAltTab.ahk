#Requires AutoHotKey 2.1-alpha

#include <libFunc Dbg>	; Functions: Debug
#include <Win>        	; win status

; Keeps own list of activated window history so fixes 2 known bugs with AHK's default WinGetList that retrieves only Z-order:
  ; minimized window goes to the end of the list instead of being #2, so going down by 1 does NOT switch to the most recent window
  ; topmost windows do NOT have any recency order, their ordering priority is fixed, so you can't switch to the most recent topmost window

class WinAltTab {
  static History := [] ; deduped list of activated window IDs, most recent at the bottom
   , max_history	:= 1000
   , is_init    	:= false
   , cbFunc     	:= []	; win event callback to allow freeing them later
   , hooks      	:= []	;
   , EVENT_SYSTEM_FOREGROUND:=3, EVENT_OBJECT_UNCLOAKED:=32792, WINEVENT_OUTOFCONTEXT:=0

  static __new() {
    if not this.is_init { ; prefill history with the ~order from current z-order windows
      this.History.capacity := this.max_history
      this.is_init	:= true
      win_z_order := win.get_switcher_list_z_order()
      loop win_z_order.Length { ; history is stored in most recent at the bottom
        this.History.push(win_z_order[-A_Index])
      }
    }
  }

  static cbProcEvHook(hook, event, win_id, objectid, childid, threadid, timestamp) {
    ; handle hook, u32 event, handle win_id, i32 objectid, i32 childid, u32 threadid, u32 timestamp
    ; static constT := 'embed' ;embed mmap
     ; , winAPI                 	:= winAPIconst_loader.load(constT)
     ; , cC                     	:= winAPI.getKey_Any .Bind(winAPI)
     ; , EVENT_SYSTEM_FOREGROUND	:=cC("EVENT_SYSTEM_FOREGROUND"	) ;3
     ; , EVENT_OBJECT_UNCLOAKED 	:=cC("EVENT_OBJECT_UNCLOAKED" 	) ;32792
     ; , WINEVENT_OUTOFCONTEXT  	:=cC("WINEVENT_OUTOFCONTEXT"  	) ;0
    static winAct := WinAltTab.onShellWinActivated.Bind(WinAltTab)
    switch (event)  {
      case this.EVENT_SYSTEM_FOREGROUND:
        ; dbgtt(0,"this.EVENT_SYSTEM_FOREGROUND",2,, x:=0,y:=0)
        winAct(win_id, ex_invis:=false)
      case this.EVENT_OBJECT_UNCLOAKED:
        ; dbgtt(0,"this.EVENT_OBJECT_UNCLOAKED" ,2,, x:=0,y:=0)
        winAct(win_id, ex_invis:=true)
    }
  }

  static set_WinEv_hook(evMin, evMax, cbFunc) {
     cbFunc   	:= cbFunc.Bind(WinAltTab)
     pCallback	:= CallbackCreate(cbFunc,, 7) ; 7 parameters
     hEvHook  	:= DllCall("SetWinEventHook" ; → HWINEVENTHOOK ; learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setwineventhook
       ,"Uint"	,evMin                     	;← eventMin         DWORD
       ,"Uint"	,evMax                     	;← eventMax         DWORD
       , "Ptr"	,0                         	;← hmodWinEventProc HMODULE
       , "Ptr"	,pCallback                 	;← pfnWinEventProc  WINEVENTPROC
       ,"Uint"	,0                         	;← idProcess        DWORD
       ,"Uint"	,0                         	;← idThread         DWORD
       ,"Uint"	,this.WINEVENT_OUTOFCONTEXT	;← dwFlag           DWORD	; callback function is not mapped into the address space of the process that generates the event. Because the hook function is called across process boundaries, the system must queue events. Although this method is asynchronous, events are guaranteed to be in sequential order. For more information, see Out-of-Context Hook Functions.
     )
     this.cbFunc.push(pCallback)
     return hEvHook
   }


  static onShellWinActivated(win_id, ex_invis:=true) {
    WinAltTab.winHistory_add(win_id, ex_invis)
  }

  static win_history_trim() { ; trims history if it exceeds max_history by removing the first 25%
    static _d := 0, _d1 := 1, _d2 := 2
    if this.History.Length > this.max_history {
      (dbg<_d1)?'':(dbgTT(0,'Trimming History',🕐:=1,,x:=0,y:=0))
      loop Round(0.25 * this.max_history) {
        this.History.RemoveAt(1)
      }
    }
  }

  static winHistory_add(win_id, ex_invis:=true) { ;
    static _d := 0, _d1 := 1, _d2 := 2
    (dbg<_d2)?'':(dbgTT(0,win_id,🕐:=1,id:=0,x:=0,y:=50))
    ; win_id = win.GetCoreWindow(win_id) ; hosted window in case of UWP host
    if this.History.Length and (this.History[-1] = win_id) {
      (dbg<_d2)?'':(dbgTT(0,"already most recent in history",🕐:=1,id:=0,x:=-1,y:=-1))
      return
    }
    if (i_found := this.History.IndexOf(win_id, -1)) { ; Push 'win_id' to the end if it exists
      this.History.RemoveAt(i_found)
      this.History.push(win_id)
      (dbg<_d2)?'':(dbgTT(0,"deduped " win_id,🕐:=1,id:=0,x:=0,y:=50))
      return
    }
    ; 'win_id' is new, validate and add it. Only cheap basic checks since this list is only for ordering, full checks will be done before actual use
    wse := WinGetExStyle(win_id)
    if not win.is_alt_tab(win_id) {
      (dbg<_d2)?'':(dbgTT(0,"not ⎇⭾" win_id,🕐:=1,id:=0,x:=0,y:=50))
      return
    }
    ; 'win_id' is valid and should be added
    this.History.push(win_id)
    this.win_history_trim()
    (dbg<_d1)?'':(dbgTT(0,"added " win_id,🕐:=1,id:=0,x:=0,y:=50))
  }

  static get_hooks() {
    return this.hooks
  }
  static set_hooks() {
    set_WinEv_hook := this.set_WinEv_hook.Bind(this)
    if this.hooks.Length > 0 {
      ; dbgtt(0, "hooks exist, returning...")
      return this.hooks
    } else {
      ; dbgtt(0, "Set 2 hooks")
      this.hooks.push(set_WinEv_hook(this.EVENT_SYSTEM_FOREGROUND, this.EVENT_SYSTEM_FOREGROUND, this.cbProcEvHook))
      this.hooks.push(set_WinEv_hook(this.EVENT_OBJECT_UNCLOAKED , this.EVENT_OBJECT_UNCLOAKED , this.cbProcEvHook))
    }
  }
}

cbExitUnsetHooks(ExitReason, ExitCode) { ; Uninstall event hooks
  for i, hk in WinAltTab.get_hooks() {
    ; dbgtt(0, i " unset hook", 4)
    DllCall("UnhookWinEvent", "Ptr",hk)
    for cbF in WinAltTab.cbFunc {
      SetTimer(CallbackFree.Bind(cbF), -12000) ; done with a latency to let the message queue empty of unfired events
    }
  }
}
OnExit(cbExitUnsetHooks)
