class TapHoldManager {
	Bindings := Map(), Bindings.CaseSense := "Off"

	__New(tapTime := 150, holdTime := tapTime, maxTaps := -1, prefixes := "$", window := ""){
		this.tapTime := tapTime
		this.holdTime := holdTime
		this.maxTaps := maxTaps
		this.prefixes := prefixes
		this.window := window
	}

	Add(keyName, callback, tapTime?, holdTime?, maxTaps?, prefixes?, window?){    ; Add hotkey
		if this.Bindings.Has(keyName)
			this.RemoveHotkey(keyName)
		this.Bindings[keyName] := TapHoldManager.KeyManager(keyName, callback, tapTime ?? this.tapTime, holdTime ?? this.holdTime, maxTaps ?? this.maxTaps, prefixes ?? this.prefixes, window ?? this.window)
	}

	RemoveHotkey(keyName){ ; to remove hotkey
		this.Bindings.Delete(keyName).SetState(0)
	}

	PauseHotkey(keyName){ ; to pause hotkey temprarily
		this.Bindings[keyName].SetState(0)
	}

	ResumeHotkey(keyName){ ; resume previously deactivated hotkey
		this.Bindings[keyName].SetState(1)
	}

	class KeyManager {
		state := 0					; Current state of the key
		sequence := 0				; Number of taps so far
		holdActive := 0				; A hold was activated and we are waiting for the release

		__New(keyName, Callback, tapTime, holdTime, maxTaps, prefixes, window){
			this.keyName := keyName
			this.Callback := Callback
			this.tapTime := tapTime
			this.holdTime := holdTime
			this.maxTaps := maxTaps
			this.prefixes := prefixes
			this.window := window

			this.HoldWatcherFn := this.HoldWatcher.Bind(this)
			this.TapWatcherFn := this.TapWatcher.Bind(this)
			this.JoyWatcherFn := this.JoyButtonWatcher.Bind(this)
			this.DeclareHotkeys()
		}

		DeclareHotkeys(){
			if (this.window)
				HotIfWinactive this.window ; sets the hotkey window context if window option is passed-in

			Hotkey this.prefixes this.keyName, this.KeyEvent.Bind(this, 1), "On" ; On option is important in case hotkey previously defined and turned off.
			if (this.keyName ~= "i)^\d*Joy"){
				Hotkey this.keyName " up", (*) => SetTimer(this.JoyWatcherFn, 10), "On"
			} else {
				Hotkey this.prefixes this.keyName " up", this.KeyEvent.Bind(this, 0), "On"
			}

			if (this.window)
				HotIfWinactive ; restores hotkey window context to default
		}

		SetState(state){ ; turns On/Off hotkeys (should be previously declared) // state is either "1: On" or "0: Off"
			; "state" under this method context refers to whether the hotkey will be turned on or off, while in other methods context "state" refers to the current activity on the hotkey (whether it's pressed or released (after a tap or hold))
			if (this.window)
				HotIfWinactive this.window

			state := (state ? "On" : "Off")
			Hotkey this.prefixes this.keyName, state
			if (this.keyName ~= "i)^\d*Joy"){
				Hotkey this.keyName " up", state
			} else {
				Hotkey this.prefixes this.keyName " up", state
			}

			if (this.window)
				HotIfWinactive
		}

		JoyButtonWatcher(){
			if GetKeyState(this.keyName)
				return
			SetTimer this.JoyWatcherFn, 0
			this.KeyEvent(0)
		}

		KeyEvent(state, *){
			if (state == this.state)
				return	; Suppress Repeats
			this.state := state
			if (state){
				; Key went down
				this.sequence++
				SetTimer this.HoldWatcherFn, -this.holdTime
			} else {
				; Key went up
				SetTimer this.holdWatcherFn, 0
				if (this.holdActive){
					this.holdActive := 0
					SetTimer this.FireCallback.Bind(this, this.sequence, 0), -1
					this.sequence := 0
					return
				}
				if (this.maxTaps > 0 && this.Sequence == this.maxTaps){
					SetTimer this.tapWatcherFn, 0
					SetTimer this.FireCallback.Bind(this, this.sequence, -1), -1
					this.sequence := 0
				} else {
					SetTimer this.tapWatcherFn, -this.tapTime
				}
			}
		}

		; If this function fires, a key was held for longer than the tap timeout, so engage hold mode
		HoldWatcher(){
			if (this.sequence > 0 && this.state == 1){
				; Got to end of tapTime after first press, and still held.
				; HOLD PRESS
				SetTimer this.FireCallback.Bind(this, this.sequence, 1), -1
				this.holdActive := 1
			}
		}

		; If this function fires, a key was released and we got to the end of the tap timeout, but no press was seen
		TapWatcher(){
			if (this.sequence > 0 && this.state == 0){
				; TAP
				SetTimer this.FireCallback.Bind(this, this.sequence), -1
				this.sequence := 0
			}
		}

		FireCallback(seq, state := -1){
			this.Callback.Call(state != -1, seq, state)
		}
	}
}