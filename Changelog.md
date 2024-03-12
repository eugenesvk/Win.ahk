# Changelog
All notable changes to this project will be documented in this file

[unreleased]: https://github.com/eugenesvk/Win.ahk/compare/0.0.6-modtap...modtap
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

[0.0.6-modtap]: https://github.com/eugenesvk/Win.ahk/releases/tag/0.0.6-modtap
## [0.0.6-modtap]
- __Fixed__
  + :beetle: modtap key ↑ event being swallowed when mod isn't activated, e.g., in <kbd>⎈</kbd>↓ <kbd>f</kbd>↓ <kbd>⎈</kbd>↑ <kbd>f</kbd>↑
  + :beetle: some cases of undetectable cursor position
  + :beetle: two keys bound to the same function (e.g., <kbd>h</kbd> and <kbd>i</kbd> on hold to exit Insert mode)not interacting well with each other since interaction between modtaps isn't implemented yet
  + :beetle: tooltip timers eagerly resetting existing tooltips instead of extend them (so a new tooltip can be dismissed by a timer remainnig from the old tooltip)
  + :beetle: vk potentially not having Prior key
  + :beetle: dirty hotkey names that may have been first defined under a different name `~vk45` in a different script


[0.0.5-modtap]: https://github.com/eugenesvk/Win.ahk/releases/tag/0.0.5-modtap
## [0.0.5-modtap]
- __Fixed__
  + :beetle: non-text keys (e.g., arrow keys)double-tapping due to not being suppressed

[0.0.4-modtap]: https://github.com/eugenesvk/Win.ahk/releases/tag/0.0.4-modtap
## [0.0.4-modtap]
- __Changed__
  + :recycle: move global modtap vars to a single class
- __Fixed__
  + :beetle: mod function stuck due to slow tooltip@cursor function delaying mod send event past the point when said modtap is reset due to its UP event

[0.0.3-modtap]: https://github.com/eugenesvk/Win.ahk/releases/tag/0.0.3-modtap
## [0.0.3-modtap]
- __Added__
  + :sparkles: taphold example of a conditonal behavior driven by another app: <kbd>h</kbd> sends <kbd>⎋</kbd> when Sublime Text's modal editing plugin NeoVintageous is in Insert mode

[0.0.2-modtap]: https://github.com/eugenesvk/Win.ahk/releases/tag/0.0.2-modtap
## [0.0.2-modtap]
