@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

set "SERVICE=%~1"
if "%SERVICE%"=="" (echo ОШИБКА: Не указан сервис. & exit /b 1)

REM 1. Определяем тип ОС и пути
set "TARGET_OS=linux"
if /i "%SERVICE%"=="win7-gui" set "TARGET_OS=windows"
if /i "%SERVICE%"=="macos-gui" set "TARGET_OS=macos"

if /i "!TARGET_OS!"=="windows" ( set "TARGET_INSTALLER_PATH=dist\RunaWFE_test-Free-4.6.0.exe"
) else if /i "!TARGET_OS!"=="macos" ( set "TARGET_INSTALLER_PATH=dist\RunaWFE_test-Free-4.6.0-aarch64.run"
) else ( set "TARGET_INSTALLER_PATH=dist\RunaWFE_test-Free-4.6.0-x64.run" )

echo Целевая ОС: !TARGET_OS!

REM 2. Проверяем нужно ли пересобирать install.jar
set NEED_BUILD=0
if not exist "dist\install.jar" (
    set NEED_BUILD=1
) else (
    rem если есть хоть один XML в корне или любые файлы в resources (рекурсивно) новее install.jar, присваиваем "1"
    for /f %%A in ('powershell -Command "$files = Get-ChildItem *.xml*, resources -Recurse; $maxDate = ($files | Measure-Object -Property LastWriteTime -Maximum).Maximum; if ($maxDate -gt (Get-Item 'dist\install.jar').LastWriteTime) { 1 } else { 0 }"') do set NEED_BUILD=%%A
)

if "!NEED_BUILD!"=="1" (
    echo Сборка инсталлятора...
    call build.bat
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
    for /f %%A in ('powershell -Command "if ((Get-Item 'dist\install.jar').LastWriteTime -gt (Get-Item '!TARGET_INSTALLER_PATH!').LastWriteTime) { 1 } else { 0 }"') do set NEED_WRAP=%%A
)

if "!NEED_WRAP!"=="1" (
    echo Упаковка инсталлятора...
    if /i "!TARGET_OS!"=="windows" (
        call wrappers\izpack2exe\build_exe.cmd
    ) else if /i "!TARGET_OS!"=="linux" (
        call wrappers\izpack2app\build_linux.cmd x64
    )
) else (
    echo Упаковка не требуется.
)

echo [prepare_for_target_os] Завершено.
exit /b 0
