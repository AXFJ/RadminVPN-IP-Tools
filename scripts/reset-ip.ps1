# Check permission
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Please run this script as an administrator."
    Read-Host "Press Enter to exit..."
    exit 1
}

# Locate Psexec
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

Write-Host "WARNING: Please be sure you've backuped everything!"
Write-Host "                  To backup, run backup-ip.bat."
Read-Host "Press Enter to continue..."

# 1. Kill RvControlSvc
# 2. Delete registry key
# 3. Kill RvRvpnGui
$regPath = "HKLM\SOFTWARE\WOW6432Node\Famatech\RadminVPN\1.0"
$cmdArgs = @("-accepteula", "-s", "-i", "cmd.exe", "/c",
    "taskkill /f /im RvControlSvc.exe >nul 2>&1 & reg delete `"$regPath`" /f >nul 2>&1 & taskkill /f /im RvRvpnGui.exe >nul 2>&1"
)

Write-Host "Elevating and executing operations..."
$process = Start-Process -FilePath $psexec -ArgumentList $cmdArgs -Wait -NoNewWindow -PassThru

if ($process.ExitCode -eq 0) {
    Write-Host "Done."
} else {
    Write-Host "ERROR: Fatal error."
}

Read-Host "Press Enter to exit..."