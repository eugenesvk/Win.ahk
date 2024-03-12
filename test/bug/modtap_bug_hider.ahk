#Requires AutoHotKey 2.1-alpha.4
!f2::Reload()

Hotkey('~*vk45'   , hkTestHider) ; set E to type 'e' right away, report its "physical" state and do nothing
Hotkey('~*vk46'   , hkTestHider) ; bind f to just show the tooltip with the status of E
; Hotkey('~*vk45 Up', hkTestHider)
hkTestHider(hk) {
  hkclean := StrReplace(StrReplace(StrReplace(StrReplace(hk,' UP'),'*'),'~'),'$')
  ; dbgtxt:=(GetKeyState(hkclean,"P")?'↓':'↑') hkclean '`n' (GetKeyState('e',"P")?'↓':'↑') 'e'
  ; dbgtxt.=' ' (GetKeyState('f',"P")?'↓':'↑') 'f' ' `n#' A_KeybdHookInstalled
  dbgtxt:=     (GetKeyState('vk45',"P")?'↓':'↑') 'vk45 ' (GetKeyState('e',"P")?'↓':'↑') 'e (phys)'
  dbgtxt.='`n' (GetKeyState('vk45'    )?'↓':'↑') 'vk45 ' (GetKeyState('e'    )?'↓':'↑') 'e'
  dbgtxt.='`n' (GetKeyState('vk46',"P")?'↓':'↑') 'vk46 ' (GetKeyState('f',"P")?'↓':'↑') 'f (phys)'
  dbgtxt.='`n' (GetKeyState('vk46'    )?'↓':'↑') 'vk46 ' (GetKeyState('f'    )?'↓':'↑') 'f'
  if InStr(hk, 'Up') {
    ToolTip(dbgtxt, 0,  0, 11)
    SetTimer () => ToolTip(,,,11), -2000
  } else {
    ToolTip(dbgtxt, 0,100, 12)
    SetTimer () => ToolTip(,,,12), -2000
  }
  ; SendLevel 1
  ; SendInput('{vk45 Up}') ;doesn't help
  ; SendLevel 0
}
