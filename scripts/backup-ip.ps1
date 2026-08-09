<#
.SYNOPSIS
    Backup Radmin VPN registry key via PsExec with SYSTEM privilege
.DESCRIPTION
    Export HKLM\SOFTWARE\WOW6432Node\Famatech\RadminVPN\1.0 to a .reg file
    saved in the "backups" folder located in the parent directory of the script.
    Requires PsExec.exe and admin rights.
#>

# Check administrator rights
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Please run this script as Administrator."
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
    Write-Host "PsExec.exe not found. Place it in the script folder or add to PATH."
    Read-Host "Press Enter to exit..."
    exit 1
}

# Registry path and output path (parent folder\backups\RadminVPN_Backup.reg)
$regPath = "HKLM\SOFTWARE\WOW6432Node\Famatech\RadminVPN\1.0"
$parentDir = Split-Path -Parent $scriptDir
$backupDir = Join-Path $parentDir "backups"

# Create backups folder if it does not exist
if (-not (Test-Path $backupDir)) {
    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
}

$exportFile = Join-Path $backupDir "RadminVPN_Backup.reg"

Write-Host "Exporting registry key with SYSTEM privilege:"
Write-Host "    $regPath"
Write-Host "    to $exportFile"

# Build PsExec command line
$cmdArgs = @(
    "-accepteula",
    "-s",
    "cmd.exe", "/c",
    "reg export `"$regPath`" `"$exportFile`" /y"
)

$process = Start-Process -FilePath $psexec -ArgumentList $cmdArgs -Wait -NoNewWindow -PassThru

if ($process.ExitCode -eq 0) {
    Write-Host "Backup successful."
} else {
    Write-Host "Backup failed (exit code: $($process.ExitCode)). Check permissions or if the key exists."
}

Read-Host "Press Enter to exit..."