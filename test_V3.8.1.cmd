@echo off
title Riced Windows Installer v1.0

:: Configuration
setlocal ENABLEDELAYEDEXPANSION

echo Checking environment...

:: Configuration paths
set "BASE_URL=https://raw.githubusercontent.com/x/windows-rice/main/configs"
set "GZ_PATH=%APPDATA%\glazewm\config.yaml"
set "FL_PATH=%APPDATA%\FlowLauncher\Settings.json"

:: Check for curl
where curl >nul 2>&1
if errorlevel 1 (
    echo [ERROR] curl not found. Please install curl or update Windows.
    pause
    exit /b
)

:: Retrieve ESC for ANSI sequences
for /f %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"

:: Go to main menu
goto menu

:ascii_art
cls
echo %ESC%[35m===============================================%ESC%[0m
echo %ESC%[35m        RICED WINDOWS INSTALLER v1.0        %ESC%[0m
echo %ESC%[35m===============================================%ESC%[0m
echo.
exit /b

:menu
call :ascii_art
echo %ESC%[96m1.%ESC%[0m Install all configurations
echo %ESC%[96m2.%ESC%[0m Remove all configurations
echo %ESC%[96m3.%ESC%[0m Exit

echo.
set /p choice=%ESC%[93mSelect an option: %ESC%[0m

if "%choice%"=="1" goto install
if "%choice%"=="2" goto uninstall
if "%choice%"=="3" goto exit
goto menu

:install
cls
call :ascii_art
echo %ESC%[92m[INFO]%ESC%[0m Starting installation...
timeout /t 1 >nul

echo %ESC%[94m[*]%ESC%[0m Downloading GlazeWM config...
echo     URL: %BASE_URL%/glaze/config.yaml
curl -# -L "%BASE_URL%/glaze/config.yaml" -o "%GZ_PATH%"

echo %ESC%[94m[*]%ESC%[0m Downloading FlowLauncher settings...
echo     URL: %BASE_URL%/flowlauncher/Settings.json
curl -# -L "%BASE_URL%/flowlauncher/Settings.json" -o "%FL_PATH%"

echo.
echo %ESC%[92m[OK]%ESC%[0m Installation complete.
pause
goto menu

:uninstall
cls
call :ascii_art
echo %ESC%[93m[INFO]%ESC%[0m Removing configurations...
timeout /t 1 >nul

if exist "%GZ_PATH%" (
    del "%GZ_PATH%" >nul
    echo %ESC%[92m[+]%ESC%[0m Deleted: GlazeWM config
) else (
    echo %ESC%[91m[-]%ESC%[0m Not found: GlazeWM config
)

if exist "%FL_PATH%" (
    del "%FL_PATH%" >nul
    echo %ESC%[92m[+]%ESC%[0m Deleted: FlowLauncher settings
) else (
    echo %ESC%[91m[-]%ESC%[0m Not found: FlowLauncher settings
)

echo.
echo %ESC%[92m[OK]%ESC%[0m Uninstallation complete.
pause
goto menu

:exit
cls
echo %ESC%[90mGoodbye!%ESC%[0m
timeout /t 1 >nul
exit /b
