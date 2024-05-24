#Requires AutoHotKey 2.1-alpha.4
#include <libFunc App>	; Functions: app-specific

shell	:= ComObject("Shell.Application") ;;; remove after loading form the main script
; ————— Make Tab into a custom prefix key
  ; Treated as *Tab, *Wildcard: Fire the hotkey even if extra modifiers are being held down
  ; Tab & r::	(run)	;⭾1​	vk31 ⟶ Open Path1 in DirectoryOpus

  Tab & vk41::  	Run(shellFd["ActionCenter"]) 	;⭾a​	vk41 ⟶ ActionCenter (def ❖a)
  ; Tab & vk43::	Run(shellFd["CortanaSpeech"])	;⭾c​	vk43 ⟶ CortanaSpeech (def ❖c)
  Tab & vk44::{ 	                             	;⭾d​	vk44 ⟶ Show Desktop (def ❖d)
                	global shell                 	; 111+ hotkeys are assume-local
                	shell.ToggleDesktop()        	;
  }             	                             	;
  Tab & e::     	Run(shellFd["Explorer"])     	;⭾e​	vk45 ⟶ Run Explorer (def ❖e)
  Tab & g::     	Run(shellFd["GameBar"])      	;⭾g​	vk47 ⟶ Show Game Bar (def ❖g)
  ; Tab & h::   	Run(shellFd["Share"])        	;⭾h​	vk48 ⟶ Share (def ❖h)
  Tab & i::     	Run(shellFd["Settings"])     	;⭾i​	vk49 ⟶ Open Settings (def ❖i)
  Tab & k::     	Run(shellFd["Connect"])      	;⭾k​	vk4B ⟶ Open Connect (def ❖k)
  Tab & l::     	WinLock()                    	;⭾l​	vk4C ⟶ LockPC+Disable❖l (def ❖l)
  ; Tab & p::   	Run(shellFd["Project"])      	;⭾p​	vk50 ⟶ Run (def ❖p)
  Tab & r::     	Run(shellFd["Run"])          	;⭾r​	vk52 ⟶ Run (def ❖r)
  Tab & s::     	Run(shellFd["Cortana"])      	;⭾s​	vk53 ⟶ Run (def ❖s)

  ; Restore Tab's original functionality
  #HotIf WinActive("ahk_group Games")
  Tab:: {
    ; SendPlay '{Tab Down}{Tab Up}'
    SendPlay '{Tab Down}'
    SendPlay '{Tab Up}'
  }
  #HotIf

  Tab Up:: {	;*⌥⭾​	vk09 ⟶ Tab Restore (on release without ~)
    static _d := 1 ; 0 to hide tooltips, 1 to hide debug with dbg=0
    ,anyMod	:= keyFunc.anyMod
    dbgk := '↑⭾'
    isMod := anyMod(0)
    isModP := anyMod(1)
    if   A_PriorHotkey = '~*LCtrl up'
      && A_PriorKey  = 'Tab'
      && A_TimeSincePriorHotkey<120 { ;try to block ⭾ on ⎈↓⭾↓⎈↑⭾↑
      dbgk := '✗' dbgk ' pre_hk=' A_PriorHotkey ' ¦k=' A_PriorKey ' 🕐' A_TimeSincePriorHotkey ;~*LCtrl up
    } else {
      ; dbgtt(0,'✓' A_PriorHotkey ' ¦ ' A_PriorKey,🕐:=3,10,150,A_ScreenHeight*.9) ;~*LCtrl up
      SendInput '{Tab}'
    }
    dbgk .= isMod ' ' isModP ;
    (dbg<_d)?'':(log(0,dbgk)), (dbg<_d+1)?'':(dbgtt(0,dbgk,🕐:=3,9,95,A_ScreenHeight*.9))
  }
  *!Tab::  	SendInput '{Blind}!{Tab}'	;*⌥⭾​	vk09 ⟶ *⌥Tab Restore (* can use with other mods)
  ; *^Tab::	SendInput '{Blind}^{Tab}'	;*^⭾​	vk09 ⟶ *^Tab Restore
  *#Tab::  	SendInput '{Blind}#{Tab}'	;*#⭾​	vk09 ⟶ *#Tab Restore

  ; Fixes StrokesPlus.net with these commands
    ; ^Tab : sp.SendModifiedVKeys([vk.RCONTROL]          , vk.TAB);
    ; ^+Tab: sp.SendModifiedVKeys([vk.RCONTROL,vk.RSHIFT], vk.TAB);
  +Tab::	SendInput '{Shift Down}{Tab}{Shift Up}'	;⇧⭾​	vk09 ⟶ Shift+Tab Restore
  ; moved to PC-only @aWin.ahk due to conflict with Bootcamp
  ; ^Tab:: 	SendInput '{Ctrl Down}{Tab}{Ctrl Up}'                      	;^⭾​ 	vk09 ⟶ Ctrl+Tab Restore
  ; ^+Tab::	SendInput '{Ctrl Down}{Shift Down}{Tab}{Ctrl Up}{Shift Up}'	;⇧^⭾​	vk09 ⟶ Ctrl+Shift+Tab Restore

  ; StrokesPlus via keyboard
  ; VKBF::click "down right"
  ; VKBF up::click "up right"

; ————————————————————————— Folders —————————————————————————————————
  ;#`::Run(Utils . "Directory Opus\DOpusrt.exe /acmd Go LASTACTIVELISTER NEW") ;❖`​ vk? ⟶ ?
  Tab & 1::	OpusDir_CD(Path1)	;⭾1​	vk31 ⟶ Open Path1 in DOpus
  Tab & 2::	OpusDir_CD(Path2)	;⭾2​	vk32 ⟶ Open Path2 in DOpus
  Tab & 3::	OpusDir_CD(Path3)	;⭾3​	vk33 ⟶ Open Path3 in DOpus
  Tab & 4::	OpusDir_CD(Path4)	;⭾4​	vk34 ⟶ Open Path4 in DOpus
  Tab & 5::	OpusDir_CD(Path5)	;⭾5​	vk35 ⟶ Open Path5 in DOpus
  Tab & 6::	OpusDir_CD(Path6)	;⭾6​	vk36 ⟶ Open Path6 in DOpus
  Tab & 7::	OpusDir_CD(Path7)	;⭾7​	vk37 ⟶ Open Path7 in DOpus
  Tab & 8::	OpusDir_CD(Path8)	;⭾8​	vk38 ⟶ Open Path8 in DOpus
