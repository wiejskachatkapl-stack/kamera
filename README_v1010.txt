KAMERA LIVE v1010 — BEZ PYTHONA

PODMIEŃ:
web/index.html
web/style.css
web/app.js
start-web.ps1

DODAJ:
gateway/web-server.ps1

NIE RUSZAJ:
gateway/start-vlc.ps1 z v1008
gateway/camera.local.ps1
gateway/setup.ps1
gateway/test-camera.ps1

URUCHOMIENIE:
OKNO 1:
Set-ExecutionPolicy -Scope Process Bypass
cd C:\Kamera\gateway
.\start-vlc.ps1

OKNO 2:
Set-ExecutionPolicy -Scope Process Bypass
cd C:\Kamera
.\start-web.ps1

Potem:
http://127.0.0.1:8090

v1010 używa wbudowanego w Windows PowerShell/.NET HttpListener zamiast Pythona.
Serwer 8090 udostępnia stronę i proxy /stream.ts na tym samym adresie.
