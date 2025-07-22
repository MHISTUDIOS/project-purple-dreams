# Riced Windows Installer PowerShell Script
# Version 2.2 — Real Download with Progress Bar
# File: install.ps1
# Usage:
#   From PowerShell console:  .\install.ps1
#   Remote install:  iwr https://raw.githubusercontent.com/MHISTUDIOS/project-purple-dreams/main/install.ps1 | iex

# === Configuration Paths ===
$BASE_URL  = 'https://raw.githubusercontent.com/MHISTUDIOS/project-purple-dreams/main/configs'
$GZ_PATH   = "$env:APPDATA\glazewm\config.yaml"
$FL_PATH   = "$env:APPDATA\FlowLauncher\Settings.json"

# === Functions ===
function Show-AsciiArt {
    Clear-Host
    Write-Host '===============================================' -ForegroundColor Magenta
    Write-Host '        RICED WINDOWS INSTALLER v2.2          ' -ForegroundColor Magenta
    Write-Host '===============================================' -ForegroundColor Magenta
    Write-Host
}

function Pause-ForKey {
    Write-Host
    Write-Host 'Press Enter to continue...' -ForegroundColor DarkGray
    [void][System.Console]::ReadLine()
}

function Download-File {
    param(
        [Parameter(Mandatory)] [string]$Name,
        [Parameter(Mandatory)] [string]$Url,
        [Parameter(Mandatory)] [string]$Destination
    )
    Show-AsciiArt
    Write-Host "[INFO] Downloading $($Name):" -ForegroundColor Cyan
    Write-Host "     URL: $Url" -ForegroundColor DarkGray

    # Set up WebClient with progress event
    $wc = [System.Net.WebClient]::new()
    $wc.DownloadProgressChanged += {
        param($sender, $e)
        $pc = $e.ProgressPercentage
        $blocks = [int]($pc / 5)
        $barHash = '#' * $blocks
        $barDot  = '.' * (20 - $blocks)
        Write-Host -NoNewline '['
        Write-Host -NoNewline $barHash -ForegroundColor Magenta
        Write-Host -NoNewline $barDot  -ForegroundColor DarkGray
        Write-Host -NoNewline "] ($($pc)`% / 100%)" -ForegroundColor White
    }
    $done = New-Object System.Threading.AutoResetEvent $false
    $wc.DownloadFileCompleted += { $done.Set() }

    # Start async download and wait
    $wc.DownloadFileAsync($Url, $Destination)
    $done.WaitOne() | Out-Null
    $wc.Dispose()

    Write-Host "`n[OK] $($Name) saved to $Destination" -ForegroundColor Green
    Pause-ForKey
}

function Install-All {
    Download-File -Name 'GlazeWM config'    -Url "$BASE_URL/glaze/config.yaml"     -Destination $GZ_PATH
    Download-File -Name 'FlowLauncher settings' -Url "$BASE_URL/flowlauncher/Settings.json" -Destination $FL_PATH
}

function Remove-All {
    Show-AsciiArt
    Write-Host '[INFO] Removing configurations...' -ForegroundColor Yellow
    if (Test-Path $GZ_PATH) {
        Remove-Item $GZ_PATH -Force
        Write-Host '[+] Removed GlazeWM config' -ForegroundColor Green
    } else {
        Write-Host '[-] GlazeWM config not found' -ForegroundColor Red
    }
    if (Test-Path $FL_PATH) {
        Remove-Item $FL_PATH -Force
        Write-Host '[+] Removed FlowLauncher settings' -ForegroundColor Green
    } else {
        Write-Host '[-] FlowLauncher settings not found' -ForegroundColor Red
    }
    Pause-ForKey
}

# === Main Menu Loop ===
while ($true) {
    Show-AsciiArt
    Write-Host '1) Install all configurations' -ForegroundColor White
    Write-Host '2) Remove all configurations'  -ForegroundColor White
    Write-Host '3) Exit'                       -ForegroundColor White
    $choice = Read-Host 'Select an option'
    switch ($choice) {
        '1' { Install-All }
        '2' { Remove-All }
        '3' { break }
        default {
            Write-Host 'Invalid choice, please try again.' -ForegroundColor Red
            Pause-ForKey
        }
    }
}

Write-Host 'Goodbye!' -ForegroundColor DarkGray
Start-Sleep -Seconds 1
