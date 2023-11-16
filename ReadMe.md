<p align="center">
Hide 🖰 mouse pointer when 🖮 typing
</p>

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

This script also fixes the issue with the main mouse pointer becoming "blocky" if the pointer size is > 1

## Install

For a standalone use:

  - Copy this repository

To use with your existing AutoHotkey scripts:

  - Copy libraries from `lib` to your own `lib` sub-folder
  - Copy `gVar` to your own `gVar` folder
  - Copy [🖰hide on 🖮](<./🖰hide on 🖮.ahk>) to your main AutoHotkey folder
  - Import the main script `#include %A_scriptDir%\🖰hide on 🖮.ahk	; Hide idle mouse cursor when typing`

## Configure

Change the default values of the `ucfg🖰hide` configuration apps at the top of [🖰hide on 🖮](<./🖰hide on 🖮.ahk>) and relaunch/reload the script. Each value has a comment explaining what it does and what values are allowed

## Use

For a standalone use: double-click on [🖰hide on 🖮_launch](<./🖰hide on 🖮_launch.ahk>)

To use with your existing AutoHotkey scripts: the import should do the trick

## Known issues

## Credits
  - [Windows-Cursor-Hider](https://github.com/Stefan-Z-Camilleri-zz/Windows-Cursor-Hider) the old simpler v1 version of the same idea
  - [UI Automation](https://github.com/Descolada/UIA-v2) library allowing detection of editable text fields
