#Requires AutoHotKey 2.0.10

<!F5::{ ; try to find keyboard number
  Loop 10 {
    startOffset	:= 20
    Index      	:= A_Index+startOffset
    maxTT      	:= 20
    ToolTipNo  	:= round(A_Index/(startOffset+10)*maxTT,0)+1
    TT("Index: " Index,4,ToolTipNo) ; show tooltip # ToolTipNo for 4 seconds
    sleep(500)
    Loop 5 {
      KeyboardLED("All",0, Index)
      Sleep(50)
      KeyboardLED("Num",-1, Index)
      Sleep(50)
      KeyboardLED("Caps",-1, Index)
      Sleep(50)
      KeyboardLED("Scroll",-1, Index)
      Sleep(50)
    }
  }
  }

<!F5::{ ; flash all LEDs
  MsgBox("flash all LEDs", "Media", "T0.5")
  led_flash_all1()
  }
led_flash_all1() { ; flash all LEDs
  Loop 5 {
    KeyboardLED("All",0)
    Sleep(250)
    KeyboardLED("Num",-1)
    Sleep(250)
    KeyboardLED("Caps",-1)
    Sleep(250)
    KeyboardLED("Scroll",-1)
    Sleep(250)
    }
  }

led_flash_all2() { ; flash all LEDs
  Loop 7 {
    KeyboardLED("All",1)
    Sleep(500)
    KeyboardLED("All",0)
    Sleep(500)
    }
  }
led_flash_all→() { ; cycle all LEDs left to right
  Loop 7 {
    KeyboardLED("All",0)
    Sleep(250)
    KeyboardLED("Num",-1)
    Sleep(250)
    KeyboardLED("Caps",-1)
    Sleep(250)
    KeyboardLED("Scroll",-1)
    Sleep(250)
    }
  }
led_flash_progress() { ; progress bar in LEDs
  Loop 5 {
    KeyboardLED("All",0)
    Sleep(300)
    KeyboardLED("Num",-1)
    Sleep(300)
    KeyboardLED("Num+Caps",-1)
    Sleep(300)
    KeyboardLED("All",-1)
    Sleep(300)
    }
  }
led_flash_knight() { ; Knight Rider KITT cycling all LEDs ;-)
  Loop 7 { ; Knight Rider KITT cycling all LEDs ;-)
    KeyboardLED("Num",-1)
    Sleep(300)
    KeyboardLED("Caps",-1)
    Sleep(300)
    KeyboardLED("Scroll",-1)
    Sleep(300)
    KeyboardLED("Caps",-1)
    Sleep(300)
    }
  }

/*
; Registry view of keyboard devices
; 23=0x17
; 0x23=35
Hadrwary Ids
HID\VID_1044&PID_7A03&REV_0000&MI_00	HID\VID_0665&PID_6000&REV_0088&MI_02	HID\VID_0665&PID_6000&REV_0088&MI_00
HID\VID_1044&PID_7A03&MI_00         	HID\VID_0665&PID_6000&MI_02         	HID\VID_0665&PID_6000&MI_00
HID\VID_1044&UP:0001_U:0006         	HID\VID_0665&UP:0001_U:0006         	HID\VID_0665&UP:0001_U:0006
=HID_DEVICE_SYSTEM_KEYBOARD         	HID_DEVICE_SYSTEM_KEYBOARD          	HID_DEVICE_SYSTEM_KEYBOARD
HID_DEVICE_UP:0001_U:0006           	HID_DEVICE_UP:0001_U:0006           	HID_DEVICE_UP:0001_U:0006
=HID_DEVICE                         	HID_DEVICE                          	HID_DEVICE

Device instance path                         	PhysDevObjectName!        	BusNumb!	=Class GUID                           	=rankOfDrv	=Address
HID\VID_1044&PID_7A03&MI_00\9&3B1E84CE&0&0000	\Device\00000135 (dec=309)	00000035	{4d36e96b-e325-11ce-bfc1-08002be10318}	00FF1003  	00000001 no power mgmt
HID\VID_0665&PID_6000&MI_00\9&28BF34E4&0&0000	\Device\00000130 (dec=304)	00000034	{4d36e96b-e325-11ce-bfc1-08002be10318}	00FF1003  	00000001
HID\VID_0665&PID_6000&MI_00\9&28BF34E4&0&0000	\Device\0000012e (dec=302)	00000032	{4d36e96b-e325-11ce-bfc1-08002be10318}	00FF1003  	00000001
*/
