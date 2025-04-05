#Requires AutoHotKey 2.1-alpha.18
#include <Locale>

initTrayMenu()
initTrayMenu() {
  ; Add language change
  MyCallbackRu := cbMenuLayoutSwitchTgt.bind(,,,ruU)
  MyCallbackEn := cbMenuLayoutSwitchTgt.bind(,,,enU)
  A_TrayMenu.Insert("&Suspend Hotkeys"	, "&Д → lng"    	, cbMenuLayoutSwitch)
  A_TrayMenu.Insert("&Suspend Hotkeys"	, "&L → lng"    	, cbMenuLayoutSwitch)
  A_TrayMenu.Insert("&Suspend Hotkeys"	, "&F → Русский"	, MyCallbackRu)
  A_TrayMenu.Insert("&Suspend Hotkeys"	, "&В → English"	, MyCallbackEn)
  A_TrayMenu.Insert("&Suspend Hotkeys"	, ""            	,)
  A_TrayMenu.SetIcon("&F → Русский"   	, "img\lng-RU48.ico")
  A_TrayMenu.SetIcon("&В → English"   	, "img\lng-US48.ico")

  ; Rename defaults to make accelerator key more prominent
  A_TrayMenu.Rename("&Suspend Hotkeys"	, "&S Suspend Hotkeys")
  A_TrayMenu.Rename("&Window Spy"     	, "&W Window Spy")
  A_TrayMenu.Rename("&Reload Script"  	, "&R Reload Script")
  A_TrayMenu.Rename("&Edit Script"    	, "&E Edit Script")
  A_TrayMenu.Rename("E&xit"           	, "&Q Quit")
  A_TrayMenu.Rename("&Pause Script"   	, "&P Pause Script")
  A_TrayMenu.Rename("&Open"           	, "&O Open")
  A_TrayMenu.Rename("&Help"           	, "&H Help")
}
