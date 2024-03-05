<p align="center">
A collection of Windows extensions written in
<br>
<a href="https://www.autohotkey.com">AutoHotkey</a> automation scripting language
</p>


## Introduction

  - [AutoHotkey](<./AutoHotkey.ahk>) main launcher, loads common and machine-specific files
  - [\[PCH\]](<./[PCH].ahk>) and `aX.ahk` machine-specific `Auto-Execute Section` and keybindings

### Scripts
  - [0 Hyper](<./0 Hyper.ahk>) <kbd>⇪</kbd> as a "Hyper" modifier key when held and open a launcher app when tapped
  - [xReformatPrompt](<./xReformatPrompt.ahk>) avoid accidentally formatting your USB drive by auto-closing prompts with a 'Format disk' button (helpful when inserting USB drives with unrecognized formatting). Use in a separate process / compile to a standalone `exe` with `Ahk2Exe` to not block the main app
  - [Home row modifier (⌂mod)](./⌂mod_modtap.ahk) without affecting fast typing (experimental)! ⌂modtap key:
    - located at the most convenient `⌂`home row position (e.g., 👆🏻<kbd>f</kbd>)
    - on hold acts as a `mod`ifier (e.g., <kbd>⇧</kbd>)
    - on a single `tap` acts as usual and types its letter (`f`)

#### Insert various characters and symbols
  - [char ⎇›](<./char ⎇›.ahk>) [TypES](https://github.com/eugenesvk/kbdLayout-Mac) typographical layout and easily insert modifier symbols like ⎇ when pressed with <kbd>⎇›</kbd>
  - [char🠿](<./char🠿.ahk>) insert chars on key Hold via a Mac-like Press&Hold character picker:<br/>
    ![sequential labels](./img/ch🠿Dia.png)<br/>
    ![custom labels](./img/ch🠿Sym.png)<br/>
    where a symbol can be inserted with a single key label, cursor keys and <kbd>⏎</kbd>, or a mouse click on the symbol or the label. Symbols, labels, hold duration trigger, and a few picker styles are customizable.
  - [char-AltTT](<./char-AltTT.ahk>) add diacritics to keys by triggering an diacritic type and finishing with a key (with a tooltip hint) or insert arbitrary symbols via the same mechanism<br/>
    ![tooltip diacritics](<./img/ch⎇TT Dia.png>) <kbd>⇧</kbd><kbd>⎇</kbd><kbd>m</kbd> to insert macron<br/>
    ![tooltip math symbols](<./img/ch⎇TT Sym.png>) <kbd>⇧</kbd><kbd>⎇</kbd><kbd>t</kbd> to insert math
  - [6 NumPad](<./6 NumPad.ahk>) NumPad with two prefix keys:
    - right-hand: <kbd>⭾</kbd> <kbd>7</kbd>...<kbd>0</kbd>...<kbd>n</kbd>...<kbd>/</kbd>
    - left-hand: <kbd>⎇</kbd> <kbd>1</kbd>...<kbd>5</kbd>...<kbd>z</kbd>...<kbd>b</kbd>
#### Mouse
  - [5 Mouse](<./5 Mouse.ahk>) e.g., scroll ←→ with <kbd>⇧</kbd><kbd>🖱↑</kbd>/<kbd>🖱↓</kbd> (MouseWheel)
  - [🖰Scroll Excel](<./🖰Scroll Excel.ahk>) horizontal scroll in Excel to be launched separately in a no-UIA Autohotkey session
  - [🖰hide on 🖮](<./🖰hide on 🖮.ahk>) hide mouse pointer while typing
#### Others
  - [Tab](<./Tab.ahk>) convert <kbd>⭾</kbd> into a prefix key and use <kbd>⭾</kbd><kbd>1</kbd>...<kbd>8</kbd> to navigate to favorite folders in a file manager or use it as a substitute for <kbd>❖</kbd><kbd>x</kbd> shortcuts
  - [9 ‹␠1 as ⎇](<./9 ‹␠1 as ⎇.ahk>) restore physical <kbd>⎇</kbd> (mapped to <kbd>⎈</kbd> via SharpKeys registry override) as <kbd>⎇</kbd> (e.g., <kbd>⎈</kbd><kbd>f4</kbd>→ <kbd>⎇</kbd><kbd>f4</kbd>)
  - [8 Language](<./8 Language.ahk>) remap <kbd>⎇</kbd><kbd>⇪</kbd> to keyboard layout switching (with workarounds around various window types)

### Libraries
Library files in `/lib` used only when function by the same name is called
- [constTypES](<./lib/constTypES.ahk>) definition for the [TypES](https://github.com/eugenesvk/kbdLayout-Mac) typographical layout
- [constWin32](<./lib/constWin32.ahk>) get any Windows API constant by name (full and short) (external dll/data)
  - [winAPIconst_embed.dll](https://github.com/eugenesvk/winAPIconst/releases) with data embedded
  - or `winAPIconst_mmap.dll` with `data/winAPI_Const.rkyv_data_0` `data/winAPI_Const.rkyv_state` 
- [constWin32T](<./lib/constWin32T.ahk>) translate Windows API types to DllCall types
- [constKey](<./lib/constKey.ahk>) use `⎈1` to define a keybind instead of `^1` (only works in a function)
- [Win](<./lib/Win.ahk>) app/window management, including applying borderless style
- [Unicode](<./lib/Unicode.ahk>) `RemoveLetterAccents`
- [cfg FileExplore](<./lib/cfg FileExplore.ahk>) to toggle extensions, hidden files in Windows File Explorer
- [4 Cursor](<./lib/4 Cursor.ahk>) Home Row cursor with 🠿<kbd>⎇›</kbd>
- Data types and their extension
  - [Collection](<./lib/Collection.ahk>) like `OrderedMap`
  - [Array](<./lib/Array.ahk>)
- [libFunc](<./lib/libFunc.ahk>) various helper functions
  - `keyFunc` register hotkeys and send functions
  - `RunActivMin` run a new app/switch to an existing instance, but with options to make the window borderless and pass other options
  - `OpusDir_CD` open a path in Directory Opus
  - `HasValue` checks if a value exists in an array
  - `GroupHasWin` check if the specified group contains the specified window (quasi-boolean)
  - [libFunc Scroll](<./lib/libFunc Scroll.ahk>) `ScrollHCombo` horizontal scroll, picking the working sub-function depending on the window/app since ther isn't a single universal horizontal scrolling method. Unfortunately, with 'UIA' enabled fails with COM (Word/Excel...) due to some weird permissions mismatch [src](autohotkey.com/boards/viewtopic.php?p=432502#p432452)
  - [libFunc Dbg](<./lib/libFunc Dbg.ahk>) `dbgTT` debugging tooltip that only shows if a global `dbg` var is set above a threshold, also with posion/timer arguments, less intrusive than a typical message box (though `dbgMsg` is also there)
- Enumerate all conhosts and tries to find the one that maps to our console window (external) [getconkbl.dll](github.com/Elfy/getconkbl)
- UI Automation (external) [UIA v2](https://github.com/Descolada/UIA-v2/raw/main/Lib/UIA.ahk)

## Install

This page (the `main` branch of the repo) doesn't support care-free installation of individual components (e.g., launching `🖰hide on 🖮.ahk` will result in warnings and might not work) or even the full combined version. So far only the following components have been separated to allow a double-click install:
  - [Press&Hold character picker](https://github.com/eugenesvk/Win.ahk/tree/pressH)
  - [Hide mouse pointer while typing](https://github.com/eugenesvk/Win.ahk/tree/mhide_kbd)
  - [Home row modifier (⌂mod)](https://github.com/eugenesvk/Win.ahk/tree/modtap)

Others would likely require manual modifications to import only the libraries that they require

Also, some of the scripts require __external libraries__ not included in this repo, so copy them to `Lib` from:
  - [UIA v2](https://github.com/Descolada/UIA-v2/raw/main/Lib/UIA.ahk)
  - [winAPIconst_embed.dll](https://github.com/eugenesvk/winAPIconst/releases)
  - [Acc](https://github.com/Descolada/AHK-v2-libraries/blob/main/Lib/Acc.ahk)

## Use

## Configure

#### Press&Hold character picker
  - [char🠿](./char🠿.ahk) contains the hotkey definitions and what set of symbols those hotkeys should use to show a symbol picker
  - [symbol](./gVar/symbol.ahk) contains a few Maps of symbols that can be updated to insert whatever symbols you need
  - [PressH](<./gVar/PressH.ahk>) contains a set of visual tweaks (like fonts and colors) and `TimerHold` hold threshold (0.4 sec by default)
  - [varWinGroup](./varWinGroup.ahk) contains the list of apps in the `PressnHold` group where the functionality is enabled
  - [PressH](./lib/PressH.ahk) library contains the actual `PressH_ChPick` function that creates the popup characte picker, and has `lbl_en` list of default labels used when no user defined labels are provided (non-english labels can be added to the [constKey](./lib/constKey.ahk) library)

#### Hide mouse pointer while typing

You can configure the script to ignore selected mouse behavior when you type:

  - hide mouse pointer to avoid obscuring your text caret with it
  - clicks to avoid surprising caret movements
  - wheel scrolling (on a per-direction level)
  - pointer movements within user defined horizontal/vertical threshold (to help with accidentally moving your mouse)

And further configure it to:

  - ignore key presses with modifiers, e.g., hide the pointer on <kbd>a</kbd>, but ignore <kbd>⎈</kbd><kbd>a</kbd> as that's not typing
  - work only within text fields, e.g., don't hide when using <kbd>j</kbd> to scroll down in an app
  - ignore specific apps (and manually tweaked to work only in specific apps)

All of these are set by changing the values of the `ucfg🖰hide` configuration map at the top of [🖰hide on 🖮](<./🖰hide on 🖮.ahk>) and reloading the script. Each value has a comment explaining what it does and what values are allowed

You can also change the keys that trigger hiding the pointer by adjusting the `keys_m['en']` map for the English locale


## Known issues
  - Horizontal scrolling fails with 'UIA' enabled AutoHotkey and COM (Word/Excel...) due to some weird permissions mismatch [src](autohotkey.com/boards/viewtopic.php?p=432502#p432452), use [🖰Scroll Excel](<./🖰Scroll Excel.ahk>)
  - `🖰hide on 🖮` with `limit2text` enabled may take ~0.3sec in some apps to determine whether the text cursor is in a text field due to using accessibility frameworks for such determination, and this might have a negative affect on other timing-sensitive typing hotkeys like modtaps. Workaround: use the [standalone version](https://github.com/eugenesvk/Win.ahk/tree/mhide_kbd)

## Credits
