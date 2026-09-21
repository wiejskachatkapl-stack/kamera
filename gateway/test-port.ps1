Write-Host "Sprawdzam port 8091..." -ForegroundColor Cyan
$r=Test-NetConnection 127.0.0.1 -Port 8091 -WarningAction SilentlyContinue
if($r.TcpTestSucceeded){
 Write-Host "PORT 8091: DZIALA (TRUE)" -ForegroundColor Green
 Write-Host "Otworz: http://127.0.0.1:8091/camera.webm" -ForegroundColor Green
}else{
 Write-Host "PORT 8091: NIE DZIALA (FALSE)" -ForegroundColor Red
 Write-Host "VLC nie uruchomil wyjscia HTTP." -ForegroundColor Red
}
