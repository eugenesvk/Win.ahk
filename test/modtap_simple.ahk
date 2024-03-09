#Requires AutoHotkey v2.0
; ✗ unclean:
  ; always types, e.g., wouldn't work if you have a big chunk of text selected and want to extend with ⇧ - will replace the existing selection
  ; can easily bug with cleanups, e.g., in the same text editing option would dirty up undo stack
; https://www.autohotkey.com/boards/viewtopic.php?t=100620
$<+f::Return
$f::{
  SendInput("f")
  if(!KeyWait("f","T0.130")) {
    SendInput("{BackSpace}")
    SendInput("{LShift down}")
    KeyWait("f")
    SendInput("{LShift up}")
  }
}
$>+j::Return
$j::{
  SendInput("j")
  if(!KeyWait("j","T0.130")) {
    SendInput("{BackSpace}")
    SendInput("{RShift down}")
    KeyWait("j")
    SendInput("{RShift up}")
  }
}
; Idea: each key send its character on a press as usual, but upon holding the key down for long enough it automatically backspaces and then holds down the appropriate modifier
; Below is the code I used to turn f and j into long-press shift modifiers. This may or may not work for you, and I am still unsure about the effects of sending a backspace in a non text window (since that is unavoidable with these hotkeys). I also have heard that keywait is not good to use for this, and its better to define a separate key up hotkey, but I'm not really sure if it matters for this use case.
; Disclaimers aside, this totally fixes the rollover issue since typing is unaffected, keys are sent on a press, not a release, as is normal. The altered behavior only matters if you hold the key down, and the automatic backspacing means that in text fields you have a visual indicator (the backspace) for when the modifier is in play.
; I specify RShift and LShift so that the behavior of f when holding down j and vice versa is unaffected.
