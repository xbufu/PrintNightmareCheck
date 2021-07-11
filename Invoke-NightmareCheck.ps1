function Get-SpoolerStatus {
    $spoolerService = Get-Service "Print Spooler" -ErrorAction SilentlyContinue
    $spoolerStatus = $spoolerService.Status

    $result = ""

    if (($spoolerStatus -eq "Running") -or ($spoolerStatus -eq "Stopped")) {
        $result = "ENABLED"
    } else {
        $result = "DISABLED"
    }

    return $result
}

function Get-PatchStatus {
    $oldestPrinterPatch = 5003635
    $latestPatch = [int](Get-HotFix -Description "Security*" | Sort-Object -Property InstalledOn)[-1].HotFixID.substring(2)

    $patchStatus = $false

    if ($latestPatch -ge $oldestPrinterPatch) {
        $patchStatus = $true
    }

    $results = @()
    $results += $patchStatus
    $results += "KB$latestPatch"

    return $results
}

echo ""
echo "Checking if Print Spooler service is enabled..."
echo ""

$spoolerStatus = Get-SpoolerStatus

if ($spoolerStatus -eq "ENABLED") {
    echo "Print Spooler is ENABLED!"
    echo ""
    echo "Checking if system has security patches applied..."
    echo ""

    $patchStatus = Get-PatchStatus

    if (!$patchStatus[0]) {
        echo "System is NOT PATCHED and most likely VULENRABLE!"
    } else {
        echo "System is PATCHED but might still be vulnerable."
        echo "Latest security patch is $($patchStatus[1])."
    }
} else {
    echo "Print Spooler is disabled!"
    echo "System is likely NOT VULNERABLE."
}
