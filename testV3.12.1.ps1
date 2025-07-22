# Riced Windows Installer PowerShell Script
# Version 2.7 — Repo-Based Installer Support
# File: install.ps1
# Usage:
#   From PowerShell console:  .\install.ps1
#   Remote install:  iwr https://raw.githubusercontent.com/yourname/project-purple-dreams/main/install.ps1 | iex

# === Configuration Paths ===
$BASE_URL        = 'https://raw.githubusercontent.com/yourname/project-purple-dreams/main/configs'
$INSTALLER_BASE  = 'https://raw.githubusercontent.com/yourname/project-purple-dreams/main/installers'
$GZ_PATH         = "$env:APPDATA\glazewm\config.yaml"
$FL_PATH         = "$env:APPDATA\FlowLauncher\Settings.json"

# === Functions ===
function Show-AsciiArt {
    Clear-Host
    Write-Host '===============================================' -ForegroundColor Magenta
    Write-Host '     RICED WINDOWS INSTALLER v2.7              ' -ForegroundColor Magenta
    Write-Host '===============================================' -ForegroundColor Magenta
    Write-Host
}

function Pause-ForKey {
    Write-Host 'Press Enter to continue...' -ForegroundColor DarkGray
    [void][System.Console]::ReadLine()
}

function Download-File {
    param(
        [string]$Name,
        [string]$Url,
        [string]$Destination
    )
    Show-AsciiArt
    Write-Host "[INFO] Downloading $Name..." -ForegroundColor Cyan
    Write-Host "     $Url" -ForegroundColor DarkGray
    try {
        Invoke-WebRequest -Uri $Url -OutFile $Destination -UseBasicParsing -ErrorAction Stop
        Write-Host "`n[OK] $Name saved to $Destination" -ForegroundColor Green
    } catch {
        Write-Host "`n[ERROR] Failed to download $Name:`n    $($_.Exception.Message)" -ForegroundColor Red
    }
    Pause-ForKey
}

function Download-And-Run-Installer {
    param(
        [string]$Name,
        [string]$Url
    )
    Show-AsciiArt
    Write-Host "[INFO] Downloading installer for $Name..." -ForegroundColor Cyan
    Write-Host "     $Url" -ForegroundColor DarkGray
    $tmp = "$env:TEMP\$Name-installer.exe"
    try {
        Invoke-WebRequest -Uri $Url -OutFile $tmp -UseBasicParsing -ErrorAction Stop
    } catch {
        Write-Host "[ERROR] Could not download installer for $Name:" -ForegroundColor Red
        Write-Host "    $($_.Exception.Message)" -ForegroundColor DarkRed
        Pause-ForKey; return
    }
    Write-Host "[INFO] Running installer for $Name..." -ForegroundColor Cyan
    try {
        Start-Process -FilePath $tmp -ArgumentList '/SILENT','/VERYSILENT','/SUPPRESSMSGBOXES' -Wait
        Write-Host "[OK] $Name installed." -ForegroundColor Green
    } catch {
        Write-Host "[ERROR] Installer for $Name failed:`n    $($_.Exception.Message)" -ForegroundColor Red
    }
    Pause-ForKey
}

function Install-All {
    Download-File -Name 'GlazeWM config'        -Url "$BASE_URL/glaze/config.yaml"           -Destination $GZ_PATH
    Download-File -Name 'FlowLauncher settings' -Url "$BASE_URL/flowlauncher/Settings.json" -Destination $FL_PATH
}

function Remove-All {
    Show-AsciiArt
    Write-Host '[INFO] Removing configurations...' -ForegroundColor Yellow
    foreach ($pair in @{ 'GlazeWM config'=$GZ_PATH; 'FlowLauncher settings'=$FL_PATH }) {
        if (Test-Path $pair.Value) {
            Remove-Item $pair.Value -Force
            Write-Host "[+] Removed $($pair.Key)" -ForegroundColor Green
        } else {
            Write-Host "[-] $($pair.Key) not found" -ForegroundColor Red
        }
    }
    Pause-ForKey
}

function Check-Applications {
    Show-AsciiArt
    Write-Host '[INFO] Checking installed applications...' -ForegroundColor Cyan
    $apps = @(
        @{ Name='GlazeWM';       Path="$env:APPDATA\glazewm";    Installer='GlazeWM.exe' },
        @{ Name='FlowLauncher'; Path="$env:APPDATA\FlowLauncher"; Installer='FlowLauncher.exe' },
        @{ Name='Zebar';         Path="$env:APPDATA\Zebar";       Installer='Zebar.exe' }
    )
    $missing = @()
    foreach ($app in $apps) {
        if (Test-Path $app.Path) {
            Write-Host "[OK] $($app.Name) present" -ForegroundColor Green
        } else {
            Write-Host "[MISSING] $($app.Name) not found" -ForegroundColor Yellow
            $missing += $app
        }
    }
    if ($missing.Count -gt 0) {
        Write-Host
        $resp = Read-Host 'Install missing applications? (Y/N)'
        if ($resp -match '^[Yy]$') {
            foreach ($app in $missing) {
                $url = "$INSTALLER_BASE/$($app.Installer)"
                Download-And-Run-Installer -Name $app.Name -Url $url
            }
        }
    } else {
        Write-Host '[INFO] All applications are present.' -ForegroundColor Green
        Pause-ForKey
    }
}

# === Main Menu Loop ===
while ($true) {
    Show-AsciiArt
    Write-Host '1) Install all configurations'       -ForegroundColor White
    Write-Host '2) Remove all configurations'        -ForegroundColor White
    Write-Host '3) Check/install applications'       -ForegroundColor White
    Write-Host '4) Exit'                             -ForegroundColor White
    $choice = Read-Host 'Select an option'
    switch ($choice) {
        '1' { Install-All; continue }
        '2' { Remove-All; continue }
        '3' { Check-Applications; continue }
        '4' {
            Show-AsciiArt
            Write-Host 'Goodbye!' -ForegroundColor DarkGray
            Start-Sleep -Seconds 1
            return
        }
        default {
            Write-Host 'Invalid choice, try again.' -ForegroundColor Red
            Pause-ForKey
        }
    }
}
