# Riced Windows Installer PowerShell Script
# Version 2.3 — Simplified Download Stub
# File: install.ps1
# Usage:
#   From PowerShell console:  .\install.ps1
#   Remote install:  iwr https://raw.githubusercontent.com/MHISTUDIOS/project-purple-dreams/main/install.ps1 | iex

# === Configuration Paths ===
$BASE_URL = 'https://raw.githubusercontent.com/MHISTUDIOS/project-purple-dreams/refs/heads/main/configs'
$GZ_PATH  = "$env:APPDATA\glazewm\config.yaml"
$FL_PATH  = "$env:APPDATA\FlowLauncher\Settings.json"

# === Functions ===
function Show-AsciiArt {
    Clear-Host
    Write-Host '===============================================' -ForegroundColor Magenta
    Write-Host '        RICED WINDOWS INSTALLER v2.4          ' -ForegroundColor Magenta
    Write-Host '===============================================' -ForegroundColor Magenta
    Write-Host
}

function Pause-ForKey {
    [void][System.Console]::ReadLine()
}

function Download-File {
    param(
        [Parameter(Mandatory)] [string]$Name,
        [Parameter(Mandatory)] [string]$Url,
        [Parameter(Mandatory)] [string]$Destination
    )
    Show-AsciiArt
    Write-Host "[INFO] Downloading $($Name)..." -ForegroundColor Cyan
    Write-Host "     $Url" -ForegroundColor DarkGray

    try {
        Invoke-WebRequest -Uri $Url -OutFile $Destination -UseBasicParsing -ErrorAction Stop
        Write-Host "`n[OK] $($Name) saved to $Destination" -ForegroundColor Green
    } catch {
        Write-Host "`n[ERROR] Failed to download $($Name):" -ForegroundColor Red
        Write-Host "    $($_.Exception.Message)" -ForegroundColor DarkRed
    }
    Write-Host 'Press Enter to continue...' -ForegroundColor DarkGray
    Pause-ForKey
}

function Install-All {
    Download-File -Name 'GlazeWM config'        -Url "$BASE_URL/glaze/config.yaml"           -Destination $GZ_PATH
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
    Write-Host 'Press Enter to continue...' -ForegroundColor DarkGray
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
        '1' { Install-All; continue }
        '2' { Remove-All; continue }
        '3' {
            Show-AsciiArt
            Write-Host 'Goodbye!' -ForegroundColor DarkGray
            Start-Sleep -Seconds 1
            return
        }
        default {
            Write-Host 'Invalid choice, please try again.' -ForegroundColor Red
            Write-Host 'Press Enter to continue...' -ForegroundColor DarkGray
            Pause-ForKey
        }
    }
}
