# Riced Windows Installer PowerShell Script
# Version 3.1 — Escape Variable References
# File: install.ps1
# Usage:
#   From PowerShell console:  .\install.ps1
#   Remote install:  iwr https://raw.githubusercontent.com/MHISTUDIOS/project-purple-dreams/main/install.ps1 | iex

# === Configuration Paths ===
$BASE_URL       = 'https://raw.githubusercontent.com/MHISTUDIOS/project-purple-dreams/refs/heads/main/configs'
$INSTALLER_BASE = 'https://raw.githubusercontent.com/MHISTUDIOS/project-purple-dreams/refs/heads/main/installers'
$GZ_PATH        = "$env:APPDATA\glazewm\config.yaml"
$FL_PATH        = "$env:APPDATA\FlowLauncher\purple_dreams.xaml"

# === Helper Functions ===
function Show-AsciiArt {
    Clear-Host
    Write-Host '===============================================' -ForegroundColor Magenta
    Write-Host '     RICED WINDOWS INSTALLER v3.1              ' -ForegroundColor Magenta
    Write-Host '===============================================' -ForegroundColor Magenta
    Write-Host
}

function Pause-ForKey {
    Write-Host
    Write-Host 'Press Enter to continue...' -ForegroundColor DarkGray
    [void][System.Console]::ReadLine()
}

# === Download Function ===
function Download-File {
    param([string]$Name, [string]$Url, [string]$Destination)
    Show-AsciiArt
    Write-Host "[INFO] Downloading ${Name}..." -ForegroundColor Cyan
    Write-Host "     ${Url}" -ForegroundColor DarkGray
    try {
        Invoke-WebRequest -Uri $Url -OutFile $Destination -UseBasicParsing -ErrorAction Stop
        Write-Host "`n[OK] ${Name} saved to ${Destination}" -ForegroundColor Green
    } catch {
        Write-Host "`n[ERROR] Failed to download ${Name}:`n    $($_.Exception.Message)" -ForegroundColor Red
    }
    Pause-ForKey
}

# === Installer Launcher ===
function Download-And-Run-Installer {
    param([string]$Name, [string]$InstallerFile)
    Show-AsciiArt
    $url = "${INSTALLER_BASE}/${InstallerFile}"
    Write-Host "[INFO] Downloading installer for ${Name}..." -ForegroundColor Cyan
    Write-Host "     ${url}" -ForegroundColor DarkGray
    $tmp = "$env:TEMP\${InstallerFile}"
    try {
        Invoke-WebRequest -Uri $url -OutFile $tmp -UseBasicParsing -ErrorAction Stop
    } catch {
        Write-Host "[ERROR] Download failed for ${Name}:`n    $($_.Exception.Message)" -ForegroundColor Red
        Pause-ForKey; return
    }
    Write-Host "[INFO] Launching installer for ${Name}..." -ForegroundColor Cyan
    try {
        $ext = [IO.Path]::GetExtension($tmp)
        if ($ext -ieq '.msi') {
            Start-Process msiexec.exe -ArgumentList "/i `"${tmp}`"" -Verb RunAs -Wait
        } else {
            Start-Process -FilePath $tmp -Verb RunAs -Wait
        }
        Write-Host "[OK] ${Name} installer exited." -ForegroundColor Green
    } catch {
        Write-Host "[ERROR] Install failed for ${Name}:`n    $($_.Exception.Message)" -ForegroundColor Red
    }
    Pause-ForKey
}

# === Config Install/Remove ===
function Install-All {
    Download-File -Name 'GlazeWM config'      -Url "${BASE_URL}/glazewm/config.yaml"             -Destination ${GZ_PATH}
    Download-File -Name 'FlowLauncher theme'  -Url "${BASE_URL}/flowlauncher/purple_dreams.xaml" -Destination ${FL_PATH}
}

function Remove-All {
    Show-AsciiArt
    Write-Host '[INFO] Removing configurations...' -ForegroundColor Yellow
    $items = @{ 'GlazeWM config' = ${GZ_PATH}; 'FlowLauncher theme' = ${FL_PATH} }
    foreach ($key in $items.Keys) {
        if (Test-Path $items[$key]) {
            Remove-Item $items[$key] -Force
            Write-Host "[+] Removed ${key}" -ForegroundColor Green
        } else {
            Write-Host "[-] ${key} not found" -ForegroundColor Red
        }
    }
    Pause-ForKey
}

# === Check & Install Applications ===
function Check-Applications {
    Show-AsciiArt
    Write-Host '[INFO] Checking installed applications...' -ForegroundColor Cyan
    $apps = @(
        @{ Name='GlazeWM';     Path="$env:ProgramFiles\GlazeWM\glazewm.exe";        File='glazewm.exe' },
        @{ Name='FlowLauncher'; Path="$env:ProgramFiles\FlowLauncher\FlowLauncher.exe"; File='flowlauncher.exe' },
        @{ Name='Zebar';        Path="$env:ProgramFiles\Zebar\zebar.exe";           File='zebar.msi' }
    )
    $missing = $apps | Where-Object { -not (Test-Path $_.Path) }
    foreach ($app in $apps) {
        $status = if (Test-Path $app.Path) { '[OK]' } else { '[MISSING]' }
        $color  = if (Test-Path $app.Path) { 'Green' } else { 'Yellow' }
        Write-Host "$status  $($app.Name)" -ForegroundColor $color
    }
    if ($missing) {
        $resp = Read-Host 'Install missing apps? (Y/N)'
        if ($resp -match '^[Yy]$') {
            foreach ($app in $missing) {
                Download-And-Run-Installer -Name $app.Name -InstallerFile $app.File
            }
        }
    } else {
        Write-Host '[INFO] All applications present.' -ForegroundColor Green
        Pause-ForKey
    }
}

# === Main Menu ===
while ($true) {
    Show-AsciiArt
    Write-Host '1) Install configurations'       -ForegroundColor White
    Write-Host '2) Remove configurations'        -ForegroundColor White
    Write-Host '3) Check/install applications'   -ForegroundColor White
    Write-Host '4) Exit'                         -ForegroundColor White
    $choice = Read-Host 'Select an option'
    switch ($choice) {
        '1' { Install-All; continue }
        '2' { Remove-All; continue }
        '3' { Check-Applications; continue }
        '4' {
            Write-Host 'Goodbye!' -ForegroundColor DarkGray
            Start-Sleep -Seconds 1
            return
        }
        default {
            Write-Host 'Invalid choice.' -ForegroundColor Red
            Pause-ForKey
        }
    }
}
