@echo off
cd /d "%~dp0"
powershell -ExecutionPolicy Bypass -File ".\scripts\backup-ip.ps1"
pause