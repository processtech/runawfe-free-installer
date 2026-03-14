@echo off
setlocal enabledelayedexpansion

if "%~1"=="" (
    echo ОШИБКА: Не указан параметр target_os.
    exit /b 1
)
if "%~2"=="" (
    echo ОШИБКА: Не указан параметр target_arch.
    exit /b 1
)

set "TARGET_OS=%~1"
set "TARGET_ARCH=%~2"

if not "!TARGET_OS!"=="windows" if not "!TARGET_OS!"=="linux" if not "!TARGET_OS!"=="macos" (
    echo ОШИБКА: Недопустимое значение target_os: !TARGET_OS!
    exit /b 1
)
if not "!TARGET_ARCH!"=="x86_64" if not "!TARGET_ARCH!"=="aarch64" (
    echo ОШИБКА: Недопустимое значение target_arch: !TARGET_ARCH!
    exit /b 1
)

set "OUTPUT_JAR=dist\install_!TARGET_OS!_!TARGET_ARCH!.jar"

endlocal & (
    set "OUTPUT_JAR=%OUTPUT_JAR%"
)