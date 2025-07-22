# Riced Windows Installer PowerShell Stub
# Version 1.0

function Show-AsciiArt {
    Clear-Host
    Write-Host "===============================================" -ForegroundColor Magenta
    Write-Host "        RICED WINDOWS INSTALLER v1.0          " -ForegroundColor Magenta
    Write-Host "===============================================" -ForegroundColor Magenta
    Write-Host "   ____                       _                   ____                        " -ForegroundColor Magenta
    Write-Host "  |  _ \ _ __ ___   __ _  ___| |__   _   _      |  _ \ _ __ ___   ___  _ __  " -ForegroundColor Magenta
    Write-Host "  | |_) | '__/ _ \ / _` |/ __| '_ \ | | | |_____| |_) | '_ ` _ \ / _ \| '_ \ " -ForegroundColor Magenta
    Write-Host "  |  __/| | | (_) | (_| | (__| | | || |_| |_____|  __/| | | | | | (_) | | | |" -ForegroundColor Magenta
    Write-Host "  |_|   |_|  \___/ \__,_|\___|_| |_| \__,_|     |_|   |_| |_| |_|\___/|_| |_|" -ForegroundColor Magenta
    Write-Host "                            purple-dream                             " -ForegroundColor Magenta
    Write-Host
}

function Pause {
    Read-Host -Prompt 'Press Enter to continue'
}

function Simulate-Install {
    Write-Host "[INFO] Starting installation..." -ForegroundColor Cyan
    Start-Sleep -Seconds 1
    Write-Host "[*] Downloading GlazeWM config..."
    Start-Sleep -Seconds 1
    Write-Host "[*] Downloading FlowLauncher settings..."
    Start-Sleep -Seconds 1
    Write-Host "[OK] Installation complete." -ForegroundColor Green
    Pause
}

function Simulate-Uninstall {
    Write-Host "[INFO] Removing configurations..." -ForegroundColor Yellow
    Start-Sleep -Seconds 1
    Write-Host "[-] Removing GlazeWM config..."
    Start-Sleep -Seconds 1
    Write-Host "[-] Removing FlowLauncher settings..."
    Start-Sleep -Seconds 1
    Write-Host "[OK] Uninstallation complete." -ForegroundColor Green
    Pause
}

# Main loop
while ($true) {
    Show-AsciiArt
    Write-Host "1) Install all configurations" -ForegroundColor White
    Write-Host "2) Remove all configurations" -ForegroundColor White
    Write-Host "3) Exit" -ForegroundColor White
    $choice = Read-Host 'Select an option'
    switch ($choice) {
        '1' { Simulate-Install }
        '2' { Simulate-Uninstall }
        '3' { break }
        default { Write-Host "Invalid choice, please try again." -ForegroundColor Red; Pause }
    }
}

Write-Host "Goodbye!" -ForegroundColor DarkGray
Start-Sleep -Seconds 1
