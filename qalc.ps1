$env:GTK_SCALE = 2
$env:GDK_DPI_SCALE = 2
Start-Process -WindowStyle Hidden -FilePath "wsl.exe" -ArgumentList "-d Ubuntu --cd ~ -- qalculate-gtk"