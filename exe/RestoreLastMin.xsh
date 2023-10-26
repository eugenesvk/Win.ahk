#!/usr/bin/env xonsh

# ! copy upx.exe to the folder where Ahk2Exe.exe is
ahk_bin = 'C:/path/to/AutoHotkey'

scripts = ['RestoreLastMin']
for script in scripts: # Compile to DisableReformatPrompt.exe
  @(f"{ahk_bin}/Compiler/Ahk2Exe.exe") \
    /in  	f"./{script}.ahk" \
    /out 	f"./{script}.exe" \
    /base f"{ahk_bin}/v2/AutoHotkey.exe" \
    /compress 2 # 2=UPX
