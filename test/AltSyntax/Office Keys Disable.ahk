#Requires AutoHotKey 2.0.10
disable_OfficeKey()
disable_OfficeKey() {
; Disable Office Shortcut (Ctrl+Alt+Shift+Win)
  ; Method1a Map2Self (allow mapping to arbitrary command in other Apps)
    ; d(OneDrive) l(LinkedIn) n(OneNote) o(Outlook) p(PowerPoint) t(Teams) w(Word) x(Excel) y(Yammer)
    loop parse "dlnoptwxy" { ; ⇧^❖⌥d​ vk44 ⟶ ⇧^❖⌥d (OneDrive)
      hkSendC('$+^#!' vk[A_LoopField], blind '{' vk[A_LoopField] '}')
    }
  ; Method1b
  $+^#!d::  ControlSend('{Blind}+^#!{' . SubStr(A_ThisHotkey,6) . '}',,"A") ;⇧^❖⌥d​ vk44 ⟶ ⇧^❖⌥d (OneDrive)
  $+^#!l::  ControlSend('{Blind}+^#!{' . SubStr(A_ThisHotkey,6) . '}',,"A") ;⇧^❖⌥l​ vk4C ⟶ ⇧^❖⌥l (LinkedIn)
  $+^#!n::  ControlSend('{Blind}+^#!{' . SubStr(A_ThisHotkey,6) . '}',,"A") ;⇧^❖⌥n​ vk54 ⟶ ⇧^❖⌥n (OneNote)
  $+^#!o::  ControlSend('{Blind}+^#!{' . SubStr(A_ThisHotkey,6) . '}',,"A") ;⇧^❖⌥o​ vk4F ⟶ ⇧^❖⌥o (Outlook)
  $+^#!p::  ControlSend('{Blind}+^#!{' . SubStr(A_ThisHotkey,6) . '}',,"A") ;⇧^❖⌥p​ vk50 ⟶ ⇧^❖⌥p (PowerPoint)
  $+^#!t::  ControlSend('{Blind}+^#!{' . SubStr(A_ThisHotkey,6) . '}',,"A") ;⇧^❖⌥t​ vk54 ⟶ ⇧^❖⌥t (Teams)
  $+^#!w::  ControlSend('{Blind}+^#!{' . SubStr(A_ThisHotkey,6) . '}',,"A") ;⇧^❖⌥w​ vk57 ⟶ ⇧^❖⌥w (Word)
  $+^#!x::  ControlSend('{Blind}+^#!{' . SubStr(A_ThisHotkey,6) . '}',,"A") ;⇧^❖⌥x​ vk58 ⟶ ⇧^❖⌥x (Excel)
  $+^#!y::  ControlSend('{Blind}+^#!{' . SubStr(A_ThisHotkey,6) . '}',,"A") ;⇧^❖⌥y​ vk59 ⟶ ⇧^❖⌥y (Yammer)

  ; Method2 specific unassigned
  +^#!d::	SendInput '{blind}{vkE8}'	;⇧^❖⌥d​	vk44 ⟶ unassigned (OneDrive)
  +^#!l::	SendInput '{Blind}{vkE8}'	;⇧^❖⌥l​	vk4C ⟶ unassigned (LinkedIn)
  +^#!n::	SendInput '{Blind}{vkE8}'	;⇧^❖⌥n​	vk54 ⟶ unassigned (OneNote)
  +^#!o::	SendInput '{Blind}{vkE8}'	;⇧^❖⌥o​	vk4F ⟶ unassigned (Outlook)
  +^#!p::	SendInput '{Blind}{vkE8}'	;⇧^❖⌥p​	vk50 ⟶ unassigned (PowerPoint)
  +^#!t::	SendInput '{Blind}{vkE8}'	;⇧^❖⌥t​	vk54 ⟶ unassigned (Teams)
  +^#!w::	SendInput '{Blind}{vkE8}'	;⇧^❖⌥w​	vk57 ⟶ unassigned (Word)
  +^#!x::	SendInput '{Blind}{vkE8}'	;⇧^❖⌥x​	vk58 ⟶ unassigned (Excel)
  +^#!y::	SendInput '{Blind}{vkE8}'	;⇧^❖⌥y​	vk59 ⟶ unassigned (Yammer)

  ; Method3 Generic unassigned (blocks all ⇧^❖⌥X combos)
  ; superuser.com/questions/1457073/how-do-i-disable-specific-windows-10-office-keyboard-shortcut-ctrlshiftwinal
  ; Since the main Office shortcut can be activated by combining the modifier keys in any order, suppressing it requires several hotkeys; one for each "suffix" key:
  #^!Shift::
  #^+Alt::
  #!+Ctrl::
  ^!+LWin::
  ^!+RWin::
    Send '{Blind}{vkE8}'
  return
}
