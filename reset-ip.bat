@echo off
cd /d "%~dp0"
powershell -ExecutionPolicy Bypass -File ".\scripts\reset-ip.ps1"
pause