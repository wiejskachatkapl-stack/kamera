Set-Location "$PSScriptRoot\web"
Write-Host "Aplikacja: http://localhost:8090" -ForegroundColor Green
python -m http.server 8090
