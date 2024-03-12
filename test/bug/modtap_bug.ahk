#Requires AutoHotKey 2.1-alpha.4
/*
https://www.autohotkey.com/boards/viewtopic.php?p=562387
The modtap_bug_hider script gets stuck with a key down state if it sees the original key down event, but for a key up event only sees an artificial one from another script
⎈↓ e↓ ⎈↑ e↑ BUGS when modtap script has a higher priority hook vs hide script, the hide script sees e↑ as an artificial event (since this script registers a e↑ hotkey)
⎈↓ e↓ e↑ ⎈↑ OK  hide script sees both e↓ and e↑ original events since this script doesn't register modifers
*/

!f1::Reload()

Hotkey('$vk45'   , hkModTap,'I1') ;$ hook is installed anyway due to callback?
Hotkey('$vk45 Up', hkModTap,'I1') ;
hkModTap(hk_dirty) {
  hk := StrReplace(StrReplace(hk_dirty,'~'),'$') ; other hotkeys may register first with ＄ ˜
  if hk = 'vk45 Up' { ;
    dbgtxt:= '↑' hk_dirty         ' l' A_SendLevel ' h' A_KeybdHookInstalled  ' hkModTap'
    ToolTip(dbgtxt, 0,265, 5)
    SetTimer () => ToolTip(,,,5), -2000
    ; SendEvent('{blind}e') ;
    ; SendEvent('{e up}') ;
  } else {
    dbgtxt:= '↓' hk_dirty '     ' ' l' A_SendLevel ' h' A_KeybdHookInstalled  ' hkModTap'
    ToolTip(dbgtxt, 0,235, 6)
    SetTimer () => ToolTip(,,,6), -2000
    ; SendEvent('{e down}') ;
    Send('{e down}') ;
    ; SendInput('{e down}') ;
    ; Send('e') ;
  }
}
