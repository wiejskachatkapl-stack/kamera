$ErrorActionPreference = "Stop"

Add-Type -AssemblyName UIAutomationClient
Add-Type -AssemblyName UIAutomationTypes

$p = Get-Process CAM720VmsTools -ErrorAction SilentlyContinue |
    Where-Object { $_.MainWindowTitle -eq "CAM720" } |
    Select-Object -First 1

if (-not $p) {
    throw "Nie znaleziono otwartego okna CAM720."
}

$root = [System.Windows.Automation.AutomationElement]::FromHandle($p.MainWindowHandle)
if (-not $root) {
    throw "Nie udało sie pobrac drzewa UI Automation dla CAM720."
}

$outFile = Join-Path $PSScriptRoot "cam720-ui-tree.txt"
$lines = New-Object System.Collections.Generic.List[string]

function Safe([scriptblock]$Code) {
    try { return (& $Code) } catch { return "" }
}

function Walk-UI {
    param(
        [System.Windows.Automation.AutomationElement]$Element,
        [int]$Depth = 0
    )

    if ($Depth -gt 12) { return }

    $name = Safe { $Element.Current.Name }
    $aid  = Safe { $Element.Current.AutomationId }
    $cls  = Safe { $Element.Current.ClassName }
    $type = Safe { $Element.Current.ControlType.ProgrammaticName }
    $enabled = Safe { $Element.Current.IsEnabled }
    $offscreen = Safe { $Element.Current.IsOffscreen }
    $rect = Safe { $Element.Current.BoundingRectangle }

    $indent = ("  " * $Depth)
    $line = "$indent TYPE=[$type] NAME=[$name] ID=[$aid] CLASS=[$cls] ENABLED=[$enabled] OFFSCREEN=[$offscreen] RECT=[$rect]"
    $lines.Add($line)

    $walker = [System.Windows.Automation.TreeWalker]::RawViewWalker
    $child = $walker.GetFirstChild($Element)

    while ($child) {
        Walk-UI -Element $child -Depth ($Depth + 1)
        $child = $walker.GetNextSibling($child)
    }
}

Write-Host ""
Write-Host "Kamera Snapshot v1021 - diagnostyka UI Automation" -ForegroundColor Cyan
Write-Host "CAM720 PID: $($p.Id)" -ForegroundColor Green
Write-Host "Odczytuje strukture okna. Nic nie bedzie klikane." -ForegroundColor Yellow

Walk-UI -Element $root

$lines | Set-Content -Path $outFile -Encoding UTF8

Write-Host ""
Write-Host "GOTOWE." -ForegroundColor Green
Write-Host "Zapisano:" -ForegroundColor Cyan
Write-Host $outFile
Write-Host ""
Write-Host "Przeslij mi plik cam720-ui-tree.txt."
