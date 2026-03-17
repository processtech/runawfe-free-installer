@echo off
chcp 65001 >nul

echo.
powershell -Command "Write-Host '[IzPack Compiler] Запуск компиляции...' -ForegroundColor Cyan"
echo.

set TARGET_OS=windows
set TARGET_ARCH=x86_64

if not "%~1"=="" (
    set TARGET_OS=%~1
)
if not "%~2"=="" (
    set TARGET_ARCH=%~2
)

@REM Проверка допустимых значений target_os и target_arch
if not "%TARGET_OS%"=="windows" if not "%TARGET_OS%"=="linux" (
    echo ОШИБКА: Недопустимое значение target_os: %TARGET_OS%
    goto print_usage
)
if not "%TARGET_ARCH%"=="x86_64" if not "%TARGET_ARCH%"=="aarch64" (
    echo ОШИБКА: Недопустимое значение target_arch: %TARGET_ARCH%
    goto print_usage
)

call setenv.bat

@REM  Проверяем обязательные аргументы
if "%WFE_EDITION%"=="" (
    echo ОШИБКА: Не указана редакция. Например: Free.
    exit /b 1
)

if "%WFE_VERSION%"=="" (
    echo ОШИБКА: Не указана версия. Например, 4.7.
    exit /b 1
)

echo Редакция: %WFE_EDITION%
echo Версия:   %WFE_VERSION%
echo Целевая ОС: %TARGET_OS%

if not exist %XML_FILE% (
    echo Файл %XML_FILE% не найден!
    exit /b 1
)

call set_output_jar.bat %TARGET_OS% %TARGET_ARCH%
if errorlevel 1 exit /b 1

powershell -Command "Write-Host 'Компилирую %XML_FILE%...' -ForegroundColor Cyan"
powershell -Command "$compiler = '%COMPILER_PATH%';" ^
 "$xml = '%XML_FILE%';" ^
 "$jar = '%OUTPUT_JAR%';" ^
 "$errorOccurred = $false;" ^
 "& $compiler $xml -o $jar 2>&1 | ForEach-Object {" ^
 "    Write-Host $_;" ^
 "    if ($_ -match 'Fatal error') { $errorOccurred = $true }" ^
 "};" ^
 "$exitCode = $LASTEXITCODE;" ^
 "if ($exitCode -ne 0 -or $errorOccurred) { exit 1 } else { exit 0 }"
if errorlevel 1 (
    echo.
    powershell -Command "Write-Host 'ERROR: Компиляция не удалась. Проверьте лог выше.' -ForegroundColor Red"
    del /q "%OUTPUT_JAR%" 2>nul
    echo.
    exit /b 1
) else (
    echo.
    powershell -Command "Write-Host 'SUCCESS: Компиляция завершена. Файл %OUTPUT_JAR% создан.' -ForegroundColor Green"
    echo.
    exit /b 0
)

:print_usage
echo.
echo Использование: build.bat [target_os] [target_arch]
echo Пример:    build.bat windows x86_64
echo Пример:    build.bat linux x86_64
echo Пример:    build.bat linux aarch64
echo Если target_os не указан, используется windows.
echo Если target_arch не указан, используется x86_64.
exit /b 1