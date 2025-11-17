@echo off
chcp 65001 >nul

echo.
echo [Installer Runner] Запуск установщика...
echo.

if not exist install.jar (
    echo Файл install.jar не найден!
    echo Сначала выполните компиляцию
    echo.
    pause
    exit /b 1
)

echo Запускаю install.jar...
echo.
start java -jar install.jar
exit /b 0
