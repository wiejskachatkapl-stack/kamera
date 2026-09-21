# Kamera LIVE v1004

Poprawka v1004: VLC zawsze łączy się z kamerą przez **RTSP over TCP (`--rtsp-tcp`)**.

## Pliki do podmiany względem v1003
- `gateway/start-vlc.ps1`
- `web/index.html`
- `web/style.css`
- `web/app.js`
- `README.md`

## Uruchomienie
1. PowerShell: `Set-ExecutionPolicy -Scope Process Bypass`
2. `cd C:\Kamera\gateway`
3. Jeśli konfiguracji jeszcze nie ma: `.\setup.ps1`
4. `.\start-vlc.ps1`
5. Sprawdź `http://127.0.0.1:8091/camera.mjpg`
6. Drugie okno: `cd C:\Kamera` i `.\start-web.ps1`
7. Otwórz `http://localhost:8090`

Telefon w tym samym Wi-Fi: `http://192.168.0.2:8090`, a jako adres komputera ustaw `192.168.0.2`.
