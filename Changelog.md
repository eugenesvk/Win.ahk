# Changelog
All notable changes to this project will be documented in this file

[unreleased]: https://github.com/eugenesvk/Win.ahk/tree/mhide_kbd/compare/0.0.3-mhide...mhide_kbd
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
- __Changed__
  + add a space in `🖰 hide on 🖮` to allow matching on `hide` in some launchers
  + add a mousegetpos error handler

[0.0.3-mhide]: https://github.com/eugenesvk/Win.ahk/tree/mhide_kbd/tag/0.0.3-mhide
## [0.0.3-mhide]
- __Fixed__
  + :beetle: "physical" state of keys used in modtaps not reflecting their physical state. Convert to checks of logical state since "physical" is not really physical anyway

[0.0.2-mhide]: https://github.com/eugenesvk/Win.ahk/tree/mhide_kbd/tag/0.0.2-mhide
## [0.0.2-mhide]
- __Fixed__
  + :beetle: hide app-specific pointers, e.g., a big fat cross in Excel
  + :beetle: labels' list mismatch in constKey
  + :beetle: add missing library updates
  + :beetle: a pointer visibility check on mouse crossing app borders

[0.0.1-mhide]: https://github.com/eugenesvk/Win.ahk/tree/mhide_kbd/tag/0.0.1-mhide
## [0.0.1-mhide]
- __Added__
  + <kbd>␠</kbd>,<kbd>␈</kbd>,<kbd>␡</kbd> keys to trigger pointer hiding behavior
