$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Windows.Forms

Add-Type @"
using System;
using System.Runtime.InteropServices;

public static class Cam720Cal {
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
    [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);
    [DllImport("user32.dll")] public static extern bool SetCursorPos(int X, int Y);
    [DllImport("user32.dll")] public static extern void mouse_event(uint f, uint dx, uint dy, uint data, UIntPtr extra);
    public struct RECT { public int Left, Top, Right, Bottom; }
}
"@

function Get-CamProcess {
    $p = Get-Process CAM720VmsTools -ErrorAction SilentlyContinue |
        Where-Object { $_.MainWindowTitle -eq "CAM720" } |
        Select-Object -First 1
    if (-not $p) { throw "Nie znaleziono okna CAM720. Otworz Playback -> Card storage." }
    return $p
}

function Activate-Cam([System.Diagnostics.Process]$p) {
    [Cam720Cal]::ShowWindowAsync($p.MainWindowHandle, 9) | Out-Null
    Start-Sleep -Milliseconds 250
    [Cam720Cal]::SetForegroundWindow($p.MainWindowHandle) | Out-Null
    Start-Sleep -Milliseconds 400
}

function Wait-Enter([string]$Message) {
    Write-Host ""
    Write-Host $Message -ForegroundColor Yellow
    [void](Read-Host "Ustaw kursor i nacisnij ENTER (nie klikaj mysza)")
    $pos = [System.Windows.Forms.Cursor]::Position
    return $pos
}

$p = Get-CamProcess
Activate-Cam $p

$r = New-Object Cam720Cal+RECT
if (-not [Cam720Cal]::GetWindowRect($p.MainWindowHandle,[ref]$r)) {
    throw "Nie mozna odczytac rozmiaru okna CAM720."
}

Write-Host ""
Write-Host "Kamera Snapshot - kalibrator v1019" -ForegroundColor Cyan
Write-Host "CAM720 PID: $($p.Id)" -ForegroundColor Green
Write-Host ""
Write-Host "WAŻNE:" -ForegroundColor Yellow
Write-Host "1. Playback -> Card storage ma byc otwarty."
Write-Host "2. Nie zmieniaj rozmiaru okna podczas kalibracji."
Write-Host "3. Wskazujemy pozycje na osi czasu, ale NIE klikamy mysza."
Write-Host ""

$zero = Wait-Enter "KROK 1/2: ustaw kursor DOKLADNIE na kresce/pozycji 00:00 na osi czasu."
$twelve = Wait-Enter "KROK 2/2: ustaw kursor DOKLADNIE na kresce/pozycji 12:00 na osi czasu."

if ($twelve.X -le $zero.X) {
    throw "Punkt 12:00 musi znajdowac sie na prawo od punktu 00:00."
}

$pxPerHour = ($twelve.X - $zero.X) / 12.0
$targetX = [int][Math]::Round($zero.X + (12.0 + 20.0/60.0) * $pxPerHour)
$targetY = [int][Math]::Round(($zero.Y + $twelve.Y) / 2.0)

$config = [ordered]@{
    version = 1019
    windowLeft = $r.Left
    windowTop = $r.Top
    windowRight = $r.Right
    windowBottom = $r.Bottom
    zeroX = $zero.X
    zeroY = $zero.Y
    twelveX = $twelve.X
    twelveY = $twelve.Y
    pixelsPerHour = [Math]::Round($pxPerHour, 6)
}
$configPath = Join-Path $PSScriptRoot "playback-calibration.json"
$config | ConvertTo-Json | Set-Content -Path $configPath -Encoding UTF8

Write-Host ""
Write-Host "Kalibracja zapisana:" -ForegroundColor Green
Write-Host $configPath
Write-Host "00:00 = X=$($zero.X) Y=$($zero.Y)"
Write-Host "12:00 = X=$($twelve.X) Y=$($twelve.Y)"
Write-Host "Pikseli/godzine = $([Math]::Round($pxPerHour,3))"
Write-Host ""
Write-Host "Za 3 sekundy wykonam JEDNO klikniecie testowe dla 12:20." -ForegroundColor Cyan
Write-Host "Aparat NIE bedzie naciskany." -ForegroundColor Yellow
Start-Sleep -Seconds 3

Activate-Cam $p
[Cam720Cal]::SetCursorPos($targetX,$targetY) | Out-Null
Start-Sleep -Milliseconds 250
[Cam720Cal]::mouse_event(0x0002,0,0,0,[UIntPtr]::Zero)
[Cam720Cal]::mouse_event(0x0004,0,0,0,[UIntPtr]::Zero)

Write-Host ""
Write-Host "Gotowe. Sprawdz czas w lewym gornym rogu obrazu CAM720." -ForegroundColor Green
Write-Host "Cel: 12:20."
