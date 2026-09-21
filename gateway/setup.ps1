$ErrorActionPreference = "Stop"
Write-Host "Kamera LIVE v1002 - konfiguracja MediaMTX" -ForegroundColor Cyan
$user = Read-Host "Login kamery (np. admin)"
$sec = Read-Host "Haslo kamery" -AsSecureString
$ptr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($sec)
try { $pass = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr) }
finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr) }

$encodedUser = [uri]::EscapeDataString($user)
$encodedPass = [uri]::EscapeDataString($pass)
$rtsp = "rtsp://${encodedUser}:${encodedPass}@192.168.0.3:554/live/ch00_0"

$template = Get-Content "$PSScriptRoot\mediamtx.template.yml" -Raw
$template.Replace("CAMERA_RTSP_URL", $rtsp) | Set-Content "$PSScriptRoot\mediamtx.local.yml" -Encoding UTF8
Write-Host ""
Write-Host "Utworzono gateway\mediamtx.local.yml (ignorowany przez Git)." -ForegroundColor Green
Write-Host "Haslo nie jest zapisywane w plikach repozytorium." -ForegroundColor Yellow
