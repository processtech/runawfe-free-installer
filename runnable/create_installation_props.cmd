@echo off
cd /d "%~dp0"
powershell -ExecutionPolicy Bypass -File "create_installation_props.ps1"
del "create_installation_props.ps1"