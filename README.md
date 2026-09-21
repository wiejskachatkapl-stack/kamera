# Kamera LIVE v1002

Wersja testowa dla kamery Cam720:
- kamera: `192.168.0.3`
- RTSP: `/live/ch00_0`
- MediaMTX zamienia RTSP na HLS dla przeglądarki.
- login i hasło są wpisywane lokalnie przez `setup.ps1`; `mediamtx.local.yml` jest ignorowany przez Git.

## Windows — uruchomienie
1. `gateway\download-mediamtx.ps1`
2. `gateway\setup.ps1`
3. `gateway\start-gateway.ps1`
4. W drugim PowerShell: `start-web.ps1`
5. Otwórz `http://localhost:8090`

Jeśli PowerShell blokuje skrypty, uruchom jednorazowo w danym oknie:
`Set-ExecutionPolicy -Scope Process Bypass`

## Telefon w tym samym Wi‑Fi
Komputer i telefon muszą być w tej samej sieci. Uruchom stronę z komputera pod jego adresem LAN:
`http://ADRES_IP_KOMPUTERA:8090`
W aplikacji → „Adres bramki” wpisz:
`http://ADRES_IP_KOMPUTERA:8888`

Nie publikuj `mediamtx.local.yml` — zawiera lokalne dane dostępowe kamery.

## GitHub Pages
Repozytorium może być trzymane na GitHubie, ale sam GitHub Pages (HTTPS) nie może bezpośrednio pobierać lokalnego HTTP/HLS z domu. Dostęp spoza Wi‑Fi zrobimy w następnym etapie przez bezpieczny HTTPS/VPN/tunel.
