#!/usr/bin/env xonsh

# ! copy upx.exe to the folder where Ahk2Exe.exe is
ahk_bin = 'C:/path/to/AutoHotkey'

scripts = ['DOpusBorderless']
for script in scripts: # Compile to dopus.exe
  @(f"{ahk_bin}/Compiler/Ahk2Exe.exe") \
    /in  	f"./{script}.ahk" \
    /out 	f"./dopus.exe" \
    /icon	"D:/AppData/Icons/dopus_100.ico" \
    /base f"{ahk_bin}/v2/AutoHotkey.exe" \
    /compress 2 # 2=UPX
