# Changelog
All notable changes to this project will be documented in this file

[unreleased]: https://github.com/eugenesvk/Win.ahk/compare/0.0.2...HEAD
## [Unreleased]
<!-- - __Added__ -->
  <!-- + :sparkles:  -->
  <!-- new features -->
<!-- - __Changed__ -->
  <!-- +   -->
  <!-- changes in existing functionality -->
<!-- - __Fixed__ -->
  <!-- + :beetle:  -->
  <!-- bug fixes -->
<!-- - __Deprecated__ -->
  <!-- + :poop:  -->
  <!-- soon-to-be removed features -->
<!-- - __Removed__ -->
  <!-- + :wastebasket:  -->
  <!-- now removed features -->
<!-- - __Security__ -->
  <!-- + :lock:  -->
  <!-- vulnerabilities -->

- __Added__
  + :sparkles: win: `isget⎀UIA` cursor position function
  + :sparkles: win: an alternative Accessibility library's cursor position function
  + :sparkles: a listener to Window Messages to set a global variable that can be used to conditionally define keybinds
  + lib dbg: add `Obj→Str` alias
  + lib dbg: add `dbgTL` function that shows tooltip and prints to log

- __Changed__
  + win: update `get⎀Acc` to return false for invisible caret
  + remove missing imports
  + update symbols
  + exclude Word from winkey keybinds
  + update app switcher to ignore same exes with different paths
  + update mouse hide on kb
  + move currency symbols from <kbd>h</kbd> to <kbd>p</kbd>, free <kbd>h</kbd> to on-hold editor functions
  + move app-specific functions to a separate file
  + add log function to outputdebug

- __Fixed__
  + :beetle: win: `TitleToggle` repositioning windows incorrectly on style updates due to not properly taking into account the size of invisible borders that can go offscreen (and thus make the window left-most upper-most coordinates be negative)
  + :beetle: win: a missing window error
  + :beetle: make tooltip reset timers extend existing ones

[0.0.2]: https://github.com/eugenesvk/Win.ahk/releases/tag/0.0.2
## [0.0.2]
