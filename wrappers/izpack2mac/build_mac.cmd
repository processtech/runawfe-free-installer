@echo off
chcp 65001 >nul

set ARCH=x86_64
echo.
powershell -Command "Write-Host 'Создание дистрибутива для macOS %ARCH%...' -ForegroundColor Yellow"
echo.

call "%~dp0..\..\setenv.bat"

set PROJECT_ROOT=%~dp0..\..

REM Проверка наличия Python
where python >nul 2>nul
if %errorlevel% neq 0 (
    powershell -Command "Write-Host 'ОШИБКА: Python не найден в PATH.' -ForegroundColor Red"
    exit /b 1
)

set SCRIPT_DIR=%~dp0
set IZPACK2MAC=%SCRIPT_DIR%izpack2mac.py

if not exist "%IZPACK2MAC%" (
    powershell -Command "Write-Host 'ОШИБКА: Скрипт izpack2mac.py не найден: %IZPACK2MAC%' -ForegroundColor Red"
    exit /b 1
)

REM Определяем имя JAR для macOS
call "%PROJECT_ROOT%\set_output_jar.bat" macos %ARCH%
if errorlevel 1 exit /b 1
set INPUT_JAR=%PROJECT_ROOT%\%OUTPUT_JAR%

REM Проверка наличия входного файла
if not exist "%INPUT_JAR%" (
    powershell -Command "Write-Host 'ОШИБКА: Файл %INPUT_JAR% не найден!' -ForegroundColor Red"
    echo Сначала выполните сборку: build.bat macos %ARCH%
    exit /b 1
)

set JRE_PATH=%MACOS_JRE%

if "%JRE_PATH%"=="" (
    powershell -Command "Write-Host 'ОШИБКА: Путь к JRE для macOS не задан в setenv.bat' -ForegroundColor Red"
    exit /b 1
)

if not exist "%JRE_PATH%" (
    powershell -Command "Write-Host 'ОШИБКА: JRE не найдена по пути: %JRE_PATH%' -ForegroundColor Red"
    exit /b 1
)

set OUTPUT_APP=%PROJECT_ROOT%\dist\%INSTALLER_X86_64APP%

echo.
echo Входной JAR:   %INPUT_JAR%
echo JRE:           %JRE_PATH%
echo Выходной файл: %OUTPUT_APP%

set PYTHONDONTWRITEBYTECODE=1
python "%IZPACK2MAC%" --jar "%INPUT_JAR%" --jre "%JRE_PATH%" --output "%OUTPUT_APP%"

if %errorlevel% neq 0 (
    powershell -Command "Write-Host 'ERROR: Ошибка при создании дистрибутива' -ForegroundColor Red"
    exit /b 1
)

REM Проверка размера дистрибутива
setlocal enabledelayedexpansion
set size=0
for /f "tokens=*" %%F in ('dir /s /a-d "%OUTPUT_APP%" ^| find "File(s)"') do (
    for /f "tokens=3" %%S in ("%%F") do set size=%%S
)
if defined size (
    echo Размер дистрибутива: !size! байт
) else (
    echo Размер дистрибутива: неизвестен
)
endlocal

powershell -Command "Write-Host 'SUCCESS: дистрибутив создан: %OUTPUT_APP%' -ForegroundColor Green"
exit /b 0