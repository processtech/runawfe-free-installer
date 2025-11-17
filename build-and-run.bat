@echo off
REM chcp 65001 >nul
echo.
echo [IzPack Compiler] Запуск компиляции...
echo.

REM Путь к компилятору compile.bat
set COMPILER_PATH="C:\Program Files\IzPack\bin\compile.bat"

REM Файл для компиляции
set XML_FILE=RunaWFE_installer.xml

if not exist %XML_FILE% (
    echo ОШИБКА: Файл %XML_FILE% не найден!
    exit /b 1
)

REM Запускаем компилятор
call %COMPILER_PATH% %XML_FILE%

if %errorlevel% == 0 (
    echo.
    echo SUCCESS: Компиляция завершена. Запускаю install.jar...
    echo.
    start java -jar install.jar
) else (
    echo.
    echo ERROR: Ошибка компиляции. См. лог выше.
    echo.
    pause
)