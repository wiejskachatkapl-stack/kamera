$ErrorActionPreference="Stop"
$vlc="C:\Program Files\VideoLAN\VLC\vlc.exe"
if(!(Test-Path $vlc)){throw "Nie znaleziono VLC: $vlc"}
if(!(Test-Path "$PSScriptRoot\camera.local.ps1")){throw "Najpierw uruchom .\setup.ps1"}
. "$PSScriptRoot\camera.local.ps1"
$url="rtsp://${CameraUser}:${CameraPass}@192.168.0.3:554/live/ch00_0"

# v1007: rezygnujemy z MJPEG/mpjpeg. VLC transkoduje do WebM/VP8 i udostepnia po HTTP.
# Ten format ma natywne wsparcie przegladarkowe i jest wspierany przez VLC jako live HTTP output.
$sout='#duplicate{dst=display,dst="transcode{vcodec=VP80,vb=1800,scale=1,acodec=none}:std{access=http{mime=video/webm},mux=webm,dst=:8091/camera.webm}"}'

Write-Host "Kamera LIVE v1007" -ForegroundColor Cyan
Write-Host "RTSP/TCP -> VLC + WebM/HTTP" -ForegroundColor Cyan
Write-Host "Adres testowy: http://127.0.0.1:8091/camera.webm" -ForegroundColor Green
Write-Host "VLC powinien rownoczesnie pokazywac obraz." -ForegroundColor Yellow
& $vlc --rtsp-tcp --network-caching=700 $url --sout $sout --sout-keep
