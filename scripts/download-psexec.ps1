<#
.SYNOPSIS
    Download PsExec from Microsoft Sysinternals
.DESCRIPTION
    Downloads the latest PsExec.zip from the official Microsoft source,
    extracts PsExec.exe to the script directory, and removes the downloaded archive.
#>

$url = "https://download.sysinternals.com/files/PSTools.zip"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$zipPath = Join-Path $scriptDir "PSTools.zip"
$psexecPath = Join-Path $scriptDir "PsExec.exe"

# Download
Write-Host "Downloading PsExec..."
try {
    Invoke-WebRequest -Uri $url -OutFile $zipPath -ErrorAction Stop
    Write-Host "Download completed."
} catch {
    Write-Host "Download failed: $_"
    Read-Host "Press Enter to exit..."
    exit 1
}

# Extract PsExec.exe only
Write-Host "Extracting PsExec.exe..."
try {
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $zip = [System.IO.Compression.ZipFile]::OpenRead($zipPath)
    $entry = $zip.Entries | Where-Object { $_.Name -eq "PsExec.exe" }
    if ($entry) {
        [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $psexecPath, $true)
        Write-Host "Extracted to $psexecPath"
    } else {
        Write-Host "PsExec.exe not found in the archive."
        $zip.Dispose()
        Remove-Item $zipPath -Force
        Read-Host "Press Enter to exit..."
        exit 1
    }
    $zip.Dispose()
} catch {
    Write-Host "Extraction failed: $_"
    Remove-Item $zipPath -Force -ErrorAction SilentlyContinue
    Read-Host "Press Enter to exit..."
    exit 1
}

# Clean up
Remove-Item $zipPath -Force
Write-Host "Done."

# Pause to allow review
Read-Host "Press Enter to exit..."