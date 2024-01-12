#Hotstring EndChars -()[]{}:'"/\,.?!`n `t;  ;Char that should follow a Hotstring 'n Enter 't Tab

; O ending char required, but omitted
:O:btw::by the way
:O:btw1::by the way{!}

; R Send the replacement text raw
:R:btw::by the way
:R:btw2::by the way?

/*
Selected help from autohotkey.com/docs/Hotstrings.htm#EndChars
* (*0 off): Ending character is not required to trigger the hotstring
? (?0 off): The hotstring will be triggered even when it is inside another word; that is, when the character typed immediately before it is alphanumeric. For example, if :?:al::airline is a hotstring, typing "practical " would produce "practicairline ". Use ?0 to turn this option back off.

O (O0 off): Omit the ending character of auto-replace hotstrings when the replacement is produced. This is useful when you want a hotstring to be kept unambiguous by still requiring an ending character, but don't actually want the ending character to be shown on the screen. For example, if :o:ar::aristocrat is a hotstring, typing "ar" followed by the spacebar will produce "aristocrat" with no trailing space, which allows you to make the word plural or possessive without having to backspace.

R: Send the replacement text raw; that is, exactly as it appears rather than translating {Enter} to an ENTER keystroke, ^c to Control-C, etc. This option is put into effect automatically for hotstrings that have a continuation section. Use R0 to turn this option back off.

C1 (C0 off): Do not conform to typed case. Use this option to make auto-replace hotstrings case insensitive and prevent them from conforming to the case of the characters you actually type. Case-conforming hotstrings (which are the default) produce their replacement text in all caps if you type the abbreviation in all caps. If you type only the first letter in caps, the first letter of the replacement will also be capitalized (if it is a letter). If you type the case in any other way, the replacement is sent exactly as defined.

::text1::
(
Any text between the top and bottom parentheses is treated literally, including commas and percent signs.
By default, the hard carriage return (Enter) between the previous line and this one is also preserved.
    By default, the indentation (tab) to the left of this line is preserved.
See continuation section for how to change these default behaviors.
The presence of a continuation section also causes the hotstring to default to raw mode. The only way to override this special default is to specify the r0 option in each hotstring that has a continuation section (e.g. :r0:text1::)
)

#HotIfWinActive ahk_class Notepad
::btw::This replacement text will appear only in Notepad.
#HotIfWinActive
::btw::This replacement text appears in windows other than Notepad
 */
