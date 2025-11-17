@echo off
chcp 65001 >nul

echo.
echo [IzPack Compiler] Запуск компиляции...
echo.

set COMPILER_PATH="C:\Program Files\IzPack\bin\compile.bat"
set XML_FILE=RunaWFE_installer.xml

if not exist %XML_FILE% (
    echo Файл %XML_FILE% не найден!
    exit /b 1
)

set IZPACK_OPTS=-Dfile.encoding=UTF-8

echo Компилирую %XML_FILE%...
call %COMPILER_PATH% %XML_FILE%

if %errorlevel% == 0 (
    echo.
    echo SUCCESS: Компиляция завершена. Файл install.jar создан.
    echo.
    exit /b 0
) else (
    echo.
    echo ERROR: Компиляция не удалась. Проверьте лог выше.
    echo.
    pause
    exit /b 1
)
