#   This Source Code Form is subject to the terms of the Mozilla Public
#   License, v. 2.0. If a copy of the MPL was not distributed with this
#   file, You can obtain one at https://mozilla.org/MPL/2.0/.

<#
.SYNOPSIS
    Changes the MAC address of the Radmin VPN virtual network adapter.
.DESCRIPTION
    This script changes the MAC address of the Radmin VPN virtual network adapter by generating a random MAC address,
    stopping related processes, disabling the adapter, writing the new MAC address to the correct registry subkey,
    and re-enabling the adapter. It uses PsExec to run the core operations with SYSTEM privileges to ensure sufficient
    permissions. The script must be run as Administrator.
#>

# Check administrator privileges
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Please run this script as Administrator!"
    Read-Host "Press Enter to exit..."
    exit 1
}

# Locate PsExec
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$psexec = if (Get-Command psexec.exe -ErrorAction SilentlyContinue) {
    "psexec.exe"
} elseif (Test-Path "$scriptDir\PsExec.exe") {
    "$scriptDir\PsExec.exe"
} else {
    Write-Host "ERROR: Psexec not found. Please run download-psexec.bat."
    Read-Host "Press Enter to exit..."
    exit 1
}

# Generate random MAC address
function Generate-RandomMac {
    $macBytes = New-Object byte[] 6
    $macBytes[0] = 0x02
    $macBytes[1] = Get-Random -InputObject @(0x02, 0x06, 0x0A, 0x0E)
    for ($i = 2; $i -lt 6; $i++) {
        $macBytes[$i] = Get-Random -Minimum 0 -Maximum 256
    }
    ($macBytes | ForEach-Object { $_.ToString("X2") }) -join ":"
}

# Find Radmin VPN adapter and registry subkey (can be done without SYSTEM)
Write-Host "Searching for Radmin VPN adapter..."
$adapter = Get-NetAdapter | Where-Object { 
    $_.Name -like "*Radmin*" -or $_.InterfaceDescription -like "*Radmin*" 
} | Select-Object -First 1

if (-not $adapter) {
    Write-Host "ERROR: Radmin VPN adapter not found."
    Read-Host "Press Enter to exit..."
    exit 1
}
$adapterName = $adapter.Name
Write-Host "Adapter found: $adapterName"

# Display current MAC address and ask for action
$currentMac = $adapter.MacAddress
Write-Host "Current MAC address: $currentMac"
Write-Host ""
Write-Host "Choose an option:"
Write-Host "1. Generate random MAC address"
Write-Host "2. Specify custom MAC address"
Write-Host "3. Cancel"
$choice = Read-Host "Enter your choice (1/2/3)"

switch ($choice) {
    "1" {
        $newMac = Generate-RandomMac
    }
    "2" {
        $valid = $false
        while (-not $valid) {
            $userInput = Read-Host "Enter MAC address (format: XX:XX:XX:XX:XX:XX or XXXXXXXXXXXX)"
            if ($userInput -match '^(?:[0-9A-Fa-f]{2}[:-]?){5}[0-9A-Fa-f]{2}$' -or $userInput -match '^[0-9A-Fa-f]{12}$') {
                # Normalize to colon-separated uppercase
                $cleanMac = $userInput -replace '[^0-9A-Fa-f]', ''
                if ($cleanMac.Length -eq 12) {
                    $newMac = ($cleanMac -split '(..)' | Where-Object { $_ } | ForEach-Object { $_.ToUpper() }) -join ':'
                    $valid = $true
                }
            }
            if (-not $valid) {
                Write-Host "Invalid MAC address format. Please try again."
            }
        }
    }
    "3" {
        Write-Host "Operation cancelled by user."
        exit 0
    }
    default {
        Write-Host "Invalid choice. Exiting."
        exit 1
    }
}
$newMacHex = $newMac -replace ":", ""
Write-Host "New MAC address will be: $newMac"

# Locate correct registry subkey for the adapter
$classPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002BE10318}"
$subkeys = Get-ChildItem -Path $classPath -ErrorAction SilentlyContinue
$targetSubkey = $null

foreach ($subkey in $subkeys) {
    $driverDesc = (Get-ItemProperty -Path $subkey.PSPath -Name "DriverDesc" -ErrorAction SilentlyContinue).DriverDesc
    if ($driverDesc -like "*Radmin*") {
        $targetSubkey = $subkey.PSPath
        break
    }
    $netCfgId = (Get-ItemProperty -Path $subkey.PSPath -Name "NetCfgInstanceId" -ErrorAction SilentlyContinue).NetCfgInstanceId
    if ($netCfgId -and $adapter.InterfaceGuid -and ($netCfgId -eq $adapter.InterfaceGuid.ToString())) {
        $targetSubkey = $subkey.PSPath
        break
    }
}

if (-not $targetSubkey) {
    Write-Host "ERROR: Could not find registry subkey for adapter."
    Read-Host "Press Enter to exit..."
    exit 1
}
Write-Host "Registry subkey: $targetSubkey"

# Build a temporary PowerShell script to run under SYSTEM
$tempScript = Join-Path $env:TEMP "ResetRadminMAC_$([GUID]::NewGuid().ToString('N')).ps1"

# Here-document for the child script
$childScriptContent = @"
`$ErrorActionPreference = 'Stop'

# Stop Radmin processes
Write-Host "Stopping Radmin processes..."
Stop-Process -Name "RvControlSvc" -Force -ErrorAction SilentlyContinue
Stop-Process -Name "RvRvpnGui" -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1

# Disable adapter using netsh
Write-Host "Disabling adapter..."
netsh interface set interface name="$adapterName" admin=disabled | Out-Null
Start-Sleep -Seconds 2

# Write MAC address to registry
Write-Host "Writing NetworkAddress = $newMacHex"
Set-ItemProperty -Path "$targetSubkey" -Name "NetworkAddress" -Value "$newMacHex" -Type String -Force
Start-Sleep -Seconds 1

# Enable adapter using netsh
Write-Host "Enabling adapter..."
netsh interface set interface name="$adapterName" admin=enabled | Out-Null
Start-Sleep -Seconds 2

Write-Host "MAC address changed successfully."
"@

# Write child script to temp file
Set-Content -Path $tempScript -Value $childScriptContent -Encoding UTF8

# Execute child script via PsExec as SYSTEM
Write-Host "Elevating with PsExec and executing operations..."
$cmdArgs = @("-accepteula", "-s", "-i", "powershell.exe", "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "`"$tempScript`"")
$process = Start-Process -FilePath $psexec -ArgumentList $cmdArgs -Wait -NoNewWindow -PassThru

# Clean up temp script
Remove-Item -Path $tempScript -Force -ErrorAction SilentlyContinue

if ($process.ExitCode -eq 0) {
    Write-Host "MAC address changed successfully."
} else {
    Write-Host "ERROR: PsExec reported failure (exit code $($process.ExitCode))."
}

Read-Host "Press Enter to exit..."
