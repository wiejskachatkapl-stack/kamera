$ErrorActionPreference="Stop"
$user=Read-Host "Login kamery (np. admin)"
$sec=Read-Host "Haslo kamery" -AsSecureString
$ptr=[Runtime.InteropServices.Marshal]::SecureStringToBSTR($sec)
try{$pass=[Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr)}finally{[Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr)}
"`$CameraUser='$($user.Replace("'","''"))'`r`n`$CameraPass='$($pass.Replace("'","''"))'" | Set-Content "$PSScriptRoot\camera.local.ps1" -Encoding UTF8
Write-Host "Konfiguracja v1006 gotowa." -ForegroundColor Green
