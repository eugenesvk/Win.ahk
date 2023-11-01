<p align="center">
Insert⏎ custom symbols by holding a key
<br>
and selecting from a character picker
</p>

## Introduction

[char🠿](<./char🠿.ahk>) binds on key hold a Mac-like Press&Hold character picker:<br/>
    ![sequential labels](./img/ch🠿Dia.png)<br/>
    ![custom labels](./img/ch🠿Sym.png)
where a symbol can be inserted with a 1-key label or via cursor keys and <kbd>⏎</kbd>. Symbols, labels, hold duration trigger, and a few picker styles are customizable.


## Install

  - Copy this repository and double-click on [char🠿_launch](./char🠿_launch.ahk) <br/>
    OR
  - Copy libraries from `lib` to your own `lib` sub-folder
  - Copy `gVar` to your own `gVar` folder
  - Copy [char🠿](./char🠿.ahk) to your main AutoHotkey folder
  - Import the main script `#Include %A_scriptDir%\char🠿.ahk	; Diacritics+chars on key hold`

## Configure

  - [char🠿](./char🠿.ahk) contains the hotkey definitions and what set of symbols those hotkeys should use to show a symbol picker (see 4 steps marked by `;;;` to update)
  - [symbol](./gVar/symbol.ahk) contains a few Maps of symbols that can be updated to insert whatever symbols you need
  - [PressH](<./gVar/PressH.ahk>) contains a set of visual tweaks (like fonts and colors) and `TimerHold` hold threshold (0.4 sec by default)
  - [varWinGroup](./varWinGroup.ahk) contains the list of apps where this script should be enabled
  - [PressH](./lib/PressH.ahk) library contains the actual `PressH_ChPick` function that creates the popup characte picker, and has `lbl_en` list of default labels used when no user defined labels are provided (non-english labels can be added to the [constKey](./lib/constKey.ahk) library)

## Known issues

## Credits
