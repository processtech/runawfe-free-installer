@echo off
chcp 65001 >nul

echo.
powershell -Command "Write-Host 'Создание installer.run (Linux) из dist\install.jar...' -ForegroundColor Yellow"
echo.

REM Загрузка переменных окружения
call "%~dp0..\..\setenv.bat"

set PROJECT_ROOT=%~dp0..\..
set IZPACK_HOME=C:\Program Files\IzPack
set STUB=%IZPACK_HOME%\utils\wrappers\izpack2run\linux_stub
set INPUT_JAR=%PROJECT_ROOT%\dist\install.jar

REM Формирование имени выходного файла на основе переменных из setenv.bat
set OUTPUT_RUN=%PROJECT_ROOT%\dist\%WFE_APPNAME%-%WFE_EDITION%-%WFE_VERSION%.run

REM Проверка наличия входного файла
if not exist "%INPUT_JAR%" (
    powershell -Command "Write-Host 'ОШИБКА: Файл %INPUT_JAR% не найден!' -ForegroundColor Red"
    echo Сначала выполните сборку: build.bat
    exit /b 1
)

REM Проверка наличия IzPack
if not exist "%IZPACK_HOME%" (
    powershell -Command "Write-Host 'ОШИБКА: IzPack не найден по пути: %IZPACK_HOME%' -ForegroundColor Red"
    exit /b 1
)

if not exist "%STUB%" (
    powershell -Command "Write-Host 'ОШИБКА: Файл linux_stub не найден: %STUB%' -ForegroundColor Red"
    exit /b 1
)

echo Создание installer.run...
echo Входной файл:  %INPUT_JAR%
echo Выходной файл: %OUTPUT_RUN%
echo.

java -cp "%IZPACK_HOME%" utils.wrappers.izpack2run.Merge2In1 ^
    "%STUB%" ^
    "%INPUT_JAR%" ^
    "%OUTPUT_RUN%"

if %errorlevel% == 0 (
    echo.
    powershell -Command "Write-Host 'SUCCESS: installer.run создан: %OUTPUT_RUN%' -ForegroundColor Green"
    
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
    
    echo.
    exit /b 0
) else (
    echo.
    powershell -Command "Write-Host 'ERROR: Ошибка при создании installer.run' -ForegroundColor Red"
    echo.
    exit /b 1
)
