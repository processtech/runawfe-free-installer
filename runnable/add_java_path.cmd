@echo off
cd /d "%~dp0"
powershell -ExecutionPolicy Bypass -File "add_java_path.ps1"
del "add_java_path.ps1"