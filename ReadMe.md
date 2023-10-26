<p align="center">
Brief description
<br>
(description continued)
</p>

<p align="center">  
description continued
</p>


## Introduction

  - `AutoHotkey.ahk` main launcher, loads common and machine-specific files
  - `[X].ahk` and `aX.ahk` machine-specific `Auto-Execute Section` and keybindings

### Scrips
  - `0 Hyper` <kbd>⇪</kbd> as a "Hyper" modifier key when held and open a launcher app when tapped
  - `xReformatPrompt` avoid accidentally formatting your USB drive by autoclosing prompts with a 'Format disk' button (helpful when inserting USB drives with unrecognized formatting). Use in a separate process / compile to a standalone `exe` with `Ahk2Exe` to not block the main app
#### Insert various characters and symbols
  - `char ⎇›` [TypES](https://github.com/eugenesvk/kbdLayout-Mac) typographical layout and easily insert modifier symbols like ⎇ when pressed with <kbd>⎇›</kbd>
  - `char🠿` insert chars on key Hold via a Mac-like Pretss&Hold character picker:
    ![sequential labels](./img/ch🠿Dia.png)
    ![custom labels](./img/ch🠿Sym.png)
  - `char-AltTT` add diacritics to keys by triggering an diacritic type and finshing with a key (with a tooltip hint) or insert arbitray symbols via the same mechanism
    ![tooltip diacritics](<./img/ch⎇TT Dia.png>) <kbd>⇧</kbd><kbd>⎇</kbd><kbd>m</kbd> to insert macron
    ![tooltip math symbols](<./img/ch⎇TT Sym.png>) <kbd>⇧</kbd><kbd>⎇</kbd><kbd>t</kbd>
  - `5 Mouse` e.g., scroll ←→ with <kbd>⇧</kbd><kbd>🖱↑</kbd>/<kbd>🖱↓</kbd> (MouseWheel)
  - `6 NumPad` numpad with two prefix keys:
    - right-hand: <kbd>⭾</kbd> <kbd>7</kbd>...<kbd>0</kbd>...<kbd>n</kbd>...<kbd>/</kbd>
    - left-hand: <kbd>⎇</kbd> <kbd>1</kbd>...<kbd>5</kbd>...<kbd>z</kbd>...<kbd>b</kbd>
  - `Tab` convert <kbd>⭾</kbd> into a prefix key and use <kbd>⭾</kbd><kbd>1</kbd>...<kbd>8</kbd> to navigate to favorite folders in a file manager or use it as a substitute for <kbd>❖</kbd><kbd>x</kbd> shortcuts
  - `9 ‹␠1 as ⎇` restore physical <kbd>⎇</kbd> (mapped to <kbd>⎈</kbd> via SharpKeys registry override) as <kbd>⎇</kbd> (e.g., <kbd>⎈</kbd><kbd>f4</kbd>→ <kbd>⎇</kbd><kbd>f4</kbd>)
  - `8 Language` remap <kbd>⎇</kbd><kbd>⇪</kbd> to keyboard layout switching (with workarounds around various window types)
  - `🖰hide on 🖮` hide mouse pointer while typing

### Libraries
Library files in `/lib` used only when function by the same name is called
- `constTypES` definition for the [TypES](https://github.com/eugenesvk/kbdLayout-Mac) typographical layout
- `constWin32` get any Windows API constant by name (full and short) (external dll/data)
  - [winAPIconst_embed.dll](https://github.com/eugenesvk/winAPIconst/releases) with data embedded
  - or `winAPIconst_mmap.dll` with `data/winAPI_Const.rkyv_data_0` `data/winAPI_Const.rkyv_state` 
- `constWin32T` translate Windows API types to DllCall types
- `constKey` use `⎈1` to define a keybind instead of `^1` (only works in a function)
- `Win` app/window management, including applying borderless style
- `Unicode` `RemoveLetterAccents`
- `cfg FileExplore` to toggle extensions, hidden files in Windows File Explorer
- `4 Cursor` Home Row cursor with 🠿<kbd>⎇›</kbd>
- Data types and their extension
  - `Collection` like `OrderedMap`
  - `Array`
- `libFunc` various helper functions
  - `keyFunc` register hotkeys and send functions
  - `RunActivMin` run a new app/switch to an existing instance, but with options to make the window borderless and pass other options
  - `OpusDir_CD` open a path in Directory Opus
  - `HasValue` checks if a value exists in an array
  - `GroupHasWin` check if the specified group contains the specified window (quasi-boolean)
  - `ScrollHCombo` horizontal scroll, picking the working sub-function depending on the window/app since ther isn't a single universal horizontal scrolling method. Unfortunately, with 'UIA' enabled fails with COM (Word/Excel...) due to some weird permissions mismatch [src](autohotkey.com/boards/viewtopic.php?p=432502#p432452)
  - `dbgTT` debugging tooltip that only shows if a global `dbg` var is set above a threshold, also with posion/timer arguments, less intrusive than a typical message box (though `dbgMsg` is also there)

WinLock() { ;requires two elevated tasks in the Task Scheduler
    - HasValue
- Enumerate all conhosts and tries to find the one that maps to our console window (external) [getconkbl.dll](github.com/Elfy/getconkbl)
- UI Automation (external) [UIA v2](https://github.com/Descolada/UIA-v2/raw/main/Lib/UIA.ahk)

## Install

  - Copy external libraries to `Lib`
    - [UIA v2](https://github.com/Descolada/UIA-v2/raw/main/Lib/UIA.ahk)
    - [winAPIconst_embed.dll](https://github.com/eugenesvk/winAPIconst/releases)
    - [Acc](https://github.com/Descolada/AHK-v2-libraries/blob/main/Lib/Acc.ahk)

## Use

## Known issues
  - Horizontal scrolling fails with 'UIA' enabled AutoHotkey and COM (Word/Excel...) due to some weird permissions mismatch [src](autohotkey.com/boards/viewtopic.php?p=432502#p432452)

## Credits
