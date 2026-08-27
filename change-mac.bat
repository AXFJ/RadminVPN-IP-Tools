@echo off
cd /d "%~dp0"
powershell -ExecutionPolicy Bypass -File ".\scripts\change-mac.ps1"
pause