<p align="center">
Hide 🖰 mouse pointer when 🖮 typing
</p>

https://github.com/eugenesvk/Win.ahk/assets/12956286/2bf30625-a621-4b41-bdae-70ba39c04b1e

## Introduction

This [AutoHotkey v2](https://www.autohotkey.com) script can be configured to ignore selected mouse behavior when you type:

  - hide mouse pointer to avoid obscuring your text caret with it
  - clicks to avoid surprising caret movements
  - wheel scrolling (on a per-direction level)
  - pointer movements within user defined horizontal/vertical threshold (to help with accidentally moving your mouse)

The script can also be further configured to:

  - ignore key presses with modidifers, e.g., hide the pointer on <kbd>a</kbd>, but ignore <kbd>⎈</kbd><kbd>a</kbd> as that's not typing
  - work only within text fields, e.g., don't hide when using <kbd>j</kbd> to scroll down in an app
  - ignore specific apps (and manually tweaked to work only in specific apps)
  - adjust pointer suppression method:
    - `sys` replace system pointers (Ibeam, Arrow, etc.) with a transparent image, but fails with app-specific ones like a Cross in Excel
    - `gui` for the app to hide its pointer by attaching our own blank gui element to its window (might break some functionality when hiding, e.g., mouse extra buttons might stop working)

This script also fixes the issue with the main mouse pointer becoming "blocky" if the pointer size is > 1

## Install

For standalone "double-click-to-run" use:

  - Install [AutoHotkey v2](https://www.autohotkey.com/download/ahk-v2.exe)
  - Download 
    - latest stable version: open [releases](https://github.com/eugenesvk/Win.ahk/releases) and find the latest release with a tag similar to `0.0.3-mhide` or a name similar to "Standalone: Hide mouse pointer while typing" and download `Assets`→`Source code (zip)`
    - latest beta version: [mhide_kbd.zip](https://github.com/eugenesvk/Win.ahk/archive/refs/heads/mhide_kbd.zip) of `mhide_kbd` of this repository
  - Unzip the downloaded zip file anywhere you like
  - (optional) to autostart on Windows login:
    - create a Shortcut (`.lnk`) to `🖰hide on 🖮_launch.ahk`
    - copy this `🖰hide on 🖮_launch.lnk` to your `%AppData%\Microsoft\Windows\Start Menu\Programs\Startup` (which should expand to `C:\Users\YOUR_USER_NAME\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup`)

To use with your _existing_ AutoHotkey scripts:

  - Copy libraries from `lib` to your own `lib` sub-folder
  - Copy `gVar` to your own `gVar` folder
  - Copy [🖰hide on 🖮](<./🖰hide on 🖮.ahk>) to your main AutoHotkey folder
  - Import the main script `#include %A_scriptDir%\🖰hide on 🖮.ahk	; Hide idle mouse cursor when typing`

## Configure

Change the default values of the `ucfg🖰hide` configuration apps at the top of [🖰hide on 🖮](<./🖰hide on 🖮.ahk>) and relaunch/reload the script. Each value has a comment explaining what it does and what values are allowed
The keys that trigger hiding the pointer are in the `keys_m['en']` map for the English locale and include all alphanumeric keys as well as ␈␡␠

## Use

For a standalone use: double-click on [🖰hide on 🖮_launch](<./🖰hide on 🖮_launch.ahk>)

To use with your existing AutoHotkey scripts: the import should do the trick

## Known issues
  - Changing GUI element owner to AHK breaks modifiers, requiring adding sleep(1) https://www.autohotkey.com/boards/viewtopic.php?f=82&t=123412
  - BUT this workaround prevents getting mouse pointer status correctly https://www.autohotkey.com/boards/viewtopic.php?f=82&t=123908
    - potential workaround is to move pointer status check earlier
  - `displayCounter` sometimes misbehaves and goes below -1, not sure whether whether this has any negative effects
  - `🖰hide on 🖮` with `limit2text` enabled may take ~0.3sec in some apps to determine whether the text cursor is in a text field due to using accessibility frameworks for such determination, and this might have a negative affect on other timing-sensitive typing hotkeys like modtaps. Workaround: use the standalone version [🖰hide on 🖮_launch](<./🖰hide on 🖮_launch.ahk>)

## Credits
  - [Windows-Cursor-Hider](https://github.com/Stefan-Z-Camilleri-zz/Windows-Cursor-Hider) the old simpler v1 version of the same idea
  - [UI Automation](https://github.com/Descolada/UIA-v2) library allowing detection of editable text fields
