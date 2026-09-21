# Kamera LIVE v1005

Wersja porządkująca projekt przesłany w `kamera-main.zip`.

## Podmień / dodaj
- `gateway/setup.ps1`
- `gateway/start-vlc.ps1`
- `start-web.ps1`
- `web/index.html`
- `web/style.css`
- `web/app.js`
- `.gitignore`

## Usuń stare MediaMTX
- `gateway/download-mediamtx.ps1`
- `gateway/mediamtx.template.yml`
- `gateway/start-gateway.ps1`
- `gateway/mediamtx.local.yml` jeśli istnieje

## Pierwsze uruchomienie po v1005
PowerShell:
`Set-ExecutionPolicy -Scope Process Bypass`
`cd C:\Kamera\gateway`
`.\setup.ps1`
`.\start-vlc.ps1`

Test strumienia:
`http://127.0.0.1:8091/camera.mjpg`

Drugie okno PowerShell:
`Set-ExecutionPolicy -Scope Process Bypass`
`cd C:\Kamera`
`.\start-web.ps1`

Aplikacja:
`http://localhost:8090`

Kamera: 192.168.0.3
RTSP: /live/ch00_0
Transport wymagany przez tę kamerę: RTSP/TCP.
