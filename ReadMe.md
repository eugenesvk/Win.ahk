<p align="center">
Proof of concept for home row mods
<br>
in AutoHotkey
</p>
<p align="center">  
(without activation delays introduced by timing-only approach)
</p>


## Introduction

Home row modifier (⌂mod) is a key that

  - located at the most convenient home row position (e.g., <kbd>f</kbd>)
  - on a single tap acts as usual and types its letter (`f`)
  - on hold acts as a modifier (e.g., <kbd>⇧</kbd>)

Usually the difference between a tap and a hold is determined __only based on time__ since key↓, i.e., if you hold <kbd>f</kbd> longer than 1 second, it becomes <kbd>⇧</kbd>. However, this introduces a mental hurdle as you can't use it in the same convenient manner you'd use a regular <kbd>⇧</kbd>, but always have to keep that artificial delay in mind.

Another approach is to __send the letter on__ key↓ and then <kbd>␈</kbd> __clean it up__ if it's being held. But this could backfire outside a text field where <kbd>␈</kbd> could be a "go history back" command in a browser (and text field detection is unfortunately not 100% reliable). This also breaks fast typing as typing `fi` while holding <kbd>f</kbd> could clean up `i` instead of `f`

This script tries to use 2 heuristics to detect a hold of a ⌂mod (but only for <kbd>f</kbd> as a ⌂<kbd>⇧</kbd>)

1) time     definitely a HOLD if held longer than X

2) sequence maybe      a HOLD depending on whether the next key

  - is tapped <kbd>a↕</kbd> (pressed down and released), this is a Hold of ⌂<kbd>f</kbd>
  - or only pressed <kbd>a↓</kbd><kbd>f↑</kbd>, this is just fast `fa` typing where it's common to press the next button before the first one is released

A slightly more complicated set of actions depending on the sequence of keys is described below:

### Legend:

  ↓ key down<br/>
  ↑ key up<br/>
  ↕ key tap<br/>
  🠿 key hold<br/>
  • perform action at this point<br/>
  •<ΔH perform action at this point only if ⌂tHold seconds has NOT passed<br/>
  ⌂ home row modtap key <br/>
  a any regular key (not modtap)<br/>

⌂↓ always activates our modtap input handler, so won't be marked as •
Key sequences and how to treat them:
```
Sequence    Label Comment
a↓ ⌂↓ a↑ ⌂↑ ↕     modtap starts after another key, should let the prior key finish
      •      xx)  print nothing (a is printed outside of this script)
         •  ↕xz)  print ⌂
⌂↓       ⌂↑ ↕     single standalone tap, not hold
         •  ↕00)  print ⌂
⌂↓ a↓ ⌂↑ a↑ ↕     should be ⌂,a as that's just fast typing
•            0a)  print nothing, don't know the future yet, just activate input hook
   •<ΔH      ?0b) print nothing, don't know whether to print ⇧A or ⌂,a, the hold depends on the next key sequence
   •>ΔH      🠿0c) print ⇧A
      •     ↕2a)  print ⌂,a
         •  ↕2b)  print nothing, 2a handle it
⌂↓ a↓ a↑ ⌂↑ 🠿    should be ⇧A, not ⌂
   •              same as above
      •<ΔH  🠿1aa) print ⇧A, also set ⌂ var as a modifier since we know it's not quick typing
      •>ΔH  🠿1ab) print nothing, 0c handled key↓
         •  🠿1b)  print nothing, 1a handles key, ⌂ is a mod
```

## Install

Download all the files in this branch and double click `⌂mod_modtap_launch.ahk`
(`lib` folder contains the needed libraries, `gVar` — the needed variables)

## Use

- Type `f`to get the expected `f`fog
- Type `fog` quickly to get the expected `fog`
- Type `fu` quickly, but hold onto <kbd>f</kbd> for a tiny bit longer (release it after releasing <kbd>u</kbd>) to get `U`
- Hold <kbd>f</kbd> for longer than 0.5 seconds , then type <kbd>u</kbd> get `U` without an `f`

## Configure

  Adjust configuration variables in the `global ucfg⌂mod := Map` line of the script
  - Set `tooltip⎀` (enabled by default) to show a tooltip near the text cursor (caret) with an indicator of a modifier status, e.g., after holding <kbd>f</kbd> and tapping <kbd>w</kbd> you'd get `‹⇧` indicator  like ![f](./img/CaretToolTip.png)
  - Change the hold duration via `holdTimer`

## Known issues

- only a few keys working
  - <kbd>f</kbd> as ⌂<kbd>‹⇧</kbd>
  - <kbd>j</kbd> as ⌂<kbd>⇧›</kbd>
- tapping same-side real modifier (e.g., <kbd>‹⇧</kbd>) resets the status of the homerow modifier, and the latter doesn't track&reset itself
- same-type opposite-side modifiers are disabled, so if ⌂<kbd>f</kbd>(‹⇧) is activated as a Hold, then ⌂<kbd>j</kbd>(⇧›) won't activate, but will act like a regular key

## Credits
