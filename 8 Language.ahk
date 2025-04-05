#Requires AutoHotKey 2.1-alpha.4
#include <Locale>	; Various i18n locale functions and win32 constants

; Remap Capslock to keyboard layout switching between User layouts (learn.microsoft.com/en-us/openspecs/windows_protocols/ms-lcid/70feba9f-294e-491e-b6eb-56532684c37f)
^CapsLock::
!CapsLock::                     	{	;⎇⇪​	vk09 ⟶ Ctrl+Tab Restore
  ; SetCapsLockState "AlwaysOff"	;[CapsLock] disable
  LayoutSwitch()
  ; SendInput '#{Space}'	;[Alt+CapsLock] to switch Keyboard Layout (Win+Space)
  }
