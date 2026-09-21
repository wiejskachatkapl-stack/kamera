$ErrorActionPreference="Stop"

# Must be run as Administrator.
$id=[Security.Principal.WindowsIdentity]::GetCurrent()
$p=New-Object Security.Principal.WindowsPrincipal($id)
if(-not $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)){
    Write-Host "Ten plik uruchom raz jako Administrator." -ForegroundColor Yellow
    Write-Host "Kliknij prawym przyciskiem PowerShell -> Uruchom jako administrator." -ForegroundColor Yellow
    exit 1
}

$lanIp = Get-NetIPAddress -AddressFamily IPv4 |
    Where-Object {
        $_.IPAddress -notlike "127.*" -and
        $_.IPAddress -notlike "169.254.*" -and
        $_.PrefixOrigin -ne "WellKnown"
    } |
    Sort-Object InterfaceMetric |
    Select-Object -First 1 -ExpandProperty IPAddress

if(-not $lanIp){ throw "Nie znaleziono lokalnego adresu IPv4." }

$url="http://${lanIp}:8090/"
Write-Host "Kamera LIVE v1013 - konfiguracja LAN" -ForegroundColor Cyan
Write-Host "Adres: $url" -ForegroundColor Cyan

# URL ACL only for the current Windows user.
$user=[Security.Principal.WindowsIdentity]::GetCurrent().Name
& netsh http delete urlacl url=$url 2>$null | Out-Null
& netsh http add urlacl url=$url user="$user"
if($LASTEXITCODE -ne 0){ throw "Nie udalo sie dodac URL ACL." }

# Narrow firewall rule: TCP 8090, Private profile only, LocalSubnet only.
$rule="Kamera LIVE v1013 TCP 8090"
Get-NetFirewallRule -DisplayName $rule -ErrorAction SilentlyContinue | Remove-NetFirewallRule -ErrorAction SilentlyContinue
New-NetFirewallRule -DisplayName $rule -Direction Inbound -Action Allow -Protocol TCP -LocalPort 8090 -Profile Private -RemoteAddress LocalSubnet | Out-Null

Write-Host ""
Write-Host "GOTOWE." -ForegroundColor Green
Write-Host "Zezwolenie dotyczy tylko TCP 8090, profilu Prywatnego i urzadzen z sieci lokalnej." -ForegroundColor Green
Write-Host "Telefon: $url" -ForegroundColor Green
