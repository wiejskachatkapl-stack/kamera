$ErrorActionPreference="Stop"
Add-Type -AssemblyName System.Windows.Forms
Add-Type @"
using System;
using System.Runtime.InteropServices;
public static class Cam1020 {
 [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
 [DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd,int n);
 [DllImport("user32.dll")] public static extern bool SetCursorPos(int X,int Y);
 [DllImport("user32.dll")] public static extern void mouse_event(uint f,uint dx,uint dy,uint data,UIntPtr extra);
}
"@

$calPath=Join-Path $PSScriptRoot "playback-calibration.json"
if(!(Test-Path $calPath)){throw "Brak playback-calibration.json. Najpierw uruchom calibrate-playback.ps1 z v1019."}
$cal=Get-Content $calPath -Raw | ConvertFrom-Json

$p=Get-Process CAM720VmsTools -ErrorAction SilentlyContinue |
   Where-Object {$_.MainWindowTitle -eq "CAM720"} | Select-Object -First 1
if(!$p){throw "Nie znaleziono okna CAM720."}

function Activate-Cam {
 [Cam1020]::ShowWindowAsync($p.MainWindowHandle,9)|Out-Null
 Start-Sleep -Milliseconds 300
 [Cam1020]::SetForegroundWindow($p.MainWindowHandle)|Out-Null
 Start-Sleep -Milliseconds 500
}
function Click-XY([int]$x,[int]$y){
 [Cam1020]::SetCursorPos($x,$y)|Out-Null
 Start-Sleep -Milliseconds 250
 [Cam1020]::mouse_event(0x0002,0,0,0,[UIntPtr]::Zero)
 [Cam1020]::mouse_event(0x0004,0,0,0,[UIntPtr]::Zero)
}

# Korekta po teście v1019: żądane 12:20 dało ok. 12:00.
# Dodajemy 20 minut do położenia wyliczonego z kalibracji.
$pxPerHour=[double]$cal.pixelsPerHour
$targetHours=12.0+20.0/60.0
$correctionHours=20.0/60.0
$targetX=[int][Math]::Round([double]$cal.zeroX + ($targetHours+$correctionHours)*$pxPerHour)
$timelineY=[int][Math]::Round(([double]$cal.zeroY+[double]$cal.twelveY)/2.0)

# Położenie aparatu względem okna z dostarczonego ekranu:
# ok. 17.0% szerokości i 84.5% wysokości.
$winW=[double]$cal.windowRight-[double]$cal.windowLeft
$winH=[double]$cal.windowBottom-[double]$cal.windowTop
$cameraX=[int][Math]::Round([double]$cal.windowLeft+$winW*0.170)
$cameraY=[int][Math]::Round([double]$cal.windowTop+$winH*0.845)

$picDir="C:\Program Files (x86)\CAM720VmsTools\MediaFile\Picture"
if(!(Test-Path $picDir)){New-Item -ItemType Directory -Path $picDir -Force|Out-Null}
$before=@(Get-ChildItem $picDir -Filter *.jpg -File -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName)

Write-Host ""
Write-Host "Kamera Snapshot v1020 - pojedynczy test" -ForegroundColor Cyan
Write-Host "1. Ustawiam Playback w okolicy 12:20." -ForegroundColor Yellow
Activate-Cam
Click-XY $targetX $timelineY

Write-Host "2. Czekam 5 sekund na zaladowanie obrazu..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

Write-Host "3. Naciskam przycisk aparatu." -ForegroundColor Yellow
Activate-Cam
Click-XY $cameraX $cameraY
Start-Sleep -Seconds 3

$after=Get-ChildItem $picDir -Filter *.jpg -File -ErrorAction SilentlyContinue |
       Sort-Object LastWriteTime -Descending
$new=$after | Where-Object {$before -notcontains $_.FullName} | Select-Object -First 1

Write-Host ""
if($new){
 Write-Host "SUKCES - CAM720 utworzyl nowe zdjecie:" -ForegroundColor Green
 Write-Host $new.FullName -ForegroundColor Green
}else{
 Write-Host "Nie wykryto nowego JPG." -ForegroundColor Red
 Write-Host "Sprawdz, czy kursor trafil w ikone aparatu i jaka godzina ustawila sie w obrazie."
}
