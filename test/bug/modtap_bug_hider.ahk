#Requires AutoHotKey 2.1-alpha.4
!f2::Reload()

Hotkey('~*vk45'   , hkTestHider) ; set E to type 'e' right away, report its "physical" state and do nothing
; Hotkey('~*vk45 Up', hkTestHider)
hkTestHider(hk) {
  hkclean := StrReplace(StrReplace(StrReplace(StrReplace(hk,' UP'),'*'),'~'),'$')
  dbgtxt:=(GetKeyState(hkclean,"P")?'↓':'↑') hkclean '`n' (GetKeyState('e',"P")?'↓':'↑') 'e' ' h' A_KeybdHookInstalled
  ToolTip(dbgtxt, 0,0, 11)
  SetTimer () => ToolTip(,,,11), -2000
  ; SendLevel 1
  ; SendInput('{vk45 Up}') ;doesn't help
  ; SendLevel 0
}
