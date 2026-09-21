$ErrorActionPreference="Stop"
Write-Host "Kamera LIVE v1009" -ForegroundColor Cyan
Write-Host "Aplikacja PC: http://127.0.0.1:8090" -ForegroundColor Green
Write-Host "Telefon (to samo Wi-Fi): http://192.168.0.2:8090" -ForegroundColor Green
python "$PSScriptRoot\gateway\web-server.py"
