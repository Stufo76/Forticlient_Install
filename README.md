Forticlient GPO Deployment

Overview

This repository contains the Forticlient_install.bat script, designed for deployment via a Group Policy Object (GPO). The GPO copies the required installation files to the target machine and then executes the script to install FortiClient VPN and necessary dependencies.

Required Files

Before setting up the GPO, you need to download the following files and place them in the \<DOMAIN>\SYSVOL\<DOMAIN>\Forticlient_install directory:

Microsoft Visual C++ Redistributable (required for FortiClient to function properly):Download here

FortiClient VPN MSI Installer (requires manual retrieval):Follow this guide to obtain the .msi file.

FortiClient VPN Configuration File (Forticlient_VPN_Config.reg) (to preconfigure VPN settings)

Forticlient_install.bat (this script)

Why Install Visual C++ Redistributable?

FortiClient VPN requires the Microsoft Visual C++ Redistributable to function properly. If this component is missing, FortiClient may not appear in the system tray after installation. More details can be found in this Fortinet article.

How to Generate Forticlient_VPN_Config.reg

If you want to preconfigure VPN settings for all users, you need to export the required registry keys from a machine where the VPN is already configured.

Steps to Export VPN Configuration:

Configure the VPN profile manually on a test machine using FortiClient.

Open Registry Editor (regedit.exe).

Navigate to the following path:

HKEY_LOCAL_MACHINE\SOFTWARE\Fortinet\FortiClient\Sslvpn\Tunnels

Locate the subkey corresponding to your VPN profile (e.g., My-VPN-Profile).

Right-click on the profile key and select Export.

Save the exported file as Forticlient_VPN_Config.reg.

Place the .reg file in the SYSVOL share so it can be copied to target machines via GPO.

GPO Configuration Guide

1. Create a New GPO

Open the Group Policy Management Console (GPMC).

Right-click on the Organizational Unit (OU) where the policy should be applied and select Create a GPO in this domain, and Link it here.

Name the policy, e.g., Forticlient_install, and click OK.

2. Configure File Copy

The GPO should copy the following files from SYSVOL to C:\Temp on the target machine:

VC_redist.x64.exe

FortiClientVPN.msi

Forticlient_VPN_Config.reg

Forticlient_install.bat

Steps to Configure File Copy:

In GPMC, right-click the newly created GPO and select Edit.

Navigate to: Computer Configuration -> Preferences -> Windows Settings -> Files.

Add the following file copy actions:

Action: Replace

Source: \\<DOMAIN>\SYSVOL\<DOMAIN>\Forticlient_install\Forticlient_install.bat

Destination: C:\Temp\Forticlient_install.bat

Repeat these steps for each file listed above.

3. Configure Scheduled Task to Execute the Script

A scheduled task will ensure that Forticlient_install.bat is executed on the target machine.

Steps to Configure the Scheduled Task:

Navigate to Computer Configuration -> Preferences -> Control Panel Settings -> Scheduled Tasks.

Create a New Immediate Task (At least Windows 7).

Configure the task:

Name: Forticlient_install

Security Options: Run as NT AUTHORITY\System with highest privileges.

Trigger: Immediate execution.

Action: Start a program:

Program/Script: C:\Temp\Forticlient_install.bat

Run with highest privileges: Enabled

4. Apply the GPO to Target Computers

Go back to the GPMC.

Ensure the GPO is linked to the correct Organizational Unit (OU) containing the target computers.

Run gpupdate /force on the affected machines to apply the policy immediately.

License

This project is licensed under the GNU General Public License v3.0. See the LICENSE file for more details.

Notes

Ensure that the target computers have the necessary permissions to access the SYSVOL share.

The script will run automatically after the files are copied.

For troubleshooting, check the Event Viewer under Applications and Services Logs -> Microsoft -> Windows -> GroupPolicy.
