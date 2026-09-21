$ErrorActionPreference="Stop"

$vlc="C:\Program Files\VideoLAN\VLC\vlc.exe"
if(!(Test-Path $vlc)){throw "Nie znaleziono VLC: $vlc"}
if(!(Test-Path "$PSScriptRoot\camera.local.ps1")){throw "Brak camera.local.ps1. Uruchom .\setup.ps1"}

. "$PSScriptRoot\camera.local.ps1"
$url="rtsp://${CameraUser}:${CameraPass}@192.168.0.3:554/live/ch00_0"

Write-Host ""
Write-Host "Kamera LIVE v1008" -ForegroundColor Cyan
Write-Host "Uruchamiam sprawdzony RTSP/TCP i proste HTTP/MPEG-TS bez transkodowania." -ForegroundColor Cyan
Write-Host "VLC: obraz lokalny" -ForegroundColor Green
Write-Host "HTTP: http://127.0.0.1:8091/stream.ts" -ForegroundColor Green
Write-Host ""

# Kluczowa poprawka v1008:
# :sout jest opcja konkretnego medium i stoi PO adresie wejściowym.
# Nie transkodujemy H.264 - tylko kopiujemy go do kontenera MPEG-TS.
$sout=':sout=#duplicate{dst=display,dst=http{mux=ts,dst=:8091/stream.ts}}'

& $vlc --rtsp-tcp --network-caching=700 $url $sout ':no-sout-all' ':sout-keep'
