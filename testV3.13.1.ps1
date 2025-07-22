# Riced Windows Installer PowerShell Script
# Version 3.5 — Add Zebar Widget Folder Deployment via Archive
# File: install.ps1
# Usage:
#   From PowerShell console:  .\install.ps1
#   Remote install:  iwr https://raw.githubusercontent.com/MHISTUDIOS/project-purple-dreams/main/install.ps1 | iex

# === Configuration Paths ===
$BASE_URL        = 'https://raw.githubusercontent.com/MHISTUDIOS/project-purple-dreams/refs/heads/main/configs'
$REPO_ZIP_URL    = 'https://github.com/MHISTUDIOS/project-purple-dreams/archive/refs/heads/main.zip'
$GZ_PATH         = "$env:USERPROFILE\.glzr\glazewm\config.yaml"
$ZB_CONFIG_PATH  = "$env:USERPROFILE\.glzr\zebar\settings.json"
$ZB_WIDGET_DIR   = "$env:USERPROFILE\.glzr\zebar\overline-zebar"
$WT_PATH         = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
$FL_PATH         = "$env:APPDATA\FlowLauncher\purple_dreams.xaml"

# === Helper Functions ===
function Show-Header {
    Clear-Host
    Write-Host '===============================================' -ForegroundColor Magenta
    Write-Host '     RICED WINDOWS INSTALLER v3.5              ' -ForegroundColor Magenta
    Write-Host '===============================================' -ForegroundColor Magenta
    Write-Host
}
function Pause-ForKey {
    Write-Host; Write-Host 'Press Enter to continue...' -ForegroundColor DarkGray; [void][Console]::ReadLine()
}

# === Program Check ===
function Check-Programs {
    Show-Header
    Write-Host '[INFO] Checking required applications...' -ForegroundColor Cyan
    $checks = @(
        @{Name='GlazeWM'; Path="$env:USERPROFILE\.glzr\glazewm"},
        @{Name='Zebar';   Path="$env:USERPROFILE\.glzr\zebar"},
        @{Name='Windows Terminal'; Path="$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe"},
        @{Name='FlowLauncher'; Path="$env:APPDATA\FlowLauncher"}
    )
    $missing = @()
    foreach ($c in $checks) {
        if (Test-Path $c.Path) {
            Write-Host "[OK]       $($c.Name) found" -ForegroundColor Green
        } else {
            Write-Host "[MISSING]  $($c.Name) not found" -ForegroundColor Yellow
            $missing += $c.Name
        }
    }
    if ($missing.Count -gt 0) {
        Write-Host; Write-Host 'Please install missing applications before deploying configs:' -ForegroundColor Red
        $missing | ForEach-Object { Write-Host "  • $_" -ForegroundColor Red }
        Pause-ForKey; return $false
    }
    Write-Host; Write-Host '[INFO] All required applications are present.' -ForegroundColor Green
    Pause-ForKey; return $true
}

# === Download Single File ===
function Download-File {
    param([string]$Name, [string]$Url, [string]$Dest)
    Show-Header
    Write-Host "[INFO] Deploying $Name..." -ForegroundColor Cyan
    Write-Host "     $Url" -ForegroundColor DarkGray
    try {
        Invoke-WebRequest -Uri $Url -OutFile $Dest -UseBasicParsing -ErrorAction Stop
        Write-Host "[OK] $Name written to $Dest" -ForegroundColor Green
    } catch {
        Write-Host "[ERROR] Failed to deploy $Name" -ForegroundColor Red
        Write-Host "    $($_.Exception.Message)" -ForegroundColor DarkRed
    }
    Pause-ForKey
}

# === Download Zebar Widget Folder via ZIP ===
function Download-ZebarWidget {
    Show-Header
    Write-Host '[INFO] Deploying Zebar widget folder...' -ForegroundColor Cyan
    $zipTemp = "$env:TEMP\project-purple-dreams.zip"
    $extractDir = "$env:TEMP\project-purple-dreams-main"
    # Download repo ZIP
    try { Invoke-WebRequest -Uri $REPO_ZIP_URL -OutFile $zipTemp -UseBasicParsing -ErrorAction Stop } catch {
        Write-Host '[ERROR] Failed to download repository archive' -ForegroundColor Red; Pause-ForKey; return
    }
    # Extract only widget folder
    try {
        Expand-Archive -Path $zipTemp -DestinationPath $extractDir -Force
        $src = Join-Path $extractDir 'project-purple-dreams-main\configs\Zebar\overline-zebar'
        if (Test-Path $src) {
            Copy-Item -Path $src -Destination $ZB_WIDGET_DIR -Recurse -Force
            Write-Host "[OK] Zebar widget folder copied to $ZB_WIDGET_DIR" -ForegroundColor Green
        } else {
            Write-Host '[ERROR] Widget folder not found in archive' -ForegroundColor Red
        }
    } catch {
        Write-Host "[ERROR] Extract/copy failed:`n    $($_.Exception.Message)" -ForegroundColor Red
    }
    # Cleanup
    Remove-Item $zipTemp -Force; Remove-Item $extractDir -Recurse -Force
    Pause-ForKey
}

# === Install Configs & Widgets ===
function Install-Configs {
    if (-not (Check-Programs)) { return }
    # Ensure directories
    New-Item -ItemType Directory -Path (Split-Path $GZ_PATH) -Force | Out-Null
    New-Item -ItemType Directory -Path (Split-Path $ZB_CONFIG_PATH) -Force | Out-Null
    New-Item -ItemType Directory -Path $ZB_WIDGET_DIR -Force | Out-Null
    New-Item -ItemType Directory -Path (Split-Path $WT_PATH) -Force | Out-Null
    New-Item -ItemType Directory -Path (Split-Path $FL_PATH) -Force | Out-Null
    # Deploy
    Download-File -Name 'GlazeWM config'        -Url "$BASE_URL/glazewm/config.yaml"              -Dest $GZ_PATH
    Download-ZebarWidget
    Download-File -Name 'Zebar settings'        -Url "$BASE_URL/zebar/settings.json"            -Dest $ZB_CONFIG_PATH
    Download-File -Name 'Windows Terminal JSON' -Url "$BASE_URL/windowsTerminal/settings.json" -Dest $WT_PATH
    Download-File -Name 'FlowLauncher theme'    -Url "$BASE_URL/flowlauncher/purple_dreams.xaml" -Dest $FL_PATH
}

# === Remove Configs & Widgets ===
function Remove-Configs {
    Show-Header
    Write-Host '[INFO] Removing configurations & widget...' -ForegroundColor Yellow
    $pairs = @{
        'GlazeWM config'             = $GZ_PATH;
        'Zebar settings'             = $ZB_CONFIG_PATH;
        'Windows Terminal settings'  = $WT_PATH;
        'FlowLauncher theme'         = $FL_PATH
    }
    foreach ($key in $pairs.Keys) {
        if (Test-Path $pairs[$key]) { Remove-Item $pairs[$key] -Force; Write-Host "[+] Removed $key" -ForegroundColor Green }
        else { Write-Host "[-] $key not found" -ForegroundColor Red }
    }
    if (Test-Path $ZB_WIDGET_DIR) {
        Remove-Item $ZB_WIDGET_DIR -Recurse -Force
        Write-Host '[+] Removed Zebar widget folder' -ForegroundColor Green
    }
    Pause-ForKey
}

# === Open Documentation ===
function Open-Docs {
    Show-Header; Write-Host '[INFO] Opening documentation...' -ForegroundColor Cyan
    Start-Process 'https://github.com/MHISTUDIOS/project-purple-dreams/'
    Pause-ForKey
}

# === Main Menu ===
while ($true) {
    Show-Header
    Write-Host '1) Install configs + Zebar widget' -ForegroundColor White
    Write-Host '2) Remove configs + widget'      -ForegroundColor White
    Write-Host '3) Check required apps'         -ForegroundColor White
    Write-Host '4) Open documentation'           -ForegroundColor White
    Write-Host '5) Exit'                         -ForegroundColor White
    $choice = Read-Host 'Select an option'
    switch ($choice) {
        '1' { Install-Configs; continue }
        '2' { Remove-Configs; continue }
        '3' { Check-Programs; continue }
        '4' { Open-Docs; continue }
        '5' { Write-Host 'Goodbye!' -ForegroundColor DarkGray; Start-Sleep -Seconds 1; break }
        default { Write-Host 'Invalid choice.' -ForegroundColor Red; Pause-ForKey }
    }
     if ($c -eq '5') { break }
}
