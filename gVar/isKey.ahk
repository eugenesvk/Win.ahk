#Requires AutoHotKey 2.1-alpha.4

class isKey↓ { ; manually track the status of combos that are activated via my hotkeys since these can't be tracked reliably via A_PriorHotkey as a mousewheel hotkey in the interim breaks it
  static ⎇↹ := 0
  static ⎇q := 0
}
