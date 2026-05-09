@echo off
REM Wrapper to run the PowerShell automation script on Windows
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\ci_run.ps1" %*