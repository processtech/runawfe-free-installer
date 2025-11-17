@echo off
chcp 65001 >nul

echo.
powershell -Command "Write-Host '[Installer Runner] Запуск установщика...' -ForegroundColor Cyan"
echo.

if not exist install.jar (
    echo.
    powershell -Command "Write-Host 'Файл install.jar не найден!' -ForegroundColor Red"
    powershell -Command "Write-Host 'Сначала выполните компиляцию' -ForegroundColor Red"
    echo.
    pause
    exit /b 1
)

powershell -Command "Write-Host 'Запускаю install.jar...' -ForegroundColor Cyan"
echo.
start java -jar install.jar
exit /b 0
