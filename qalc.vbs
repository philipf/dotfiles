Set objShell = CreateObject("WScript.Shell")
objShell.Run "wsl.exe -d Ubuntu --cd ~ -- qalculate-gtk", 0, False