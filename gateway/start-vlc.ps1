$ErrorActionPreference="Stop"
$vlc="C:\Program Files\VideoLAN\VLC\vlc.exe"
if(!(Test-Path "$PSScriptRoot\camera.local.ps1")){throw "Najpierw uruchom .\setup.ps1"}
. "$PSScriptRoot\camera.local.ps1"
$url="rtsp://${CameraUser}:${CameraPass}@192.168.0.3:554/live/ch00_0"
$sout='#duplicate{dst=display,dst="transcode{vcodec=MJPG,vb=2500,scale=1,acodec=none}:standard{access=http,mux=mpjpeg,dst=:8091/camera.mjpg}"}'
Write-Host "v1006: VLC ma pokazac obraz i wystawic http://127.0.0.1:8091/camera.mjpg" -ForegroundColor Green
& $vlc --rtsp-tcp --network-caching=700 $url --sout $sout --sout-keep
