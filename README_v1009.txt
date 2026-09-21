KAMERA LIVE v1009

Cel: odtwarzanie działającego HTTP MPEG-TS/H.264 z VLC bezpośrednio w interfejsie WWW.

PODMIEŃ:
web/index.html
web/style.css
web/app.js
start-web.ps1

DODAJ:
gateway/web-server.py
web/vendor/mpegts.js (jeśli znajduje się w paczce)

NIE RUSZAJ działającego:
gateway/start-vlc.ps1 z v1008
gateway/setup.ps1
gateway/test-camera.ps1
gateway/camera.local.ps1

URUCHOMIENIE:
OKNO 1:
Set-ExecutionPolicy -Scope Process Bypass
cd C:\Kamera\gateway
.\start-vlc.ps1
VLC ma pokazać obraz.

OKNO 2:
Set-ExecutionPolicy -Scope Process Bypass
cd C:\Kamera
.\start-web.ps1

Następnie otwórz:
http://127.0.0.1:8090

v1009 używa mpegts.js do odtwarzania H.264/MPEG-TS przez Media Source Extensions.
Lokalny serwer na 8090 ma również proxy /stream.ts, aby uniknąć problemów CORS.
