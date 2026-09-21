$ErrorActionPreference="Stop"

$id=[Security.Principal.WindowsIdentity]::GetCurrent()
$p=New-Object Security.Principal.WindowsPrincipal($id)
if(-not $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)){
  Write-Host "Uruchom ten plik JEDEN RAZ w PowerShell jako Administrator." -ForegroundColor Yellow
  exit 1
}

$lanIp = Get-NetIPAddress -AddressFamily IPv4 |
  Where-Object {$_.IPAddress -notlike "127.*" -and $_.IPAddress -notlike "169.254.*" -and $_.PrefixOrigin -ne "WellKnown"} |
  Sort-Object InterfaceMetric |
  Select-Object -First 1 -ExpandProperty IPAddress
if(-not $lanIp){throw "Nie znaleziono lokalnego IPv4."}

$url="http://${lanIp}:8090/"
Write-Host "Kamera LIVE v1014 - naprawa dostepu LAN" -ForegroundColor Cyan
Write-Host "Adres: $url" -ForegroundColor Cyan

# Usuń błędną rezerwację z v1013 i dodaj rezerwację dla wszystkich
# uwierzytelnionych użytkowników komputera. Zapora nadal ogranicza dostęp
# do profilu Private + LocalSubnet + TCP 8090.
& netsh http delete urlacl url=$url 2>$null | Out-Null
& netsh http add urlacl url=$url sddl="D:(A;;GX;;;AU)"
if($LASTEXITCODE -ne 0){throw "Nie udalo sie dodac URL ACL."}

$rule="Kamera LIVE TCP 8090"
Get-NetFirewallRule -DisplayName "Kamera LIVE v1013 TCP 8090" -ErrorAction SilentlyContinue | Remove-NetFirewallRule -ErrorAction SilentlyContinue
Get-NetFirewallRule -DisplayName $rule -ErrorAction SilentlyContinue | Remove-NetFirewallRule -ErrorAction SilentlyContinue
New-NetFirewallRule -DisplayName $rule -Direction Inbound -Action Allow -Protocol TCP -LocalPort 8090 -Profile Private -RemoteAddress LocalSubnet | Out-Null

Write-Host ""
Write-Host "GOTOWE v1014." -ForegroundColor Green
Write-Host "URL ACL naprawiony dla zwyklego konta Windows." -ForegroundColor Green
Write-Host "Zapora: tylko TCP 8090, profil Prywatny, LocalSubnet." -ForegroundColor Green
Write-Host "Telefon: $url" -ForegroundColor Green
