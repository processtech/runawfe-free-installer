@echo off
chcp 65001 >nul

echo.
powershell -Command "Write-Host '[IzPack Compiler] Запуск компиляции...' -ForegroundColor Cyan"
echo.

set COMPILER_PATH="C:\Program Files\IzPack\bin\compile.bat"
set XML_FILE=RunaWFE_installer.xml

if not exist %XML_FILE% (
    echo Файл %XML_FILE% не найден!
    exit /b 1
)

set IZPACK_OPTS=-Dfile.encoding=UTF-8

powershell -Command "Write-Host 'Компилирую %XML_FILE%...' -ForegroundColor Cyan"
call %COMPILER_PATH% %XML_FILE%

if %errorlevel% == 0 (
    echo.
    powershell -Command "Write-Host 'SUCCESS: Компиляция завершена. Файл install.jar создан.' -ForegroundColor Green"
    echo.
    exit /b 0
) else (
    echo.
    powershell -Command "Write-Host 'ERROR: Компиляция не удалась. Проверьте лог выше.' -ForegroundColor Red"
    echo.
    exit /b 1
)
