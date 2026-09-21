$ErrorActionPreference = "Stop"
$api = Invoke-RestMethod "https://api.github.com/repos/bluenviron/mediamtx/releases/latest"
$asset = $api.assets | Where-Object { $_.name -match 'windows_amd64\.zip$' } | Select-Object -First 1
if (-not $asset) { throw "Nie znaleziono paczki MediaMTX Windows amd64." }
$tmp = Join-Path $env:TEMP "mediamtx.zip"
Invoke-WebRequest $asset.browser_download_url -OutFile $tmp
$dest = Join-Path $PSScriptRoot "_mediamtx"
if (Test-Path $dest) { Remove-Item $dest -Recurse -Force }
Expand-Archive $tmp -DestinationPath $dest -Force
Copy-Item (Join-Path $dest "mediamtx.exe") (Join-Path $PSScriptRoot "mediamtx.exe") -Force
Remove-Item $dest -Recurse -Force
Remove-Item $tmp -Force
Write-Host "MediaMTX pobrany." -ForegroundColor Green
