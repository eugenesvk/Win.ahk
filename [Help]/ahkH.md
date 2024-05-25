# Help

```ahk
isStandAlone := (A_ScriptFullPath = A_LineFile) ;
```

# Libraries
  `OnMouseEvent.ahk` - Call back whenever the mouse moves, clicks or scrolls [src](https://www.autohotkey.com/boards/viewtopic.php?f=83&t=104629&p=464765&hilit=this.MouseMoved.Bind#p464765)

[Symbols](autohotkey.com/docs/Hotkeys.htm#Symbols)
[Link2](gist.github.com/ronjouch/2428558#file-ronj-autohotkey-ahk-L80)
```ahk
#Warn                           	; Enable all warnings to assist with detecting common errors
#Warn UseUnsetLocal, OutputDebug	; Warn when a local variable is used before it's set; send warning to OutputDebug
#Persistent                     	; Keeps a script permanently running (that is, until the user closes it or ExitApp is encountered).

; Waiting for a key release instead of using bad GetKeyState("a", "P")
  ; autohotkey.com/boards/viewtopic.php?f=7&t=19745
  ;!!! Gosub is now removed (see autohotkey.com/v2/v2-changes.htm)
  F11::
    SetTimer "SendA", "10"
    Gosub("SendA")
    Return
  F11 up::
    SetTimer "SendA", "Off"
    Return
  SendA:
    SendInput 'a'
    Return
  F12::
    SetTimer "SendB", "10"
    Gosub("SendB")
    Return
  F12 up::
    SetTimer "SendB", "Off"
    Return
  SendB:
    SendInput 'b'
    Return
```
"SC" (scancode) identifies a physical key, while "VK" identifies a virtual key [vk Win list](https://learn.microsoft.com/en-us/windows/win32/inputdev/virtual-key-codes)
  - Keyboard layout maps SC to VK, so the SC doesn't change when you switch layouts within Windows. When defining a hotkey, you can use just SC or just VK instead of both
  - Scan codes are dependent on your hardware and might differ from computer to computer. Virtual keys are mapped to be the same keys on any system
  __NB!__ VK hotkeys with keyboard hook (`*vk24` or `~vk24`), will fire for only one of the keys, not both (e.g. NumpadHome but not Home)
  vk  sc 	Name      	Comment
  24  047	NumpadHome	(with NumLock on)
  24  147	Home      	.
  67  047	Numpad7   	(with Numlock off)


```ahk
;avoid autorepeat, asterisk, tilde, dollar sign, ampersand
  $*a::    	; * prefix fires the hotkey even if extra modifiers are being held down
           	; $ prefix forces a keyboard hook, needed to avoid multiple triggers
           	; ~ prefix When the hotkey fires, its key's native function will not be blocked (hidden from the system)
  Tab & r::	; & prefix Make Tab into a custom prefix key. Act as though they have wildcard(*) modifier by default
  SendInput '{blind}{a down}'   ;When {Blind} is the first item in the string, the program avoids   releasing Alt/Control/Shift/Win if they started out in the down position
  KeyWait a
  SendInput '{a up}'
  return
```

`Numpad0 & Numpad1:: MsgBox ("You pressed Numpad1 while Numpad0 was pressed.")`

__Pressing CTRL + ALT + S__ causes the system to behave as if you pressed CTRL + ALT + DELF (due to the aggressive detection of this key combination). To avoid this, you should wait with KeyWait to release the keys; for example:
```ahk
 ^! S ::
 KeyWait Control
 KeyWait Alt
 Send {Delete}
 return

 ActiveID := WinGetID("A")
 WinMaximize("ahk_id" ActiveID)
 WinGetPos(,, k_WindowWidth, k_WindowHeight, "A")
 MsgBox("The ID of the active window is " ActiveID ". Width and Height are" k_WindowWidth k_WindowHeight)
```

__Wildcard__: Executes the hotkey even if additional modifier keys are held down. This is often used in conjunction with the re-assignment of keys. For example:
```ahk
  * # C :: Run Calc.exe ;  WIN + C, SHIFT + WIN + C and CTRL + WIN + C, etc. will trigger the following hotkey.
  * ScrollLock :: Run Notepad ;  The ROLL button triggers the following hotkey, even if modifier keys are held down.
Wildcard hotkeys always use the keyboard hook, as does any other hotkey that would match a wildcard hotkey. For example, *a:: cause ^a:: to go back to the hook.
```
; Array to string and back https://autohotkey.com/boards/viewtopic.php?t=1878
; some functions used in these scripts
  ControlGetVisible(Control, WinTitle, WinText, ExcludeTitle, ExcludeText) Returns 1 (true) if Control is visible, or 0 (false) if hidden

```ahk
  ; Tooltip
  CoordMode "ToolTip", "Screen"  	; use absolute screen coordinates
  Tooltip "Text", 2550, 1340     	;
  SetTimer () => ToolTip(), -2000	; unnamed fat function to kill in 2sec
```

```ahk
; tection of single, double, and triple-presses of a hotkey. This allows a hotkey to perform a different operation depending on how many times you press it:
; #z::
vkBF:: ;/ slash key
KeyWinC() {   ; This is a function hotkey
	static winc_presses := 0
	if winc_presses > 0 { ; SetTimer already started, so we log the keypress instead.
		winc_presses += 1
		return
	}
	winc_presses := 1 ; Otherwise, this is the first press of a new series. Set count to 1 and start the timer:
	SetTimer "After400", -400 ; Wait for more presses within a 400 millisecond window.
	After400() { ; This is a nested function.
		if winc_presses = 1 { ; The key was pressed once.
			ToolTip("First press")
			SendEvent('{blind}{vkBF down}{vkBF up}')
		} else if winc_presses = 2 { ; The key was pressed twice
			ToolTip("Second press")
			SendEvent('{blind}{vkBF down}{vkBF up}')
		} else if winc_presses > 2 {
			ToolTip("Third or subsequent press")
			SendEvent('{blind}{vkBF down}{vkBF up}')
		}
		SetTimer () => ToolTip(), -2000 ;debug
		winc_presses := 0 ; Regardless of which action above was triggered, reset the count to prepare for the next series of presses:
	}
}
```




[Disable Office Keys](superuser.com/questions/1457073/how-do-i-disable-specific-windows-10-office-keyboard-shortcut-ctrlshiftwinal) see `Office Keys Disable.ahk`

# Send vs ControlSend
https://autohotkey.com/board/topic/62117-implementation-of-send-vs-controlsend/
The help file describes, in laman's terms, the effect of the command. In actual fact, ControlSend sends messages directly to a window or control which are ordinarily sent by Windows in response to keyboard input. If the target program does not respond to those messages but instead monitors keyboard activity via some other method, it will not have the desired effect.

Send uses one of three different APIs provided by the OS to simulate keyboard input. These APIs may in turn generate messages identical to the ones generated by ControlSend, but also affect the "keyboard state" of the active window's thread. If a program asks "is key x pressed", the answer may be "yes" if Send was used but "no" if ControlSend was used.

You don't need to understand it, just accept that they are different and use whichever command works for your purpose.

https://g-ek.com/clsid-guid-spisok-shell-v-windows-10
http://ipmnet.ru/~sadilina/Windows/227.html
run       	`Explorer.exe Shell:::{2559a1f3-21d7-11d4-bdaf-00c04f60b9f0}`
security  	`Explorer.exe Shell:::{2559a1f2-21d7-11d4-bdaf-00c04f60b9f0}`
system    	`Explorer.exe Shell:::{BB06C0E4-D293-4f75-8A90-CB05B6477EEE}`
Start Menu	`Explorer.exe Shell:::{48e7caab-b918-4e58-a94d-505519c795dc}`
`Explorer.exe Shell:::{04731B67-D933-450a-90E6-4ACD2E9408FE}`

https://www.askvg.com/tip-how-to-disable-all-win-keyboard-shortcuts-hotkeys-in-windows/

A2  01D	a	d	0.66	LControl
09  00F	a	d	0.02	Tab
09  00F	a	u	0.00	Tab
A2  01D	a	u	0.00	LControl
74  03F	 	d	0.98	F5

A2  01D	a	d	0.44	LControl
09  00F	a	d	0.00	Tab
09  00F	a	u	0.00	Tab
A2  01D	a	u	0.00	LControl
74  03F	 	d	0.39	F5


^Tab::    SendInput '{Blind}^{Tab}'
A2  01D	a	d	0.02	LControl
09  00F	h	d	0.00	Tab
09  00F	a	u	0.00	Tab
A2  01D	a	u	0.00	LControl
09  00F	i	d	0.00	Tab
09  00F	i	u	0.00	Tab
74  03F	 	d	0.81	F5

^Tab::    SendInput '^{Tab}'
A2  01D	a	d	0.00	LControl	
09  00F	h	d	0.00	Tab     	
09  00F	a	u	0.00	Tab     	
A2  01D	a	u	0.00	LControl	
09  00F	i	d	0.00	Tab     	
09  00F	i	u	0.00	Tab     	
A2  01D	i	u	0.00	LControl	
74  03F	 	d	0.58	F5  

^Tab::    SendInput '{LCtrl Down}{Tab}{LCtrl Up}'
A2  01D	a	d	0.02	LControl	
09  00F	h	d	0.00	Tab     	
09  00F	a	u	0.00	Tab     	
A2  01D	a	u	0.00	LControl	
A2  01D	i	d	0.00	LControl	
09  00F	i	d	0.00	Tab     	
09  00F	i	u	0.00	Tab     	
A2  01D	i	u	0.00	LControl	
74  03F	 	d	0.42	F5     

^Tab::    SendInput '{Blind}{LCtrl Down}{Tab}{LCtrl Up}'
A2  01D	a	d	0.00	LControl	
09  00F	h	d	0.00	Tab     	
09  00F	a	u	0.00	Tab     	
A2  01D	a	u	0.00	LControl	
A2  01D	i	d	0.00	LControl	
09  00F	i	d	0.00	Tab     	
09  00F	i	u	0.00	Tab     	
A2  01D	i	u	0.00	LControl	
74  03F	 	d	0.23	F5           


 *^Tab::	SendInput '{Blind}{LCtrl Down}{Tab}{LCtrl Up}'	;*^⭾​	vk09 ⟶ *^Tab Restore

A2  01D	a	d	0.00	LControl	
09  00F	h	d	0.00	Tab     	
09  00F	a	u	0.00	Tab     	
A2  01D	i	d	0.00	LControl	
09  00F	i	d	0.00	Tab     	
09  00F	i	u	0.00	Tab     	
A2  01D	a	u	0.00	LControl	
A2  01D	 	d	0.64	LControl	


  *^Tab::	SendInput '{LCtrl Down}{Tab}{LCtrl Up}'	;*^⭾​	vk09 ⟶ *^Tab Restore

A2  01D	a	d	0.00	LControl	
09  00F	h	d	0.00	Tab     	
09  00F	a	u	0.00	Tab     	
A2  01D	a	u	0.00	LControl	
A2  01D	i	d	0.00	LControl	
09  00F	i	d	0.00	Tab     	
09  00F	i	u	0.00	Tab     	
A2  01D	i	u	0.00	LControl	
74  03F	 	d	0.63	F5      

9B  000	 	d	1.94	RButton 	
9B  000	 	u	0.22	RButton 	
A2  01D	a	d	0.00	LControl	
A0  02A	a	d	0.00	LShift  	
09  00F	h	d	0.00	Tab     	
09  00F	a	u	0.00	Tab     	
A2  01D	i	d	0.00	LControl	
A0  02A	i	u	0.00	LShift  	
09  00F	i	d	0.00	Tab     	
09  00F	i	u	0.00	Tab     	
A2  01D	i	u	0.00	LControl	
A0  02A	a	u	0.00	LShift  	
A2  01D	a	u	0.00	LControl	
74  03F	 	d	0.76	F5   


Test
^Tab::	SendInput '{Ctrl Down}{Tab}{LCtrl Up}'	;^⭾​	vk09 ⟶ ^Tab Restore

A2  01D	a	d	0.39	LControl	
09  00F	h	d	0.00	Tab     	
09  00F	a	u	0.00	Tab     	
11  01D	i	d	0.00	Control 	
09  00F	i	d	0.00	Tab     	
09  00F	i	u	0.00	Tab     	
A2  01D	a	u	0.00	LControl	
A2  01D	i	u	0.00	LControl	
74  03F	 	d	0.26	F5         

^+Tab::	SendInput '{Ctrl Down}{Shift Down}{Tab}{Ctrl Up}{Shift Up}'	;^⇧⭾​	vk09 ⟶ ^+Tab Restore

A2  01D	a	d	0.52	LControl	
A0  02A	a	d	0.00	LShift  	
09  00F	h	d	0.00	Tab     	
09  00F	a	u	0.00	Tab     	
A0  02A	a	u	0.00	LShift  	
A2  01D	a	u	0.00	LControl	
11  01D	i	d	0.00	Control 	
10  02A	i	d	0.00	Shift   	
09  00F	i	d	0.00	Tab     	
09  00F	i	u	0.00	Tab     	
11  01D	i	u	0.00	Control 	
10  02A	i	u	0.00	Shift   	





__Creating international characters__
When you press the APOSTROPHE (') key, QUOTATION MARK (") key, ACCENT GRAVE (`) key, TILDE (~) key, or ACCENT CIRCUMFLEX,. also called the CARET key, (^) key, nothing is displayed on the screen until you press a second key:

- If you press one of the letters designated as eligible to receive an accent mark, the accented version of the letter appears.
- If you press the key of a character that is not eligible to receive an accent mark, two separate characters appear.
- If you press the space bar, the symbol (apostrophe, quotation mark, accent grave, tilde, accent circumflex or caret) is displayed by itself.

__COM Object__

- No need to free it, anyway, can't: `doc := ""`releases `ComObject` (wrapper around a `COM object`, not the object itself) see https://www.autohotkey.com/boards/viewtopic.php?t=23832)

#Tips
- ahk_group: Criteria beyond the first should be separated from the previous with exactly one space or tab (any other spaces or tabs are treated as a literal part of the previous criterion)
- HotIf allows context-sensitive hotkeys to be created and modified while the script is running (by contrast, the #HotIf directive is positional and takes effect before the script begins executing)
