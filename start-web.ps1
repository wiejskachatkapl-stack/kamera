$ErrorActionPreference="Stop"
Set-Location "$PSScriptRoot\web"
Write-Host "Kamera LIVE v1005" -ForegroundColor Cyan
Write-Host "Otworz: http://localhost:8090" -ForegroundColor Green
python -m http.server 8090 --bind 0.0.0.0
