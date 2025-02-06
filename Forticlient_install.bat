:: Forticlient Installation Script
:: Author: Diego Pastore
:: This script installs FortiClient VPN, required dependencies,
:: and applies a predefined VPN configuration using a GPO deployment.
:: It logs all operations to C:\Temp\Forticlient_install.log.

:: Disable command echoing
@echo off
:: Enable local environment changes
setlocal enabledelayedexpansion

:: Log the start of the installation process
echo [%date% %time%] Starting installation... > "C:\Temp\Forticlient_install.log"

:: Check if Microsoft Visual C++ Redistributable 2022 is already installed
reg query "HKLM\SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64" /v Installed 2>nul | findstr /C:"0x1" >nul
if %errorlevel% equ 0 (
    echo [%date% %time%] Visual C++ Redistributable 2022 is already installed. Skipping installation. >> "C:\Temp\Forticlient_install.log"
) else (
    echo [%date% %time%] Visual C++ Redistributable 2022 is NOT installed. Proceeding with installation. >> "C:\Temp\Forticlient_install.log"

:: Install Microsoft Visual C++ Redistributable 2022 if not present
    if not exist "C:\Temp\VC_redist.x64.exe" (
        echo [%date% %time%] Error: Installer file not found. Aborting installation. >> "C:\Temp\Forticlient_install.log"
        exit /b 1
    )

    echo [%date% %time%] Installing Visual C++ Redistributable 2022 x64... >> "C:\Temp\Forticlient_install.log"
:: Install Microsoft Visual C++ Redistributable 2022 if not present
    start /b /wait "" "C:\Temp\VC_redist.x64.exe" /install /quiet /norestart
)

set FC_INSTALLED=0
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" /s | findstr /I "FortiClient VPN" >nul 2>&1
if %errorlevel% equ 0 (
    echo [%date% %time%] FortiClient VPN is already installed. Skipping installation. >> "C:\Temp\Forticlient_install.log"
    set FC_INSTALLED=1
) else (
    echo [%date% %time%] FortiClient VPN is NOT installed. Proceeding with installation. >> "C:\Temp\Forticlient_install.log"

:: Install FortiClient VPN if not already installed
    if not exist "C:\Temp\FortiClientVPN.msi" (
        echo [%date% %time%] Error: FortiClientVPN MSI file not found. Aborting installation. >> "C:\Temp\Forticlient_install.log"
        exit /b 1
    )

    echo [%date% %time%] Installing FortiClientVPN MSI package... >> "C:\Temp\Forticlient_install.log"
:: Install FortiClient VPN if not already installed
    start /wait msiexec /i "C:\Temp\FortiClientVPN.msi" /quiet /norestart /le+ "C:\Temp\Forticlient_install.log"

)

reg query "HKLM\SOFTWARE\Fortinet\FortiClient\Sslvpn\Tunnels\MED-VPN-MFA-HQ" >nul 2>&1
if %errorlevel% neq 0 (
    echo [%date% %time%] FortiClient VPN configuration not found. Importing registry settings... >> "C:\Temp\Forticlient_install.log"
    
:: Import the VPN configuration file if not already present
    if exist "C:\Temp\Forticlient_VPN_Config.reg" (
:: Import the VPN configuration file if not already present
        reg import "C:\Temp\Forticlient_VPN_Config.reg" >nul 2>&1
        echo [%date% %time%] FortiClient VPN configuration successfully imported. >> "C:\Temp\Forticlient_install.log"
    ) else (
        echo [%date% %time%] Error: Registry file not found. Aborting configuration. >> "C:\Temp\Forticlient_install.log"
        exit /b 1
    )
) else (
    echo [%date% %time%] FortiClient VPN configuration already exists. Skipping registry import. >> "C:\Temp\Forticlient_install.log"
)

:: Log the completion of the process
echo [%date% %time%] Process completed successfully. >> "C:\Temp\Forticlient_install.log"

endlocal
exit /b 0
