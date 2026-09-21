$ErrorActionPreference="Stop"
$vlc="C:\Program Files\VideoLAN\VLC\vlc.exe"

if(!(Test-Path $vlc)){throw "Nie znaleziono VLC w: $vlc"}
if(!(Test-Path "$PSScriptRoot\camera.local.ps1")){throw "Brak camera.local.ps1. Uruchom najpierw .\setup.ps1"}

. "$PSScriptRoot\camera.local.ps1"

Write-Host "Kamera LIVE v1005" -ForegroundColor Cyan
Write-Host "Kamera: 192.168.0.3 | RTSP przez TCP" -ForegroundColor Cyan
Write-Host "Wyjscie HTTP: http://127.0.0.1:8091/camera.mjpg" -ForegroundColor Green
Write-Host "Nie zamykaj VLC podczas podgladu." -ForegroundColor Yellow

& $vlc --rtsp-tcp --network-caching=700 $CameraUrl `
  --sout '#transcode{vcodec=MJPG,vb=2500,scale=1,acodec=none}:standard{access=http,mux=mpjpeg,dst=:8091/camera.mjpg}' `
  --sout-keep
