@echo off
chcp 65001 >nul

echo.
powershell -Command "Write-Host 'Создание installer.run (Linux) с включенной JRE...' -ForegroundColor Yellow"
echo.

REM Загрузка переменных окружения
call "%~dp0..\..\setenv.bat"

set PROJECT_ROOT=%~dp0..\..
set INPUT_JAR=%PROJECT_ROOT%\dist\install.jar

REM Проверка наличия входного файла
if not exist "%INPUT_JAR%" (
    powershell -Command "Write-Host 'ОШИБКА: Файл %INPUT_JAR% не найден!' -ForegroundColor Red"
    echo Сначала выполните сборку: build.bat
    exit /b 1
)

REM Проверка наличия Python
where python >nul 2>nul
if %errorlevel% neq 0 (
    powershell -Command "Write-Host 'ОШИБКА: Python не найден в PATH.' -ForegroundColor Red"
    exit /b 1
)

set SCRIPT_DIR=%~dp0
set IZPACK2RUN=%SCRIPT_DIR%izpack2run.py

if not exist "%IZPACK2RUN%" (
    powershell -Command "Write-Host 'ОШИБКА: Скрипт izpack2run.py не найден: %IZPACK2RUN%' -ForegroundColor Red"
    exit /b 1
)

REM Определение архитектуры (по умолчанию x64)
set ARCH=x64
if not "%~1"=="" (
    set ARCH=%~1
)

REM Проверка допустимости архитектуры
if not "%ARCH%"=="x64" if not "%ARCH%"=="aarch64" (
    powershell -Command "Write-Host 'ОШИБКА: Неизвестная архитектура: %ARCH%' -ForegroundColor Red"
    exit /b 1
)

REM Выбор JRE в зависимости от архитектуры
if "%ARCH%"=="x64" (
    set JRE_PATH=%LINUX_X64_JRE%
) else (
    set JRE_PATH=%LINUX_AARCH64_JRE%
)

if "%JRE_PATH%"=="" (
    powershell -Command "Write-Host 'ОШИБКА: Путь к JRE для архитектуры %ARCH% не задан в setenv.bat' -ForegroundColor Red"
    exit /b 1
)

if not exist "%JRE_PATH%" (
    powershell -Command "Write-Host 'ОШИБКА: JRE не найдена по пути: %JRE_PATH%' -ForegroundColor Red"
    exit /b 1
)

if "%ARCH%"=="x64" (
    set OUTPUT_RUN=%PROJECT_ROOT%\dist\%INSTALLER_X64RUN%
) else (
    set OUTPUT_RUN=%PROJECT_ROOT%\dist\%INSTALLER_AARCH64RUN%
)

echo.
powershell -Command "Write-Host 'Создание .run для архитектуры %ARCH%...' -ForegroundColor Cyan"
echo Входной JAR:   %INPUT_JAR%
echo JRE:           %JRE_PATH%
echo Выходной файл: %OUTPUT_RUN%

set PYTHONDONTWRITEBYTECODE=1
python "%IZPACK2RUN%" --jar "%INPUT_JAR%" --jre "%JRE_PATH%" --output "%OUTPUT_RUN%" --arch %ARCH%

if %errorlevel% neq 0 (
    powershell -Command "Write-Host 'ERROR: Ошибка при создании .run для архитектуры %ARCH%' -ForegroundColor Red"
    exit /b 1
)

REM Проверка размера файла
setlocal enabledelayedexpansion
set size=
for %%F in ("%OUTPUT_RUN%") do (
    set size=%%~zF
)
if defined size (
    set /a size_kb=!size! / 1024 2>nul
    if !size_kb! gtr 0 (
        echo Размер файла: !size_kb! KB
    ) else (
        echo Размер файла: !size! байт
    )
) else (
    echo Размер файла: неизвестен
)
endlocal

powershell -Command "Write-Host 'SUCCESS: .run создан: %OUTPUT_RUN%' -ForegroundColor Green"
exit /b 0
