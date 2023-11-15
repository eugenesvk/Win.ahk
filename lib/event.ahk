#Requires AutoHotKey 2.0.10

class Event { ; from OnMouseEvent emitter autohotkey.com/boards/viewtopic.php?f=83&t=104629&p=464765&hilit=this.MouseMoved.Bind#p464765
  Add     	:=  1 ; will add    function to the end       of the list
  Remove  	:=  0 ; will remove listener if it is         in the list
  AddBegin	:= -1 ; will add    function to the beginning of the list
  Listeners := [] ; Add a listener
  onFire(fn,  addremove := this.Add) {
    ; Return value informs whether to start or stop whichever system will fire this event, returns:
    ;  1 if the first listener was added
    ;	-1 if the last  listener was removed
    ;	 0 otherwise
    if        addremove == this.Add      {
          return (this.Listeners.Push(fn)       ,   this.Listeners.Length == 1)
    } else if addremove == this.Remove   {
      for i, v in this.Listeners {
        if v == fn {
          return (this.Listeners.RemoveAt(i    ), -(this.Listeners.Length == 0))
        }
      }
      return 0
    } else if addremove == this.AddBegin {
          return (this.Listeners.InsertAt(1, fn),   this.Listeners.Length == 1 )
    } else {
      throw ValueError("Parameter #2 invalid", -1, addremove)
    }
  }

  Fire(args*) { ; Call all listeners with args Return nothing
    for fn in this.Listeners { ; warning: it's possible to modify the array during traversal
      fn(args*)
    }
  }
}
