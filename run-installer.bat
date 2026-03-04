@echo off
chcp 65001 >nul

echo.
powershell -Command "Write-Host '[Installer Runner] Запуск установщика...' -ForegroundColor Cyan"
echo.

if not exist dist\install.jar (
    echo.
    powershell -Command "Write-Host 'Файл install.jar не найден!' -ForegroundColor Red"
    powershell -Command "Write-Host 'Сначала выполните компиляцию' -ForegroundColor Red"
    echo.
    pause
    exit /b 1
)

powershell -Command "Write-Host 'Запускаю install.jar...' -ForegroundColor Cyan"
echo.
java -Dfile.encoding=UTF-8 -jar dist\install.jar
exit /b %errorlevel%