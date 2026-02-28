@echo off
chcp 65001 >nul

echo.
powershell -Command "Write-Host 'Конвертация JAR → EXE...' -ForegroundColor Yellow"
echo.

set PROJECT_ROOT=%~dp0..

call "%PROJECT_ROOT%\setenv.bat"

set INSTALL_JAR=%PROJECT_ROOT%\install.jar
set IZPACK_WRAPPER=C:\Program Files\IzPack\utils\wrappers\izpack2exe

cd /d "%~dp0izpack2exe"

py izpack2exe.py ^
  --file="%INSTALL_JAR%" ^
  --output="%PROJECT_ROOT%\%INSTALLER_EXE%" ^
  --with-7z="%IZPACK_WRAPPER%\7za.exe" ^
  --no-upx ^
  --with-jdk=%LAUNCHER_JRE% ^
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
