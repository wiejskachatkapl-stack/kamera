$ErrorActionPreference="Stop"
Write-Host "Kamera LIVE v1005 - konfiguracja lokalna kamery" -ForegroundColor Cyan

$user=Read-Host "Login kamery (np. admin)"
$sec=Read-Host "Haslo kamery" -AsSecureString
$ptr=[Runtime.InteropServices.Marshal]::SecureStringToBSTR($sec)
try{$pass=[Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr)}
finally{[Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr)}

$u=[uri]::EscapeDataString($user)
$p=[uri]::EscapeDataString($pass)
$url="rtsp://${u}:${p}@192.168.0.3:554/live/ch00_0"

"`$CameraUrl='$($url.Replace("'","''"))'" | Set-Content "$PSScriptRoot\camera.local.ps1" -Encoding UTF8

Write-Host ""
Write-Host "Utworzono gateway\camera.local.ps1." -ForegroundColor Green
Write-Host "Ten plik zawiera lokalne dane dostepowe - NIE dodawaj go do GitHub." -ForegroundColor Yellow
