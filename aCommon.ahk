#Requires AutoHotKey 2.1-alpha.4

#Warn All                                    	; Enable all warnings to assist with detecting common errors ; #Warn All, Off
SetWorkingDir(A_ScriptDir)                   	; Ensures a consistent starting directory
#SingleInstance force                        	; Reloads script without dialog box
A_MenuMaskKey := "vkE8"                      	; vkE8=unassigned. Stop sending LControl to mask release of Winkey/Alt; vk00sc000 disables automasking; vk07 was undefined, but now it's reserved for opening a game bar; vkFF no mapping
; SetCapsLockState "AlwaysOff"               	; [CapsLock] disable
InstallKeybdHook(Install:=true, Force:=false)	; Install hook even if nothing uses it (can view recent keys)
#UseHook True                                	; Any keyboard hotkeys use hook
KeyHistory(500)                              	; Limit history to last X (need >10 for Hyper) ;;; temp
ListLines 0                                  	; Potential performance boost
; SendMode("Input")                          	; blocks interspersion, useful for sending long test, but requires hook reinstall, which takes time and can bug other things, see autohotkey.com/boards/viewtopic.php?f=96&t=127074&p=562790. Superior speed and reliability. SendPlay for games to emulate keystrokes. Too fast for GUI selection of Diacritics, use SendInput individually
SendMode("Event")                            	; avoid rehooking bugs
SetKeyDelay(-1, 0)                           	; NoDelay MinPressDuration
; SetTitleMatchMode(2)                       	; |2| win title can contain WinTitle anywhere inside it to be a match

;Auto-Execute Section (AES), continues until Return, Exit, hotkey/hotstring label
;(1) AES code common to ALL macros
  dbg                          	:= 0	; Level of debug verbosity (0-none)
  dbgT                         	:= 2	; Timer for dbg messages (seconds)
  USERPROFILE                  	:= EnvGet('userProfile')
  shell                        	:= ComObject("Shell.Application")
  A_HotkeyInterval             	:= 1000	; [2000]
  A_MaxHotkeysPerInterval      	:= 200 	; [70]
  CoordMode "ToolTip", "Screen"	; Place ToolTips at absolute screen coordinates
  CoordMode "Mouse",   "Screen"	; Mouse cursor: get absolute scren coordinates
  SetMouseDelay -1             	; [10]ms Delay after each mouse movement/click, -1=none
;(2) AES code common to particular macros
  ;Gosub is removed!!! https://www.autohotkey.com/v2/v2-changes.htm
  ;Gosub, M01_InitVars
  ;-------------------------------------
  ;MACRO 01
  ;M01_InitVars: ;Initialize vars used in this macro
  ;(some code)
  ;Return
  ; TimerHold := "T0.4"	; Timer for Char-Hold.ahk​

#DllLoad "Imm32" ; Enables getting layout for consoles

; lib functions not autoloaded anymore
#include <libFunc>         	; General set of functions
#include <libFunc App>     	; Functions: app-specific
#include <libFunc Scroll>  	; Functions: Scrolling
#include <libFunc Num>     	; Functions: Numeric
#include <libFunc Dbg>     	; Functions: Debug
#include <libFunc Native>  	; Functions: Native
#include <libFunc Callback>	; Functions: callbacks for various events
#include <Unicode>         	; Unicode text functions
#include <Locale>          	; Various i18n locale functions and win32 constants
#include <io>              	;
#include <cfg FileExplore> 	; toggle extension/hidden files in Win File Explorer
#include <constKey>        	; various key constants
#include <str>             	; string helper functions
#include <sys>             	;
#include <Win>             	; Remove window borders
#include <PressH>          	; Special Char Selection
#include <WinEvent>        	; Window-related events

; #include <SelectCharGUI>                 	;
; #include <GetLocaleInfo>                 	;
#include %A_scriptDir%\gVar\varWinGroup.ahk	; App groups for window matching
#include %A_scriptDir%\8 Language.ahk      	; Alt-CapsLock switch layout Ru-En only
#include %A_scriptDir%\Hotstring.ahk       	;
#include %A_scriptDir%\9 ‹␠1 as ⎇.ahk      	; physical ⎇ (mapped to ⎈) as ⎇ restore
#include %A_scriptDir%\5 App Switcher.ahk  	; Switch in-app windows
; #include %A_scriptDir%\QuickSwitch.ahk   	; Listary Quick Switch alternative
; #include %A_scriptDir%\🖰hide on 🖮.ahk    	; Hide idle mouse cursor when typing
#include %A_scriptDir%\listen_WinMsg.ahk   	; Listen to window messages and set global vars accordingly
;#include %A_scriptDir%\xReformatPrompt.ahk	; (use exe for another thread) Auto✗ prompts with a ‘Format disk’ button

; #include %A_scriptDir%\Game\init_game.ahk	; Games

;Win10 switch between desktops
; LWin & LCtrl::SendInput('{LWin down}{LCtrl down}{Left down}{Lwin up}{LCtrl up}{Left up}')
; LWin & LAlt::SendInput('{LWin down}{LCtrl down}{Right down}{LWin up}{LCtrl up}{Right up}')

; ————————————————————————— Helpers —————————————————————————————
  *ScrollLock::ShowModStatus() ; 91  046  ScrollLock
  *CtrlBreak::ShowModStatus() ; 03  046  CtrlBreak
; ————————————————————————— Key changes —————————————————————————————
  #include %A_scriptDir%\char🠿.ahk      	; Diacritics+chars on key hold
  #include %A_scriptDir%\Char-AltTT.ahk 	; Diacritics+chars@Tooltip on Alt+Shift+?+3rd, e.g. ⌥⇧u+e=ë (Umlaut on e)
  #include %A_scriptDir%\⌂mod_modtap.ahk	; Hold vs tap without interfering with typing: Homerow mods, exit Insert in modal editor on 🠿i

; !!!!!TOO slow, check why
; $Shift:: { ; One Shot Shift. Don't hold down ⇧ to Cap! Tap ⇧ and forget, it expires in 1 second or capitalizes the next letter. No more typing ‘THe’! Frees up the pinky and is a better than Sticky Keys
;   ih := InputHook("L1 T1 I1")
;   ih.Start()
;   ih.Wait()
;   if (ih.EndReason = "Timeout") {
;     return
;   }
;   Send '+{' ih.Input '}'
; }
; RAlt::Send '{' A_priorkey '}' ; Repeat Key, bind to Thumb


  ; Mask single Alt manually to avoid Menu autohotkey.com/boards/viewtopic.php?t=13587
  ; ~Alt::Send '{Blind}{vkE8}'	;
  ~*Alt::Send '{Blind}{vkE8}' 	; + blocks Shift+AltDown/Up from opening a menu
    ; but no need to mask combos with Ctrl, if Ctrl is down before Alt, the menu underlines will not even appear
    ; Releasing Shift/Win after pressing / before releasing Alt also suppresses the menu
    ;;; BUG autohotkey.com/boards/viewtopic.php?f=82&t=81355
    ;;; bug PSReadLine https://github.com/PowerShell/PSReadLine/issues/2036
  #HotIf WinActive("ahk_exe ConEmu64.exe")
  ~Alt::Send '{Blind}{Ctrl Up}'	; avoid pwsh @ bug
  #HotIf

  ; ————— Make Tab into a custom prefix key
  #include %A_scriptDir%\Tab.ahk	; Tab → prefix key
  ; $`;:: Send('`:')
  ; $+`;::Send('`;')

  ; StrokesPlus via keyboard
  ; VKBF::click "down right"
  ; VKBF up::click "up right"

  ;Global❖WinKeyX → LocalApp❖X (kills default global mappings)
    ; autohotkey.com/boards/viewtopic.php?p=116601
    ; v2 details https://www.autohotkey.com/boards/viewtopic.php?f=82&t=96593
  ; ~LWin::SendInput '{Blind}{vkE8}'
  ; Avoid GlobalWinKey by sending Self directly to window control (SubStr filter out $#)
  ; ... except for ❖x and ❖;/., for which there are not alternatives
  ; $#f::ControlSend('{Blind}#{f}')
  ; $#o::SendInput('{LCtrl Down}{o}{LCtrl Up}')
  ; $#o::SendInput('!f')
  add_WinKeyPassthru() {
    static K  := keyConstant , vk := K._map, sc := K._mapsc  ; various key name constants, gets vk code to avoid issues with another layout
     , s      := helperString ; K.▼ = vk['▼']
     , hkf    := keyFunc.customHotkeyFull
     , hkSend := keyFunc.hkSend, hkSendI := keyFunc.hkSendI, hkSendC := keyFunc.hkSendC

    blind := '{Blind}#' ; with modifiers, exclude self from Blind commands
    loop parse "1234567890wcrst;" { ; '1cdefghiklmpx0-=,.' ❖2​  vk32 ⟶ #2
      hkSendC('$#' vk[A_LoopField], blind '{' vk[A_LoopField] '}')
    }

    ; Disable Office Shortcut (Ctrl+Alt+Shift+Win)
    ; Method1 Map2Self (allow mapping to arbitrary command in other Apps)
    ; d(OneDrive) l(LinkedIn) n(OneNote) o(Outlook) p(PowerPoint) t(Teams) x(Excel) y(Yammer) ✗w(Word)
    loop parse "dlnoptxy" { ; ⇧^❖⌥d​ vk44 ⟶ ⇧^❖⌥d (OneDrive)
      hkSendC('$+^#!' vk[A_LoopField], blind '{' vk[A_LoopField] '}')
    }

  }
  add_WinKeyPassthru()
  $#1::	aTabSameApp("+","", "LWin","vk31")	;❖1​	vk31 ⟶ Switch between windows of the same app (ignore minimized)

  ; #l::	Return	; CAN'T override #L unless disable workstation lockdown HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System DWORD 32-bit 'DisableLockWorkstation' and set to '1' disable superuser.com/questions/960905/how-to-disable-new-to-windows-10-winkey-hotkeys

  ; $#x::	ControlSend('{Blind}#{' . SubStr(A_ThisHotkey,3) . '}',,"A")	;❖x	vk58 ⟶ #x

  ; #k::	;❖k​	vk4B ⟶ ^⇧p Command Palette in Sublime (disable ❖K)
    ; SendInput '{WIN up}'
    ; SendInput '{k up}'
    ; SendInput '^+p'
  ; return

  ; ^escape::return
  ^escape::	SendInput '{Blind}{Ctrl up}{Escape}'	;⌃⎋​	vk1B ⟶ ⎋ (instead of Win menu)

  ; Navigate
  ^!PgUp::	SendInput '{Up 15}'  	;^⌥⇞​	vk9F ⟶ ↑×15 (half PgUp)
  ^!PgDn::	SendInput '{Down 15}'	;^⌥⇟​	vk9E ⟶ ↓×15 (half PgDn)

  ; !WheelUp::  	SendInput '{Up 15}'  	;^⌥⇞​	vk9F ⟶ ↑×15 (half PgUp)
  ; !WheelDown::	SendInput '{Down 15}'	;^⌥⇞​	vk9F ⟶ ↑×15 (half PgUp)


  ;Substitute '\' with 'Enter'
  ;Return
  ;$\::     	Enter
  ;$+\::    	SendInput "+\"
  ;$^\::    	SendInput "\"
  ;$+\::    	SendInput "+\"
  ; $<!/::  	SendInput "/"
  $!\::     	SendInput "/"
  ; !+vkBF::	;⌥/​	vkBF ⟶ ´ acute	?(using VK + scancode)
  $!+\::    	SendInput('¦') ; "÷"
  ;^!+vk20::	SendInput '{U+2007}'	;^⌥⇧␣​	vk20 ⟶   Figure Space            	2007
  ^Esc::    	SendInput '{Esc}'   	;^⎋​  	 ⟶ ⎋ (disable Start Menu)        	  1B
  $!+vkDB:: 	SendInput '{U+007B}'	;⌥⇧[​ 	vkDB ⟶ { Left  Curly  Bracket    	  7B
  $!+vkDD:: 	SendInput '{U+007D}'	;⌥⇧]​ 	vkDD ⟶ } Right Curly  Bracket    	  7D
  ;$!vkDB:: 	SendInput '{U+005B}'	;⌥[​  	vkDB ⟶ [ Left  Square Bracket    	  5B
  ;$!vkDD:: 	SendInput '{U+005D}'	;⌥]​  	vkDD ⟶ ] Right Square Bracket    	  5D
  ; $!vkBC::	SendInput '{U+00AB}'	;⌥,​  	vkBC ⟶ « Left  double angle quote	  AB
  ; $!vkBE::	SendInput '{U+00BB}'	;⌥.​  	vkBE ⟶ » Right double angle quote	  BB
  ; $!vkBC::	SendInput '{U+2039}'	;⌥,​  	vkBC ⟶ ‹ Left  single angle quote	2039
  ; $!vkBE::	SendInput '{U+203A}'	;⌥.​  	vkBE ⟶ › Right single angle quote	203A
  ; $!vkBA::	SendInput '{U+2018}'	;⌥;​  	vkBA ⟶ ‘ Left  single       quote	2018
  ; $!vkDE::	SendInput '{U+2019}'	;⌥'​  	vkDE ⟶ ’ Right single       quote	2019
  $!+vkBA:: 	SendInput '{U+201C}'	;⌥⇧;​ 	vkBA ⟶ “ Left  double       quote	201C
  $!+vkDE:: 	SendInput '{U+201D}'	;⌥⇧'​ 	vkDE ⟶ ” Right double       quote	201D
  #!-::     	SendInput '{U+2012}'	;◆⎇-​ 	vkBD ⟶ ‒ figure-dash             	2012
  ^!-::     	SendInput '{U+2212}'	;^⌥-​ 	vkBD ⟶ − minus                   	2212
  !-::      	SendInput '{U+2014}'	;⌥⇧-​ 	vkBD ⟶ — em-dash                 	2014
  !+-::     	SendInput '{U+2013}'	;⌥-​  	vkBD ⟶ – en-dash                 	2013
  !vkBB::   	SendInput '{U+2260}'	;⌥=​  	vkBB ⟶ ≠ not=                    	2260
  ; !+vkBB::	SendInput '{U+2248}'	;⌥⇧=​ 	vkBB ⟶ ≈ approx                  	2248
  !+vkBB::  	SendInput '{U+00B1}'	;⌥⇧=​ 	vkBB ⟶ ± plus-minus              	  B1
  <+3::     	SendInput '{Raw}#'  	;⇧3​  	vk33 ⟶ # US number-sign          	  23
  <!+3::    	SendInput '№'       	;⌥⇧3​ 	vk33 ⟶ № RU Numero Sign          	2116

  ;;; currently there is no universal way to get TextEdit property, need to test with UIautomation how to limit
  ; HWND := ControlGetFocus("A")
  ; HWND := ControlGetClassNN(ControlGetFocus("A"))
  ; TT(HWND,2)

  ; #c::
  ;   KeyWinC(ThisHotkey){  ; This is a named function hotkey.
  ;   static winc_presses := 0
  ;   if winc_presses > 0 { ; SetTimer already started, so we log the keypress instead.
  ;     winc_presses += 1
  ;     return
  ;   }
  ;   ; Otherwise, this is the first press of a new series. Set count to 1 and start
  ;   winc_presses := 1 ; the timer
  ;   SetTimer "AfterT", -400 ; Wait for more presses within a 400 millisecond window.

  ;   AfterT() { ; This is a nested function.
  ;     if winc_presses = 1 { ; The key was pressed once
  ;       TT("One click detected",1) ; Run "C:\"  ; Open a folder
  ;     } else if winc_presses = 2 { ; The key was pressed twice
  ;       TT("Two clicks detected",1) ; Run "C:\Dev"  ; Open a different folder
  ;     } else if winc_presses > 2 {
  ;       TT("Three or more clicks detected",1)
  ;     }
  ;     ; Regardless of which action above was triggered, reset the count to
  ;     winc_presses := 0 ; prepare for the next series of presses:
  ;   }
  ;   return
  ;   }

  ; Example #4: Detects when a key has been double-pressed (similar to double-click).
  ; KeyWait is used to stop the keyboard's auto-repeat feature from creating an unwanted
  ; double-press when you hold down the RControl key to modify another key.  It does this by
  ; keeping the hotkey's thread running, which blocks the auto-repeats by relying upon
  ; #MaxThreadsPerHotkey being at its default setting of 1.
  ; Note: There is a more elaborate script to distinguish between single, double, and
  ; triple-presses at the bottom of the SetTimer page.
  ; ~RControl::{
  ;   if (A_PriorHotkey != "~RControl" or A_TimeSincePriorHotkey > tDTap) {
  ;     KeyWait "RControl" ; Too much time between presses, so this isn't a double-press
  ;     return
  ;   }
  ;   ; SendInput '^+c'
  ;   TT("You double-pressed the right control key",1)
  ;   }
  ; ~LShift::{	;l⇧²​	vkA0 ⟶ ()
  ;   if (A_PriorHotkey != "~LShift" or A_TimeSincePriorHotkey > tDTap) {
  ;     KeyWait "LShift" ; Too much time between presses, so this isn't a double-press
  ;     return
  ;   }
  ;   Send '('	; add (opening parenthesis
  ;   if not WinActive("ahk_group BracketDouble") {
  ;     Send '){Left}'	; add closing parenthesis)
  ;   }
  ;   }
  ; ~RShift::{	;r⇧²​	vkA1 ⟶ {}
  ;   if (A_PriorHotkey != "~RShift" or A_TimeSincePriorHotkey > tDTap) {
  ;     KeyWait "RShift" ; Too much time between presses, so this isn't a double-press
  ;     return
  ;   }
  ;   Send '{{}'	; add {opening brace
  ;   if not WinActive("ahk_group BracketDouble") {
  ;     Send '{}}{Left}'	; add closing brace}()
  ;   }
  ;   }
  ; ~LWin::{	;l❖²​	vk5B ⟶ ()
  ;   if (A_PriorHotkey != "~LWin" or A_TimeSincePriorHotkey > tDTap) {
  ;     KeyWait "LWin" ; Too much time between presses, so this isn't a double-press
  ;     return
  ;   }
  ;   TT("You double-pressed left ❖",1)
  ;   }

  ~vkBC::{ ;, vkBC ⟶ , (double tap) in Russian layout
    ; if (GetCurLayout() = ruU) {
    ;   c1 := ListenChar(.5)
    ;   if (c1) {
    ;     SendInput '{BackSpace}'
    ;     SendInput ','
    ;   }
      ;if (A_PriorHotKey = A_ThisHotKey and A_TimeSincePriorHotkey < 200) {
      ;  SendInput '{BackSpace}'
      ;  SendInput ','
      ;} else {
      ;  SendInput '{vkBC}'
      ;}
    ; }
    ; else { ;
    ;   SendInput '{vkBC}'
    ; }
    }

  #HotIf !WinActive("ahk_group WinTerm") ; Windows Terminal
  +BackSpace::	SendInput '{Delete}'	;⇧⌫​	vk08 ⟶ ⌦ Delete	(U+00 vk2E)
  #HotIf


  ;#Left::	SendInput '{LCtrl down}{LShift down}{Tab}{LShift up}{LCtrl up}'	;❖←​		⟶ Tab Left

  ;#Right:: 	SendInput '{LCtrl down}{Tab}{LCtrl up}' 	;❖→​ 		⟶ Tab Right
  ;#+Left:: 	Send '{Blind}{LWin down}{Left}{LWin up}'	;❖⇧←​		⟶ Winkey Left (resize)
  ;#+a::    	SendInput '{LWin down}{Left}{LWin up}'  	;❖⇧←​		⟶ Winkey Left (resize)
  ;#+Left:: 	SendInput '{LWin down}{Left}{LWin up}'  	;❖⇧←​		⟶ Winkey Left (resize)
  ;#+Right::	SendInput '{LWin down}{Right}{LWin up}' 	;❖⇧←​		⟶ Winkey Left (resize)
  ;#+Right::	SendInput '{LCtrl down}{Tab}{LCtrl up}' 	;❖⇧→​		⟶ Winkey Right (resize)

  ;Capslock&Left:: 	SendInput '{LCtrl down}{LShift down}{Tab}{LShift up}{LCtrl up}'	;⇪←​	    	⟶ Tab Left
  ;Capslock&Right::	SendInput '{LCtrl down}{Tab}{LCtrl up}'                        	;⇪→​	    	⟶ Tab Right
  ;^q::            	SendInput '{LAlt}{F4}'                                         	;^q​	vk51	⟶ ⌥F4	 vk73 03E
  ;^w::            	^F4                                                            	;w​ 	vk57	⟶ ^F4	 vk73 03E
  ;^q::            	!F4                                                            	;^q​	vk51	⟶ ⌥F4	 vk73 03E

  ; ^q::SendInput '{Alt Down}{F4}{Alt Up}' ;^q​	vk51	⟶ ⌥F4 vk73 03E

  ; disable as it's now useful to switch windows
  ; $F1::{                                 ;F1 activates F1 only if held > 1sec
  ;   F1Time := KeyWait("F1", "T1")       ;Wait for the user to release
  ;   if F1Time=0 {
  ;     SendInput '{F1}'
  ;   }
  ;   }
  ; $F9::F20
  ; F20 & 1:: TT("F20 & 1", 3)

; ————————————————————————— Cursor changes ———————————————————————————
  #include %A_scriptDir%\4 Cursor.ahk
  #include %A_scriptDir%\6 NumPad.ahk

; ————————————————————————— Mouse changes ———————————————————————————
  #include %A_scriptDir%\5 Mouse.ahk

;—————————————————————————— Quick Launch ————————————————————————————
  ; #s::RunActivMin(App.ST*)            	;s​ vk53 ⟶ ?	(U+?)
  ; #c::Run('"' AppConEmu '"', "C:\Dev")	;c​ vk43 ⟶ ?	(U+?)
  ^vkC0::RunActivMin(AppWezTerm)        	;^`​        		vkC0 ⟶ Launch App
  ; #r::shell.FileRun()                 	;❖r​        		vk52 ⟶ ...
  ; #d::RunActivMin(App.DOpus*)         	;❖d​        		vk44 ⟶ ...
  ; #e::RunActivMin(App.DOpus*)         	;❖e​        		vk45 ⟶ ...
  #+e::Run('"' AppTotalCMD '"')         	;❖⇧e​       		vk45 ⟶ ...
  ;#+f::RunActivMin(Apps.Everything*)   	;❖⇧f​       		vk46 ⟶ ...
  ;#f::RunActivMin(Apps.Everything*)    	;❖f​        		vk46 ⟶ ...
  ;;; #f::RunActivMin(App.Everything*)  	;❖f​        		vk46 ⟶ ...
  #p::RunActivMin(AppPowerPoint)        	;❖p​        		vk50 ⟶ ...
  ; #t::Run('"' AppTotalCMD '"')        	;❖t​        		vk54 ⟶ ...
  ; #x::RunActivMin(AppExcel)           	;❖x​        		vk58 ⟶ ...
  ; #w::RunActivMin(AppWord)            	;❖w​        		vk57 ⟶ ...
  ;#o::RunActivMin(AppOutlook)          	;❖o​        		vk4F ⟶ ...
  ; HyperKeys bindings
  #include %A_scriptDir%\0 Hyper.ahk

  ; vk2C::  ;PrntScr​	vk2C ⟶ Launch SnagIt or pass PrintScreen if it's launched
  ;   SplitPath(AppSnagit, &ExeFileName)
  ;   PID := ProcessExist(ExeFileName)
  ;   if (PID = 0) {
  ;     Run('"' AppSnagit '"')
  ;     if WinWaitActive("ahk_exe " ExeFileName, , "5") {
  ;       SendInput '{PrintScreen}'
  ;     } else {
  ;       SendInput '{PrintScreen}'
  ;     }
  ;   } else {
  ;     SendInput '{PrintScreen}'
  ;   }
  ; Return


  ; Paste as pure text (autohotkey.com/community/viewtopic.php?t=11427)
  $^#vk56::{                                                 ;^❖v vk56
    ClipSaved	:= ClipboardAll() ; Save the entire clipboard
    SendInput '^v'
    Sleep 100
    A_Clipboard := ClipSaved   ; Restore the original clipboard
    VarSetStrCapacity(&ClipSaved, 0)
    }
  $!#vk56::{                                                 ;⌥❖v vk56
    Send "{Raw}" A_Clipboard ; "type" instead of pasting to circumvent pasting restrictions
    }
 ;Internet
  ; #i::RunActivMin("C:\Windows\explorer.exe shell:Appsfolder\Microsoft.MicrosoftEdge_8wekyb3d8bbwe!MicrosoftEdge")            ;❖i vk49 e vk45
  ; #q::RunActivMin(AppVivaldi)	;❖q vk51
  ; #v::RunActivMin(AppChrome) 	;[❖v] vk56
  ;#g:: Run http://www.google.com/search?q=%clipboard%
  ;#z::RunActivMin(AppFirefox)
 ;Multimedia
  ; #+v:: Run(winamp.exe) ;[❖⇧v] vk56
  ; $Media_Play_Pause::
  ; pid := ProcessExist("MusicBee.exe")
  ;	if pid {
  ;		SendInput '{Media_Play_Pause}'
  ;		} Else {
  ;			pid := ProcessExist("itunes.exe")
  ;			if pid {
  ;				SendInput '{Media_Play_Pause}'
  ;				} Else {
  ;					if ProcessExist("winamp.exe")
  ;					Sleep 1000
  ;					SendInput '{Media_Play_Pause}'
  ;					}
  ;			}
  ;	Return
  ; #v::RunActivMin(Utils . "VMware Workstation\vmware.exe") ;[❖v] vk56
  ; MultiMedia. $ forces a keyboard hook, needed to avoid multiple triggers
  #F1::    	SendInput '{Media_Play_Pause}'	;❖F1    	vk?? ⟶ Media Play/Pause
  #F2::    	SendInput '{Media_Stop}'      	;❖F2    	vk?? ⟶ Media Stop
  #F3::    	SendInput '{Media_Prev}'      	;❖F3    	vk?? ⟶ Media Prev
  #F4::    	SendInput '{Media_Next}'      	;❖F4    	vk?? ⟶ Media Next
  #F7::    	SendInput '{Media_Prev}'      	;❖F7    	vk?? ⟶ Media Prev
  #F8::    	SendInput '{Media_Play_Pause}'	;❖F8    	vk?? ⟶ Media Play/Pause
  #F9::    	SendInput '{Media_Next}'      	;❖F9    	vk?? ⟶ Media Next
  <^>!F7:: 	SendInput '{Media_Prev}'      	;r⌥GrF7 	vk?? ⟶ Media Prev
  <^>!F8:: 	SendInput '{Media_Play_Pause}'	;r⌥GrF8 	vk?? ⟶ Media Play/Pause
  <^>!F9:: 	SendInput '{Media_Next}'      	;r⌥GrF9 	vk?? ⟶ Media Next
  >!F7::   	SendInput '{Media_Prev}'      	;r⌥F7   	vk?? ⟶ Media Prev
  >!F8::   	SendInput '{Media_Play_Pause}'	;r⌥F8   	vk?? ⟶ Media Play/Pause
  >!F9::   	SendInput '{Media_Next}'      	;r⌥F9   	vk?? ⟶ Media Next
  #F10::   	SendInput '{Volume_Mute}'     	;❖F10   	vk?? ⟶ Volume Mute
  #F11::   	SendInput '{Volume_Down}'     	;❖F11   	vk?? ⟶ Volume Down
  #F12::   	SendInput '{Volume_Up}'       	;❖F12   	vk?? ⟶ Volume Up
  <^>!F10::	SendInput '{Volume_Mute}'     	;r⌥GrF10	vk?? ⟶ Volume Mute
  <^>!F11::	SendInput '{Volume_Down}'     	;r⌥GrF11	vk?? ⟶ Volume Down
  <^>!F12::	SendInput '{Volume_Up}'       	;r⌥GrF12	vk?? ⟶ Volume Up
  >!F10::  	SendInput '{Volume_Mute}'     	;r⌥F10  	vk?? ⟶ Volume Mute
  >!F11::  	SendInput '{Volume_Down}'     	;r⌥F11  	vk?? ⟶ Volume Down
  >!F12::  	SendInput '{Volume_Up}'       	;r⌥F12  	vk?? ⟶ Volume Up

  ; <^>!>+VKBF::	SendInput '{Media_Play_Pause}'	;[r⇧r⌥Gr/] VKBF ⟶ Media Play/Pause ;DeadKey in TypES Layout


  <^>!+F9::{ ; [r⌥Gr⇧F9]
    MsgBox("Media Next every 3 seconds; Esc to exit", "Media", "T0.5")
    While (GetKeyState('Esc') = 0) {
      Sleep 3000
      SendInput '{Media_Next}'
    }
    ; escState := ""
    ; Loop {
      ; escState := GetKeyState('Esc')
      ; escState := GetKeyState('Right')
      ; SendInput '{Media_Next}'
      ; Sleep 1000
    ; } Until (escState = 1)
    MsgBox("Loop Finished", "Media", "T0.5")
    }

  ; Press&Hold shortcuts might be blocking this
  ; ~vk56 & 0:: SendInput '{Volume_Mute}' ; [v0] vk56+vk30
  ; ~vk56 & vkBD:: SendInput '{Volume_Down}' ; [v-] vk56+vkBD
  ; ~vk56 & vkBB:: SendInput '{Volume_Up}' ; [v=] vk56+vkBB

; ————————————————————————— Folders —————————————————————————————————
  ;#`::Run(Utils . "Directory Opus\DOpusrt.exe /acmd Go LASTACTIVELISTER NEW") ;❖`​ vk? ⟶ ?
  ; Tab & X::     	OpusDir_CD(Path1)    	;@Tab.ahk
  ; #0::          	RunActivMin(AppDOpus)	;❖0​ 	vk30 ⟶ ?
  ; #1::          	OpusDir_CD(Path1)    	;❖1​ 	vk31 ⟶ ?
  ; #2::          	OpusDir_CD(Path2)    	;❖2​ 	vk32 ⟶ ?
  ; #3::          	OpusDir_CD(Path3)    	;❖3​ 	vk33 ⟶ ?
  ; #4::          	OpusDir_CD(Path4)    	;❖4​ 	vk34 ⟶ ?
  ; #5::          	OpusDir_CD(Path5)    	;❖5​ 	vk35 ⟶ ?
  ; #6::          	OpusDir_CD(Path6)    	;❖6​ 	vk36 ⟶ ?
  ; #7::          	OpusDir_CD(Path7)    	;❖7​ 	vk37 ⟶ ?
  ; #8::          	OpusDir_CD(Path8)    	;❖8​ 	vk38 ⟶ ?
  ; CapsLock & 1::	OpusDir_CD(Path1)    	;⇪1​ 	vk31 ⟶ ?
  ; CapsLock & 2::	OpusDir_CD(Path2)    	;⇪2​ 	vk32 ⟶ ?
  ; CapsLock & 3::	OpusDir_CD(Path3)    	;⇪3​ 	vk33 ⟶ ?
  ; CapsLock & 4::	OpusDir_CD(Path4)    	;⇪4​ 	vk34 ⟶ ?
  ; CapsLock & 5::	OpusDir_CD(Path5)    	;⇪5​ 	vk35 ⟶ ?
  ; CapsLock & 6::	OpusDir_CD(Path6)    	;⇪6​ 	vk36 ⟶ ?
  ; CapsLock & 7::	OpusDir_CD(Path7)    	;⇪7​ 	vk37 ⟶ ?
  ; CapsLock & 8::	OpusDir_CD(Path8)    	;⇪8​ 	vk38 ⟶ ?
  ; #+1::         	TotalCMD_CD(Path1)   	;❖⇧1​	vk31 ⟶ ?
  ; #+2::         	TotalCMD_CD(Path2)   	;❖⇧2​	vk32 ⟶ ?
  ; #+3::         	TotalCMD_CD(Path3)   	;❖⇧3​	vk33 ⟶ ?
  ; #+4::         	TotalCMD_CD(Path4)   	;❖⇧4​	vk34 ⟶ ?
  ; #+5::         	TotalCMD_CD(Path5)   	;❖⇧5​	vk35 ⟶ ?
  ; #+6::         	TotalCMD_CD(Path6)   	;❖⇧6​	vk36 ⟶ ?
  ; #+7::         	TotalCMD_CD(Path7)   	;❖⇧7​	vk37 ⟶ ?
  ; #+8::         	TotalCMD_CD(Path8)   	;❖⇧8​	vk38 ⟶ ?

; ————————————————————————— Windows —————————————————————————————————
  WinEvent.Create(cbCreate_Borderless, App.ST.match) ; watch Sublime Text windows and apply borderless style
  WinEvent.Create(cbCreate_Borderless, App.DOpus.match) ;
  WinEvent.Create(cbCreate_Borderless, App.Everything.match) ;
  WinEvent.Create(cbCreate_Borderless, App.MSHelp.match) ;
  #h::      	WinMinimize "A"                  	;❖h​ 	vk48	⟶ hide active window
  #+h::     	Win_HideOthers()                 	;❖⇧h​	vk48	⟶ /lib Hides all windows but the focused one
  ;^!w::    	Win_FWT()                        	;^⌥w​	vk57	⟶ Borderless the window under the mouse
  ;#w::     	Win_FWT(WinExist("A"))           	;❖w​ 	vk57	⟶ Borderless the active window
  #+0::     	Win_FWT(WinExist("A"))           	;❖⇧0​	vk30	⟶ Borderless the active window
  #0::      	Win_MenuToggle(WinExist("A"))    	;❖0​ 	vk30 ⟶ Toggle active window's menu
  ; #+0::   	Win_MenuToggle(WinExist("A"))    	;❖⇧0​	vk30 ⟶ Toggle active window's menu
  ; #m::    	Win_MenuToggle(WinExist("A"))    	;❖m​ 	vk4D ⟶ Toggle active window's menu
  #+m::     	Win_RestoreLastMinWin()          	;❖⇧m​	vk4D ⟶ Restore last minimized window
  #vkBD::   	Win_TitleToggle("noPosFix")      	;❖-​ 	vkBD	⟶ Toggle Window Borders On/Off
  #vkBB::   	Win_TitleToggle("PosFix")        	;❖=​ 	vkBB	⟶ Toggle Window Borders On/Off and adjust size/position
  #+vkBD::  	WinSetStyle("^" WS_Caption, "A") 	;❖⇧-​	vkBD	⟶ Toggle Window Title Bar On/Off
  #+vkBB::  	WinSetStyle("^" WS_SizeBox, "A") 	;❖⇧=​	vkBB	⟶ Toggle Window Resize Margins On/Off
  !Esc::    	SwapTwoWindows()                 	;⌥⎋  	Esc 	⟶ Fast-swap between two last windows only; requires change in function when hotkey changes ;;;ToDO: get hotkey and adjust the function automatically
  ; !vkC0:: 	aTabSameApp("+","", "Alt","vkC0")	;⌥`  	vkC0 ⟶ Switch between windows of the same app (ignore minimized)
  ; !vkC0:: 	aTabSameApp("+","ShowMin")       	;⌥`  	vkC0 ⟶ Switch between windows of the same app (include minimized)
  ; #vk31:: 	aTabSameApp("+")                 	;⌥1  	vk31 ⟶ Switch between windows of the same app (ignore minimized), mapped in WinKey remappings
  ; !+vkC0::	aTabSameApp("-")                 	;⌥⇧` 	vkC0 ⟶ Switch between windows of the same app (reverse order)

  ; old alternative to SwapTwoWindows(), messes with AltUp which is needed for another macro switches between two apps: current and most recent (and vice versa) (edited version of superuser.com/questions/1261225/prevent-alttab-from-switching-to-minimized-windows)
  ; ~Alt Up:: ;Reset on Alt up
  ; ~*vk57 Up::{ ;Reset on W up (allows repetition while Alt is pressed)
  ;   global wCycling, wForward
  ;   if wCycling {
  ;     wForward	:= !wForward
  ;   }
  ;   wCycling	:= false
  ;   }
  ; #!w::{               		;^⌥w​	vk57 ⟶ Instantly switch to next non-minimized window
  ;   global wForward    		;
  ;   WinCycle(wForward) 		;
  ;   }                  		;
  ; ^!+w::{              		;^⌥⇧w​	vk57 ⟶ Instantly switch to previous non-minimized window
  ;   global wForward    		;
  ;   WinCycle(!wForward)		;
  ;   }                  		;

; ————————————————————————— Autohotkey self-management —————————————————————————
  <^<!<+e:: Edit                   	;Left^⌥⇧e​	vk45 ⟶ Edit the master AutoHotKey file
  <^<!<+t:: Run('"' AppAHKHelp '"')	;Left^⌥⇧t​	vk54 ⟶ Help file
  <^<!<+y:: Run('"' AppAHKSpy '"') 	;Left^⌥⇧y​	vk59 ⟶ Spy utility

  #SuspendExempt  ; Exempt the following hotkey from Suspend.
  ; Tab & vkDE::	Suspend -1	;^⌥⇧'​	vkDE ⟶ Suspend other ListHotkeys'
  ; Tab & Esc:: 	Suspend -1	;^⌥⇧⎋​	vkDE ⟶ Suspend other ListHotkeys'
  #Esc::{ ;#⎋
    Suspend(-1), WinEvent.Pause(-1)
  }

  ; !z:: ;;; temporary fast reloads
  !F1::     	;‹⎇F1​   	vk70
  <^<!<+r::{	;‹⎈‹⎇‹⇧r​	vk52 ⟶ Reload this AutoHotKey script
    Tooltip "AutoHotKey Reloading!"
    sleep(500)
    SetTimer () => ToolTip(), -500 ; killed on Reload, but helpful if reload fails
    Reload
    }
  #SuspendExempt False  ; Disable exemption for any hotkeys/hotstrings below this.
  ; ^!+vk41::Run(A_AhkPath " " A_scriptDir "\Sys-EnableUIAccess.ahk")	;^⌥⇧a​	vk41 ⟶ Enable UI access for EXE file

  ; Sleep 1000
  ;SoundPlay *48
  ; MsgBox  4,, Script could NOT be reloaded`, open it for editing?, 1 ;0
  ; IfMsgBox Yes, Edit
  ; Return

; ————————————————————————— App-specific hotkeys —————————————————————————
#HotIf WinActive("ahk_class CabinetWClass")	;[App] only in Explorer Windows
  ^n::NewTextFile()                        	;[^n]      	vk4E /lib Create a new file (*.md by default) and open it in ST
  ;$^n::^+vk4E                             	;[^n]→[^⇧n]	vk4E Creates a new folder via default Ctrl+Shift+N shortcut
  ; #+h::ToggleHidden()                    	;[❖⇧h]     	vk48
  #+i::ToggleHidden()                      	;[❖⇧i]     	vk49 /lib Toggles hidden files
  #+x::ToggleExtension()                   	;[❖⇧x]     	vk58 /lib Toggle file extensions in Explorer
  BackSpace::{                             	;[⌫]       	vk08 Go up, not back
    try (renamestatus:=ControlGetVisible("Edit1","A")) ; make sure no renaming is in process and we are actually in list or in tree
    catch as e { ; set blank when no control exists
      renamestatus := ""
    }
    focussed	 := ControlGetFocus("A")
    if (renamestatus!=1 and (focussed="DirectUIHWND3" or focussed="SysTreeView321")) {
      SendInput '{Alt Down}{Up}{Alt Up}'
      Return
    } else {
      SendInput '{Backspace}'
      return
    } ;autohotkey.com/board/topic/22194-vista-explorer-backspace-for-parent-folder-as-in-xp/
  }
#HotIf

#HotIf WinActive("ahk_exe sublime_text.exe") ;[App] ⇧+⇪ opens Command Palette
  ;#HotIfWinActive, ahk_class PX_WINDOW_CLASS
  ;# WinKey, ^ Control, ! Alt, + Shift, <> left/right key of a pair
  ;+Capslock::   	SendInput '^+{vk50}'	;⇧⇪​	vk50 ⟶ ^⇧p Command Palette	()
  ;Capslock & p::	SendInput '^+{vk50}'	;⇪p​	vk50 ⟶^⇧p Command Palette 	()
  ; #Right::     	SendInput '^{Tab}'  	;⇧[​	vkDB ⟶ { Left Bracket     	(U+007B)

  ; ; Avoid GlobalWinKey by sending Self directly to window control (SubStr filter out $#)
  ; $#2::	ControlSend('{Blind}#{' . SubStr(A_ThisHotkey,3) . '}',,"A")	;❖2​	vk32 ⟶ #2
#HotIf
#HotIf WinActive("ahk_class Photoshop") ;[App Photoshop]
  <^1::	SendInput '^+{Tab}'	;​‹⎈1​	vk31 ⟶ prev document
  <^2::	SendInput '^{Tab}' 	;​‹⎈2​	vk32 ⟶ next document
#HotIf
#HotIf WinActive("ahk_exe EXCEL.EXE") ;[App Excel] Reset some of the shortcuts to originals
  ;#HotIfWinActive, ahk_class HwndWrapper[DefaultDomain;;2d58ffd7-2857-405f-9298-df01cb46d314]
  ; !=::    	SendInput '{LAlt down}{=}{LAlt up}'
  ^vkC0::   	SendInput '^{vkC0}'              	;^`​   	vkC0 ⟶ Restore
  !vkBB::   	SendInput '{Blind}='             	;⌥=​   	vkBB ⟶ Restore
  <^>!vkBB::	SendInput '{Blind}{LControl up}='	;rGr⌥=​	vkBB ⟶ Restore
  >!vkBB::  	SendInput '{Blind}{LControl up}='	;r⌥=​  	vkBB ⟶ Restore
  ; <^>!=:: 	SendInput '{LAlt down}{=}{LAlt up}'
  ; !+=::   	SendInput '{LAlt down}{LShift down}{=}{LAlt up}{LShift up}'
  ^F2::     	return             	;^F​2	vk71 ⟶ Disable Printing Menu
  <^1::     	SendInput '^{PgUp}'	;​
  <^2::     	SendInput '^{PgDn}'	;​
  <#1::     	SendInput '^1'     	;​
  <#2::     	SendInput '^2'     	;​
#HotIf

#HotIf WinActive("ahk_exe OneCommanderV2.exe") ;[App] Ctrl←→/⌘←→ navigate to the left/right tab
  ;#HotIfWinActive, ahk_class HwndWrapper[DefaultDomain;;2d58ffd7-2857-405f-9298-df01cb46d314]
  ^Left::  SendInput '{LCtrl down}{LShift down}{Tab}{LShift up}{LCtrl up}'
  ^Right:: SendInput '{LCtrl down}{Tab}{LCtrl up}'
  #Left::  SendInput '{LCtrl down}{LShift down}{Tab}{LShift up}{LCtrl up}'
  #Right:: SendInput '{LCtrl down}{Tab}{LCtrl up}'
#HotIf

#HotIf WinActive("ahk_exe dopus.exe") ;[App Directory Opus] Ctrl←→/⌘←→ navigate to the left/right tab
  ;#HotIfWinActive, ahk_class HwndWrapper[DefaultDomain;;2d58ffd7-2857-405f-9298-df01cb46d314]
  ;^Left::  SendInput '{LCtrl down}{LShift down}{Tab}{LShift up}{LCtrl up}'
  ;^Right:: SendInput '{LCtrl down}{Tab}{LCtrl up}'
  ;#Left::  SendInput '{LCtrl down}{LShift down}{Tab}{LShift up}{LCtrl up}'
  ; F1::AppWindowSwitcher(←)	;   ...    to Previous App's Window (↓ Z-order) ; bug in opus, can't rebind f2 inline rename
  ; F2::AppWindowSwitcher(→)	; Switch to Next     App's Window (↑ Z-order)
#HotIf
#HotIf WinActive("ahk_class dopus.lister")	; only in Opus Directory
  ;;;;;^n::NewTextFile()                  	;[^n]	vk4E /lib Create a new file (*.md by default) and open it in ST
  ;WinGetText function gives out a different format of text vs Explorer, so active tab is harder to get
  #Left:: SendInput '^+{Tab}'
  #Right::SendInput '^{Tab}'
#HotIf

#HotIf WinActive("ahk_exe chrome.exe") ;[App Chrome] Ctrl←→/⌘←→ navigate to the left/right tab
  ;#HotIfWinActive, ahk_class HwndWrapper[DefaultDomain;;2d58ffd7-2857-405f-9298-df01cb46d314]
  ;^Left::  SendInput '{LCtrl down}{LShift down}{Tab}{LShift up}{LCtrl up}'
  ;^Right:: SendInput '{LCtrl down}{Tab}{LCtrl up}'
  #Left:: 	SendInput '{LCtrl down}{LShift down}{Tab}{LShift up}{LCtrl up}'
  #Right::	SendInput '{LCtrl down}{Tab}{LCtrl up}'
#HotIf

#HotIf WinActive("ahk_exe vivaldi.exe") ;[App Vivaldi] Ctrl←→/⌘←→ navigate to the left/right tab
  ; ^q:: ;^q​ vk51 ⟶ Ask for quit confirmation
  ;	MsgBox:=MsgBox("Exit Vivaldi?", "Confirm", "OKCancel T2 32")
  ;	if MsgBox = "OK"
  ;		SendInput '{Alt Down}{F4}{Alt Up}' ;^q​	vk51	⟶ [⌥F4] vk73 03E
  ;	else
  ; Return
  ; ^q::   	SendInput '{Alt Down}{F4}{Alt Up}' ;^q​	vk51	⟶ [⌥F4] vk73 03E
  ^!Left:: 	SendInput '{LCtrl down}{LShift down}{Tab}{LShift up}{LCtrl up}'
  ^!Right::	SendInput '{LCtrl down}{Tab}{LCtrl up}'
  !1::     	SendInput '^{vk21}' ;Page Up to override Facebook Alt+# shortcuts
  !2::     	SendInput '^{vk22}' ;Page Down to override Facebook Alt+# shortcuts
  ; Extensions (set global rare keybinds in Vivaldi, map convenient to rare here)
  ; !vk41::	SendInput '^+{vk30}' ;⌥a​	vk41 ⟶ [⇧^0] Bitwarden: auto-fill
#HotIf

#HotIf WinActive("ahk_exe SumatraPDF.exe") ;[App SumatraPDF] Alt1/2 move to the left/right tab
  ; ^q::   	SendInput '{Alt Down}{F4}{Alt Up}' ;^q​	vk51	⟶ ⌥F4 vk73 03E
  ^!Left:: 	SendInput '{LCtrl down}{LShift down}{Tab}{LShift up}{LCtrl up}'
  ^!Right::	SendInput '{LCtrl down}{Tab}{LCtrl up}'
  !1::     	SendInput '^+{vk09}'	;⌥1​	vk31	⟶ ^⇧⭾ vk09 Tab Left to override Alt+# shortcuts
  !2::     	SendInput '^{vk09}' 	;⌥2​	vk32	⟶ ^⭾ vk09  Tab Right to override Alt+# shortcuts
#HotIf

#HotIf WinActive("ahk_exe TOTALCMD64.EXE") ;[App TotalCMD] Ctrl←→/⌘←→ navigate to the left/right tab
  ;#HotIfWinActive, ahk_class HwndWrapper[DefaultDomain;;2d58ffd7-2857-405f-9298-df01cb46d314]
  ;^Left:: SendInput '{LCtrl down}{LShift down}{Tab}{LShift up}{LCtrl up}'
  ;^Right:: SendInput '{LCtrl down}{Tab}{LCtrl up}'
  #Left:: 	SendInput '{LCtrl down}{LShift down}{Tab}{LShift up}{LCtrl up}'
  #Right::	SendInput '{LCtrl down}{Tab}{LCtrl up}'
#HotIf

#HotIf WinActive("ahk_exe FontLab 7.exe") ;[App FontLab] Alt1/2 to Tab Left/Right
  ;#HotIfWinActive, ahk_class Qt5QWindowIcon
  !1::	SendInput '^+{Tab}'
  !2::	SendInput '^{Tab}'
#HotIf

#HotIf WinActive("ahk_class ApplicationFrameWindow") And WinActive("ahk_exe ApplicationFrameHost.exe") And WinActive("Readiy") ;[App Readiy]
  XButton1::	SendInput '{Left}' ;[G6/G7] G700s mouse to ←→ (for switching to previous/next article)
  XButton2::	SendInput '{Right}'
#HotIf

#HotIf WinActive("ahk_group WinTerm") ; Windows Terminal
  XButton1::	SendInput '^+{Tab}'	;🖰G​7​	vk05 ⟶ ^⇧⭾ previous tab
  XButton2::	SendInput '^{Tab}' 	;🖰G​6 	vk06 ⟶ ^⭾ next tab
#HotIf

; #HotIfWinActive ahk_exe EXCEL.EXE ;Ctrl⌥+←/→/↑/↓ Scroll Left/Right/Up/Down
;	^!Left::                              ; Scroll Left
;		SetScrollLockState(1)
;		Send '{Left}'
;		SetScrollLockState(0)
;	Return
;	^!Right::                             ; Scroll Right
;		SetScrollLockState(1)
;		Send '{Right}'
;		SetScrollLockState(0)
;	Return
;	^!Up::                                ; Scroll Up
;		SetScrollLockState(1)
;		Send '{Up}'
;		SetScrollLockState(0)
;	Return
;	^!Down::                              ; Scroll Down
;		SetScrollLockState(1)
;		Send '{Down}'
;		SetScrollLockState(0)
;	Return
; #HotIfWinActive

; check window control focused element's variable (if ∃)
; F2::
;   focusedHwnd     	:= ControlGetFocus("A")
;   ; focusedClassNN	:= ControlGetClassNN(focusedHwnd)
;   if focusedHwnd {
;     MsgBox("The target window doesn't exist or none of its controls has input focus", "Focus", "T.8")
;   } else {
;    MsgBox("AutoHotControl with focus = " . focusedHwnd . "`nClassNN: ", "AutoHotControl")
;    ; MsgBox("AutoHotControl", "AutoHotControl with focus = " . focusedHwnd . "\nClassNN: " . focusedClassNN)
;   }
;   Return

; IfWinActive, ahk_group WinTabSwitch
;	^Left:: SendInput '{LCtrl down}{LShift down}{Tab}{LShift up}{LCtrl up}'
; else
;	MsgBox Suspend, Off
