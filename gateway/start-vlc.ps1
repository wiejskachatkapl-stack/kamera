$ErrorActionPreference="Stop"
$vlc="C:\Program Files\VideoLAN\VLC\vlc.exe"
if(!(Test-Path $vlc)){throw "Nie znaleziono VLC."}
if(!(Test-Path "$PSScriptRoot\camera.local.ps1")){throw "Najpierw uruchom setup.ps1"}
. "$PSScriptRoot\camera.local.ps1"
Write-Host "Kamera LIVE v1004" -ForegroundColor Cyan
Write-Host "RTSP/TCP -> MJPEG/HTTP :8091/camera.mjpg" -ForegroundColor Cyan
Write-Host "Nie zamykaj VLC podczas podgladu." -ForegroundColor Yellow
& $vlc --rtsp-tcp --network-caching=700 $CameraUrl --sout "#transcode{vcodec=MJPG,vb=2500,scale=1,acodec=none}:standard{access=http,mux=mpjpeg,dst=:8091/camera.mjpg}" --sout-keep
