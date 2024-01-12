; Global Paths for Navigation
;Folders
  global Path1	:= ""
  , Path2     	:= ""
  , Path3     	:= ""
  , Path4     	:= ""
  , Path5     	:= ""
  , Path6     	:= ""
  , Path7     	:= ""
  , Path8     	:= ""

; Global Paths
  global esvHome	:= ""
  , App         	:= ""
  , Progs       	:= "C:\Program Files\"
  , Utilities   	:= ""
  , Utils       	:= ""
  , Inet        	:= ""
  , Play        	:= ""
  , Progs32     	:= "C:\Program Files (x86)\"
  , Inet32      	:= ""
  , Utilities32 	:= ""
  , AppLocal    	:= ""
  , MSO         	:= "C:\Program Files\Microsoft Office\"


; Global Apps
  global AppAHKHelp	:= Utilities . "AutoHotkey\AutoHotkey.chm"
  , AppAHKSpy      	:= Utilities . "AutoHotkey\AU3_Spy.exe"
  , AppST          	:= ""
  , AppNPP         	:= ""
  , AppVivaldi     	:= ""
  , AppVivaldiXtra 	:= "--process-per-site --disable-features=RendererCodeIntegrity"
  , AppVivaldi2    	:= Inet32 . "Vivaldi\Application\vivaldi.exe"
  , AppChrome      	:= Progs32 . "Google\Chrome\Application\chrome.exe"
  , AppFirefox     	:= Progs32 . "Internet\Firefox\firefox.exe"
  , AppDOpus       	:= App "dopus.exe" ; Launch borderless (compiled AHK script)
  , AppDOpus_old   	:= Utilities . "Directory Opus\DOpus.exe"
  , AppDOpusRt     	:= Utilities . "Directory Opus\DOpusrt.exe"
  , AppTotalCMD    	:= ""
  , AppConEmu      	:= ""
  , AppWezTerm     	:= ""
  , AppEverything  	:= Progs . "Everything.exe"
  , AppSnagit      	:= Play . ""
  , AppPowerPoint  	:= MSO . "PowerPnt.exe"
  , AppExcel       	:= MSO . "EXCEL.EXE"
  , AppWord        	:= MSO . "WinWord.exe"
  , AppOutlook     	:= MSO . "Outlook.exe"
  , AppWire        	:= AppLocal . "wire\Wire.exe"

; Store App Launch Name and Settings object for RunActivMin
; App, WorkDir:="", Size:="", Title:=0, PosFix:=0, Menu:=1, Match:="exe", CLIOpts:=""
  global Apps := Map()
  _fillApps()
  _fillApps() {
    global Apps
    t:=[],t.App:=AppST        	, t.Title:=0	             	, t.WorkDir:=esvHome               	           	, Apps["AppST"]:=t
    t:=[],t.App:=AppNPP       	, t.Title:=0	             	, t.WorkDir:=esvHome               	           	, Apps["AppNPP"]:=t
    t:=[],t.App:=AppDOpus     	, t.Title:=0	, t.PosFix:=0	, t.Match:="ahk_class dopus.lister"	           	, Apps["DOpus"]:=t
    t:=[],t.App:=AppEverything	, t.Title:=0	, t.PosFix:=0	, t.Match:="ahk_class EVERYTHING"  	, t.Menu:=0	, Apps["Everything"]:=t
    t:=[],t.App:=AppVivaldi   	            	             	, t.CLIOpts:=AppVivaldiXtra        	           	, Apps["VivaldiX"]:=t
  }

;;;;; Convert to named parameters when they're added
; Alternative way requires adding and __Enum to objects autohotkey.com/boards/viewtopic.php?t=76067
; broken in AutoHotkey_2.0-a128-f63b0eb4_postMethod+Prop
; Object.Prototype.DefineProp("__Enum", { call : (this, NumberOfVars) => this.OwnProps() })
; oST        	:= {App:AppST        	, Title:0	          	, WorkDir:esvHome               	}
; oNPP       	:= {App:AppNPP       	, Title:0	          	, WorkDir:esvHome               	}
; oDOpus     	:= {App:AppDOpus     	, Title:0	, PosFix:0	, Match:"ahk_class dopus.lister"	}
; oEverything	:= {App:AppEverything	, Title:0	, PosFix:0	, Match:"ahk_class EVERYTHING"  	, Menu:0}
; oVivaldiX  	:= {App:AppVivaldi   	         	          	, CLIOpts:AppVivaldiXtra        	}

; RunActivMin(App, WorkDir:="", Size:="", Title:=0, PosFix:=0, Menu:=1, Match:="exe", CLIOpts:="") {
;name      	    App          	, WorkDir	, Size	, Title	, PosFix	,	Menu	, Match                   	, CLIOpts
;defval    	    App          	, ""     	, ""  	, 0    	, 0     	,	1   	, "exe"                   	, ""
oST        	:= [AppST        	, esvHome	,     	,      	,       	,	    	,                         	, ]
oNPP       	:= [AppNPP       	, esvHome	,     	,      	,       	,	    	,                         	, ]
oDOpus     	:= [AppDOpus     	,        	,     	,      	,       	,	    	, "ahk_class dopus.lister"	, ]
oEverything	:= [AppEverything	,        	,     	,      	,       	,	0   	, "ahk_class EVERYTHING"  	, ]
oVivaldiX  	:= [AppVivaldi   	,        	,     	,      	,       	,	    	,                         	, AppVivaldiXtra]

App         	:= {
  ST        	: oST        	,
  NPP       	: oNPP       	,
  DOpus     	: oDOpus     	,
  Everything	: oEverything	,
  VivaldiX  	: oVivaldiX  	,
  }
