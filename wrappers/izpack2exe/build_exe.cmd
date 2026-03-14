@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo.
powershell -Command "Write-Host 'Конвертация JAR → EXE...' -ForegroundColor Yellow"
echo.

set PROJECT_ROOT=%~dp0..\..

call "%PROJECT_ROOT%\setenv.bat"

call "%PROJECT_ROOT%\set_output_jar.bat" windows x86_64
if errorlevel 1 exit /b 1
set INSTALL_JAR=%PROJECT_ROOT%\%OUTPUT_JAR%
set IZPACK_WRAPPER=C:\Program Files\IzPack\utils\wrappers\izpack2exe
cd /d "%~dp0"



py izpack2exe.py ^
  --file="%INSTALL_JAR%" ^
  --output="%PROJECT_ROOT%\dist\%INSTALLER_EXE%" ^
  --with-7z="%IZPACK_WRAPPER%\7za.exe" ^
  --no-upx ^
  --with-jdk=%WINDOWS_JRE% ^
  --jvm-args="-Dfile.encoding=UTF-8 -Dconsole.encoding=UTF-8"

if %errorlevel% == 0 (
    echo.
    powershell -Command "Write-Host 'SUCCESS: EXE создан: %INSTALLER_EXE%' -ForegroundColor Green"
    echo.
    exit /b 0
) else (
    echo.
    powershell -Command "Write-Host 'ERROR: Ошибка при создании EXE' -ForegroundColor Red"
    echo.
    exit /b 1
)
