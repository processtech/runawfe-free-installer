@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

call setenv.bat

set "SERVICE=%~1"
if "%SERVICE%"=="" (echo ОШИБКА: Не указан сервис. & exit /b 1)

REM 1. Определяем тип ОС и архитектуру
set "TARGET_OS=linux"
set "TARGET_ARCH=x86_64"
if /i "%SERVICE%"=="win7-gui" (
    set "TARGET_OS=windows"
    set "TARGET_ARCH=x86_64"
)
if /i "%SERVICE%"=="macos-gui" (
    set "TARGET_OS=macos"
    set "TARGET_ARCH=aarch64"
)

if /i "!TARGET_OS!"=="windows" (
    set "TARGET_INSTALLER_PATH=dist\%INSTALLER_EXE%"
) else (
    if /i "!TARGET_ARCH!"=="x86_64" (
        set "TARGET_INSTALLER_PATH=dist\%INSTALLER_X86_64RUN%"
    ) else (
        set "TARGET_INSTALLER_PATH=dist\%INSTALLER_AARCH64RUN%"
    )
)

echo Целевая ОС: !TARGET_OS!
echo Целевая архитектура: !TARGET_ARCH!

REM 2. Определяем имя JAR для целевой платформы
call set_output_jar.bat !TARGET_OS! !TARGET_ARCH!
if errorlevel 1 exit /b 1

REM Проверяем нужно ли пересобирать JAR
set NEED_BUILD=0
if not exist "%OUTPUT_JAR%" (
    set NEED_BUILD=1
) else (
    rem если есть хоть один XML в корне или любые файлы в resources (рекурсивно) новее JAR, присваиваем "1"
    for /f %%A in ('powershell -Command "$files = Get-ChildItem *.xml*, resources -Recurse; $maxDate = ($files | Measure-Object -Property LastWriteTime -Maximum).Maximum; if ($maxDate -gt (Get-Item '%OUTPUT_JAR%').LastWriteTime) { 1 } else { 0 }"') do set NEED_BUILD=%%A
)

if "!NEED_BUILD!"=="1" (
    echo Компиляция инсталлятора для !TARGET_OS! !TARGET_ARCH!...
    call build.bat !TARGET_OS! !TARGET_ARCH!
    if errorlevel 1 exit /b 1
) else (
    echo Сборка не требуется.
)

REM 3. Проверяем нужно ли упаковывать инсталлятор
set NEED_WRAP=0

if !NEED_BUILD!==1 (
    rem JAR был пересобран
    set NEED_WRAP=1
) else if not exist "!TARGET_INSTALLER_PATH!" (
    rem Упакованный файл отсутствует.
    set NEED_WRAP=1
) else (
    rem Только если JAR не менялся и EXE на месте, проверяем даты через PowerShell
    for /f %%A in ('powershell -Command "if ((Get-Item '%OUTPUT_JAR%').LastWriteTime -gt (Get-Item '!TARGET_INSTALLER_PATH!').LastWriteTime) { 1 } else { 0 }"') do set NEED_WRAP=%%A
)

if "!NEED_WRAP!"=="1" (
    echo Упаковка инсталлятора...
    if /i "!TARGET_OS!"=="windows" (
        call wrappers\izpack2exe\build_exe.cmd
    ) else if /i "!TARGET_OS!"=="linux" (
        rem Передаём архитектуру в build_linux.cmd (x86_64 или aarch64)
        if /i "!TARGET_ARCH!"=="x86_64" (
            call wrappers\izpack2app\build_linux.cmd x86_64
        ) else (
            call wrappers\izpack2app\build_linux.cmd aarch64
        )
    ) else if /i "!TARGET_OS!"=="macos" (
        echo Упаковка для macOS не реализована.
        exit /b 1
    )
) else (
    echo Упаковка не требуется.
)

echo [prepare_for_target_os] Завершено.
exit /b 0
