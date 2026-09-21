$ErrorActionPreference = "Stop"

Add-Type @"
using System;
using System.Runtime.InteropServices;
public static class Win32PlaybackTest {
    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);

    [DllImport("user32.dll")]
    public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);

    [DllImport("user32.dll")]
    public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);

    [DllImport("user32.dll")]
    public static extern bool SetCursorPos(int X, int Y);

    [DllImport("user32.dll")]
    public static extern void mouse_event(uint dwFlags, uint dx, uint dy, uint dwData, UIntPtr dwExtraInfo);

    public struct RECT {
        public int Left;
        public int Top;
        public int Right;
        public int Bottom;
    }
}
"@

function Click-Relative {
    param(
        [IntPtr]$Handle,
        [double]$XRatio,
        [double]$YRatio
    )

    $rect = New-Object Win32PlaybackTest+RECT
    if (-not [Win32PlaybackTest]::GetWindowRect($Handle, [ref]$rect)) {
        throw "Nie udało się odczytać położenia okna CAM720."
    }

    $width  = $rect.Right - $rect.Left
    $height = $rect.Bottom - $rect.Top

    $x = [int]($rect.Left + ($width * $XRatio))
    $y = [int]($rect.Top  + ($height * $YRatio))

    [Win32PlaybackTest]::SetCursorPos($x, $y) | Out-Null
    Start-Sleep -Milliseconds 250
    [Win32PlaybackTest]::mouse_event(0x0002, 0, 0, 0, [UIntPtr]::Zero)
    [Win32PlaybackTest]::mouse_event(0x0004, 0, 0, 0, [UIntPtr]::Zero)
}

$p = Get-Process CAM720VmsTools -ErrorAction SilentlyContinue |
     Where-Object { $_.MainWindowTitle -eq "CAM720" } |
     Select-Object -First 1

if (-not $p) {
    Write-Host "Nie znaleziono otwartego okna CAM720." -ForegroundColor Red
    Write-Host "Uruchom CAM720 i otwórz Playback -> Card storage."
    exit 1
}

$h = $p.MainWindowHandle
[Win32PlaybackTest]::ShowWindowAsync($h, 9) | Out-Null
Start-Sleep -Milliseconds 400
[Win32PlaybackTest]::SetForegroundWindow($h) | Out-Null
Start-Sleep -Milliseconds 700

$rect = New-Object Win32PlaybackTest+RECT
[Win32PlaybackTest]::GetWindowRect($h, [ref]$rect) | Out-Null

Write-Host ""
Write-Host "Kamera Snapshot - test v1017" -ForegroundColor Cyan
Write-Host "Znaleziono CAM720 (PID $($p.Id))." -ForegroundColor Green
Write-Host "Okno: $($rect.Left),$($rect.Top) - $($rect.Right),$($rect.Bottom)"
Write-Host ""
Write-Host "Za 3 sekundy kursor zostanie ustawiony na osi czasu w miejscu odpowiadającym ok. 12:20." -ForegroundColor Yellow
Write-Host "Ten test NIE naciska przycisku aparatu." -ForegroundColor Yellow
Start-Sleep -Seconds 3

# Na dostarczonym ekranie oś czasu obejmuje 04:00-23:00.
# 12:20 to 8 h 20 min od 04:00, czyli ok. 43.86% szerokości osi.
# Oś zaczyna się ok. 4.5% szerokości okna i kończy ok. 97.2%.
$timelineStart = 0.045
$timelineEnd   = 0.972
$fraction = ((12.0 + 20.0/60.0) - 4.0) / (23.0 - 4.0)
$xRatio = $timelineStart + (($timelineEnd - $timelineStart) * $fraction)

# Oś nagrań znajduje się w dolnej części okna.
$yRatio = 0.915

Click-Relative -Handle $h -XRatio $xRatio -YRatio $yRatio

Write-Host ""
Write-Host "Kliknięcie testowe wykonane." -ForegroundColor Green
Write-Host "Sprawdź w CAM720, na jaką godzinę ustawił się znacznik." -ForegroundColor Cyan
Write-Host "Nic więcej nie zostało wykonane."
