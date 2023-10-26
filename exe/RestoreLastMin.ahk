#Requires AutoHotKey 2.0.10

Win_RestoreLastMinWin()

; Get winID of the last minimized window
Win_GetLastMinWin() { ; autohotkey.com/board/topic/39133-how-to-restore-the-last-minimized-window-solved/
  winIDs := WinGetList()
  Loop winIDs.Length {
    WinState := WinGetMinMax("ahk_id " winIDs[A_Index])
    if (WinState = -1) {
      return winIDs[A_Index]
    }
  }
}
Win_RestoreLastMinWin() { ; Restore the last minimized window
  LastMinWin := Win_GetLastMinWin()
  if (LastMinWin != "") {
    WinRestore("ahk_id " Win_GetLastMinWin())
  }
}
