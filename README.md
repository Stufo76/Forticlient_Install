# Forticlient GPO Deployment

## Overview

This repository contains the **Forticlient_install.bat** script, designed for deployment via a Group Policy Object (GPO). The GPO copies the required installation files to the target machine and then executes the script to install FortiClient VPN and necessary dependencies.

## Required Files

Before setting up the GPO, you need to download the following files and place them in the `\<DOMAIN>\SYSVOL\<DOMAIN>\Forticlient_install` directory:

- **Microsoft Visual C++ Redistributable** (required for FortiClient to function properly):  
  [Download here](https://aka.ms/vs/17/release/vc_redist.x64.exe)
- **FortiClient VPN MSI Installer** (requires manual retrieval):  
  Follow [this guide](https://www.reddit.com/r/fortinet/comments/rfzq8c/msi_file_for_forticlient_vpn/) to obtain the `.msi` file.
- **FortiClient VPN Configuration File (`Forticlient_VPN_Config.reg`)** (to preconfigure VPN settings)
- **Forticlient_install.bat** (this script)

### Why Install Visual C++ Redistributable?
FortiClient VPN requires the **Microsoft Visual C++ Redistributable** to function properly. If this component is missing, FortiClient may not appear in the system tray after installation. More details can be found in [this Fortinet article](https://community.fortinet.com/t5/FortiClient/Technical-Tip-FortiClient-not-appearing-in-system-tray-on/ta-p/344280).

## How to Generate `Forticlient_VPN_Config.reg`
If you want to preconfigure VPN settings for all users, you need to export the required registry keys from a machine where the VPN is already configured.

### Steps to Export VPN Configuration:
1. Configure the VPN profile manually on a test machine using FortiClient.
2. Open **Registry Editor** (`regedit.exe`).
3. Navigate to the following path:
   ```
   HKEY_LOCAL_MACHINE\SOFTWARE\Fortinet\FortiClient\Sslvpn\Tunnels
   ```
4. Locate the subkey corresponding to your VPN profile (e.g., `My-VPN-Profile`).
5. Right-click on the profile key and select **Export**.
6. Save the exported file as `Forticlient_VPN_Config.reg`.
7. Place the `.reg` file in the SYSVOL share so it can be copied to target machines via GPO.

## GPO Configuration Guide

### 1. Create a New GPO

1. Open the **Group Policy Management Console** (GPMC).
2. Right-click on the **Organizational Unit (OU)** where the policy should be applied and select **Create a GPO in this domain, and Link it here**.
3. Name the policy, e.g., **Forticlient_install**, and click **OK**.

### 2. Configure File Copy

The GPO should copy the following files from SYSVOL to `C:\Temp` on the target machine:

- `VC_redist.x64.exe`
- `FortiClientVPN.msi`
- `Forticlient_VPN_Config.reg`
- `Forticlient_install.bat`

#### Steps to Configure File Copy:

1. In GPMC, right-click the newly created GPO and select **Edit**.
2. Navigate to: `Computer Configuration -> Preferences -> Windows Settings -> Files`.
3. Add the following file copy actions:
   - **Action:** Replace
   - **Source:** `\\<DOMAIN>\SYSVOL\<DOMAIN>\Forticlient_install\Forticlient_install.bat`
   - **Destination:** `C:\Temp\Forticlient_install.bat`

Repeat these steps for each file listed above.

### 3. Configure Scheduled Task to Execute the Script

A scheduled task will ensure that `Forticlient_install.bat` is executed on the target machine.

#### Steps to Configure the Scheduled Task:

1. Navigate to `Computer Configuration -> Preferences -> Control Panel Settings -> Scheduled Tasks`.
2. Create a **New Immediate Task (At least Windows 7)**.
3. Configure the task:
   - **Name:** `Forticlient_install`
   - **Security Options:** Run as `NT AUTHORITY\SYSTEM` with highest privileges.
   - **Trigger:** Immediate execution.
   - **Action:** Start a program:
     - **Program/Script:** `C:\Temp\Forticlient_install.bat`
     - **Run with highest privileges:** Enabled

### 4. Apply the GPO to Target Computers

1. Go back to the GPMC.
2. Ensure the GPO is linked to the correct **Organizational Unit (OU)** containing the target computers.
3. Run `gpupdate /force` on the affected machines to apply the policy immediately.

## License

This project is licensed under the **GNU General Public License v3.0**. See the `LICENSE` file for more details.

## Notes

- Ensure that the target computers have the necessary permissions to access the SYSVOL share.
- The script will run automatically after the files are copied.
- For troubleshooting, check the **Event Viewer** under `Applications and Services Logs -> Microsoft -> Windows -> GroupPolicy`.
