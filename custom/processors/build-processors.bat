@echo off
chcp 65001 >nul

echo.
powershell -Command "Write-Host '[Custom Processors] Компиляция ServerPortDetectorProcessor...' -ForegroundColor Cyan"

set "CUSTOM_SRC=%~dp0src"
set "CUSTOM_BUILD=%~dp0build"
set "CUSTOM_JAR=%~dp0custom-processors.jar"

if not exist "%CUSTOM_BUILD%" mkdir "%CUSTOM_BUILD%"

set "CP=%IZPACK_HOME%\lib\*"

javac -cp "%CP%" -d "%CUSTOM_BUILD%" "%CUSTOM_SRC%\com\izforge\izpack\panels\userinput\processor\ServerPortDetectorProcessor.java"
if errorlevel 1 (
    echo.
    powershell -Command "Write-Host '[Custom Processors] ОШИБКА компиляции!' -ForegroundColor Red"
    exit /b 1
)

jar cf "%CUSTOM_JAR%" -C "%CUSTOM_BUILD%" .
if errorlevel 1 (
    echo.
    powershell -Command "Write-Host '[Custom Processors] ОШИБКА создания jar!' -ForegroundColor Red"
    exit /b 1
)

powershell -Command "Write-Host '[Custom Processors] Готово: %CUSTOM_JAR%' -ForegroundColor Green"