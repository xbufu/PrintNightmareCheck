function Get-SpoolerStatus {
    Write-Output "Checking if Print Spooler service is enabled..."
    Write-Output ""
    
    $spoolerService = Get-Service "Print Spooler" -ErrorAction SilentlyContinue
    $spoolerStatus = $spoolerService.Status

    $result = ""

    if (($spoolerStatus -eq "Running") -or ($spoolerStatus -eq "Stopped")) {
        $result = "ENABLED"
    } else {
        $result = "DISABLED"
    }

    Write-Output "Print Spooler service is $($result)!"
    Write-Output ""

    if ($result -eq "ENABLED") {
        Write-Output "System is likely VULNERABLE!"
    } else {
        Write-Output "System is likely NOT VULNERABLE."
    }

    Write-Output ""
}

function Get-PatchStatus {
    Write-Output "Checking if system has security patches applied..."
    Write-Output ""

    $oldestPrinterPatch = 5003635
    $latestPatch = [int](Get-HotFix -Description "Security*" | Sort-Object -Property InstalledOn)[-1].HotFixID.substring(2)

    $isPatched = $false

    if ($latestPatch -ge $oldestPrinterPatch) {
        $isPatched = $true
    }

    Write-Output "Latest security patch: KB$($latestPatch)."
    Write-Output ""

    if (!$isPatched) {
        Write-Output "System is NOT PATCHED and most likely VULENRABLE!"
    } else {
        Write-Output "System is PATCHED but might still be vulnerable."
    }

    Write-Output ""
}

function Test-RegistryValue {
    param (
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]$Path,

        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]$Value
    )

    try {
        Get-ItemProperty -Path $Path | Select-Object -ExpandProperty $Value -ErrorAction Stop | Out-Null
        
        return $true
    } catch {
        return $false
    }
}    

function Get-RegistryStatus {
    Write-Output "Checking registry settings..."
    Write-Output "(NoWarningNoElevationOnInstall and UpdatePromptSettings should either not exist or be set 0.)"
    Write-Output ""

    Write-Output "Checking if registry setting HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint exists..."
    Write-Output ""

    $key = Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint"

    if ($key) {
        Write-Output "Registry setting exists!"
        Write-Output ""
        Write-Output "Checking if registry keys NoWarningNoElevationOnInstall or UpdatePromptSettings exist..."
        Write-Output ""

        $value01Exists = Test-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint" -Value "NoWarningNoElevationOnInstall"
        $value02Exists = Test-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint" -Value "UpdatePromptSettings"

        if ($value01Exists) {
            $value01 = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint" -Name "NoWarningNoElevationOnInstall").NoWarningNoElevationOnInstall

            Write-Output "NoWarningNoElevationOnInstall exists and is set to $($value01)!"
        }

        if ($value02Exists) {
            $value02 = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint" -Name "UpdatePromptSettings").UpdatePromptSettings

            Write-Output "UpdatePromptSettings exists and is set to $($value02)!"
        }

        Write-Output ""

        if (($value01 -eq 1) -or ($value02 -eq 1)) {
            Write-Output "System is likely VULNERABLE!"
        } else {
            Write-Output "System is likely NOT VULNERABLE."
        }
    } else {
        Write-Output "Registry setting does not exist."
        Write-Output ""
        Write-Output "System is likely NOT VULNERABLE."
    }
    Write-Output ""
}

function Invoke-AllChecks {
    Get-SpoolerStatus
    Get-PatchStatus
    Get-RegistryStatus
}
