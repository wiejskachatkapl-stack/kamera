$ErrorActionPreference = "Stop"

Add-Type @"
using System;
using System.Runtime.InteropServices;
public static class Cam720Click {
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
    [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);
    [DllImport("user32.dll")] public static extern bool SetCursorPos(int X, int Y);
    [DllImport("user32.dll")] public static extern void mouse_event(uint f, uint dx, uint dy, uint data, UIntPtr extra);
    public struct RECT { public int Left, Top, Right, Bottom; }
}
"@

$p = Get-Process CAM720VmsTools -ErrorAction SilentlyContinue |
     Where-Object { $_.MainWindowTitle -eq "CAM720" } |
     Select-Object -First 1
if (-not $p) { throw "Nie znaleziono okna CAM720." }

$h = $p.MainWindowHandle
[Cam720Click]::ShowWindowAsync($h, 9) | Out-Null
Start-Sleep -Milliseconds 300
[Cam720Click]::SetForegroundWindow($h) | Out-Null
Start-Sleep -Milliseconds 700

$r = New-Object Cam720Click+RECT
if (-not [Cam720Click]::GetWindowRect($h,[ref]$r)) { throw "Nie można odczytać rozmiaru okna." }

$w = $r.Right-$r.Left
$hh = $r.Bottom-$r.Top

# Kalibracja z ekranu użytkownika:
# początek skali 00:00 = ok. 6.55% szerokości okna
# 20:00 = ok. 97.35% szerokości okna
# cel 12:20 = 12.333333 h
$left = 0.0655
$right = 0.9735
$f = (12.0 + 20.0/60.0) / 20.0
$xRatio = $left + (($right-$left) * $f)

# Klikamy w górną część kolorowego paska nagrania.
$yRatio = 0.895

$x = [int]($r.Left + $w*$xRatio)
$y = [int]($r.Top + $hh*$yRatio)

Write-Host ""
Write-Host "Kamera Snapshot - kalibracja v1018" -ForegroundColor Cyan
Write-Host "CAM720 PID: $($p.Id)" -ForegroundColor Green
Write-Host "Cel testu: 12:20" -ForegroundColor Yellow
Write-Host "Klikam punkt: X=$x Y=$y" -ForegroundColor DarkGray
Write-Host "UWAGA: przed testem skala osi musi wyglądać jak na screenie: 00:00 po lewej i 20:00 po prawej." -ForegroundColor Yellow
Start-Sleep -Seconds 3

[Cam720Click]::SetCursorPos($x,$y) | Out-Null
Start-Sleep -Milliseconds 250
[Cam720Click]::mouse_event(0x0002,0,0,0,[UIntPtr]::Zero)
[Cam720Click]::mouse_event(0x0004,0,0,0,[UIntPtr]::Zero)

Write-Host ""
Write-Host "Gotowe. Odczytaj godzinę wyświetloną w lewym górnym rogu obrazu CAM720." -ForegroundColor Green
Write-Host "Przycisk aparatu NIE został naciśnięty."
