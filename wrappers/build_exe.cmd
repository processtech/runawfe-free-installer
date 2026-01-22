@echo off
chcp 65001 >nul

echo.
powershell -Command "Write-Host 'Конвертация JAR → EXE...' -ForegroundColor Yellow"
echo.

call "%~dp0..\setenv.bat"

cd /d "%~dp0izpack2exe"

python izpack2exe.py ^
--file="%INSTALL_JAR%" ^
--output="%PROJECT_ROOT%\%INSTALLER_EXE%" ^
--with-7z="%IZPACK_WRAPPER%\7za.exe" ^
--no-upx ^
--with-jdk=%LAUNCHER_JRE%

if %errorlevel% == 0 (
  echo.
  powershell -Command "Write-Host 'EXE создан: %INSTALLER_EXE%' -ForegroundColor Green"
  "%RCEDIT%" "%PROJECT_ROOT%\%INSTALLER_EXE%" --set-icon "%PROJECT_ROOT%\%INSTALLER_ICON%"
  if %errorlevel% == 0 (
    powershell -Command "Write-Host 'Иконка установлена.' -ForegroundColor Green"
    ) else (
    powershell -Command "Write-Host 'ПРЕДУПРЕЖДЕНИЕ: Не удалось установить иконку.' -ForegroundColor Yellow"
  )
  ) else (
  echo.
  powershell -Command "Write-Host 'ERROR: Ошибка при создании EXE' -ForegroundColor Red"
)
