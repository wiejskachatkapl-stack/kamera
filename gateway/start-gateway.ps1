$ErrorActionPreference = "Stop"
if (!(Test-Path "$PSScriptRoot\mediamtx.exe")) {
  Write-Host "Brak mediamtx.exe. Uruchom najpierw download-mediamtx.ps1" -ForegroundColor Yellow
  exit 1
}
if (!(Test-Path "$PSScriptRoot\mediamtx.local.yml")) {
  Write-Host "Brak konfiguracji. Uruchom najpierw setup.ps1" -ForegroundColor Yellow
  exit 1
}
Set-Location $PSScriptRoot
.\mediamtx.exe mediamtx.local.yml
