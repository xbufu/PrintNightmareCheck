# PrintNightmareCheck

This repository contains some manul checks to see if the system is vulnerable to the PrintNightmare vulnerability (CVE-2021-1675, CVE-2021-34527) and also a PowerShell script to automate the process.

Please note that this is the first PowerShell script I have ever written myself so do not rely on it!

## Manual checks

### Check if `Print Spooler` service is running

```powershell
# Using WMIC
wmic service list brief | findstr "Spool"

# Using PowerShell
Get-Service "Print Spooler"
```

### Check latest security patches

```powershell
Get-HotFix -Description "Security*" | Sort-Object -Property InstalledOn
```
