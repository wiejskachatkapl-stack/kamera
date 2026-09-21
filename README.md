# Kamera LIVE v1001
Pierwsza wersja PWA pod GitHub Pages.

## Uruchomienie
Wgraj zawartość paczki do repozytorium, w GitHub Pages ustaw publikację z gałęzi `main` i katalogu `/root`.

W aplikacji otwórz **Ustawienia**, wybierz typ strumienia i wpisz adres kamery.

### Obsługiwane na start
- HLS (`.m3u8`)
- MJPEG / obraz HTTP
- bezpośredni MP4/WebM

RTSP wymaga bramki RTSP → HLS/WebRTC i nie powinno się publikować loginu/hasła kamery w repozytorium.
