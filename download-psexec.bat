@echo off
cd /d "%~dp0"
powershell -ExecutionPolicy Bypass -File ".\scripts\download-psexec.ps1"
pause