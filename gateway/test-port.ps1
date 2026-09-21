Write-Host "Kamera LIVE v1008 - test portu 8091" -ForegroundColor Cyan
$r=Test-NetConnection 127.0.0.1 -Port 8091 -WarningAction SilentlyContinue
Write-Host ""
if($r.TcpTestSucceeded){
    Write-Host "PORT 8091: DZIALA (TRUE)" -ForegroundColor Green
    Write-Host "Etap RTSP -> VLC -> HTTP jest gotowy." -ForegroundColor Green
    Write-Host "Adres: http://127.0.0.1:8091/stream.ts" -ForegroundColor Cyan
}else{
    Write-Host "PORT 8091: NIE DZIALA (FALSE)" -ForegroundColor Red
}
