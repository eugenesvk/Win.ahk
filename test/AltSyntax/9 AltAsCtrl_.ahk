#Requires AutoHotKey 2.1-alpha.4

; Ctrl remapped to alt via SharpKeys
  LCtrl & Tab::AltTab	; ⎈⭾​	⟶ Switch to Next     window
  <^F4::!F4
  ; <^1::!1
  ; <^2::!2
  <+<#Up::+^Up
  <+<#Down::+^Down
  <+<#Esc::+^Esc
  *#Up::^Up
  *#Down::^Down
  *#Left::^Left
  *#Right::^Right
  ; AppsKey & vkBF::^vkBF
; TODO: convert a template to use ␠›1 syntax (can AppsKey with alt (use different syntax not & for alt))
