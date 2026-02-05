@echo off
chcp 65001 >nul

setlocal

set JAVA_HOME=$java.path
set "NOPAUSE=1"
set "LOGFILE=%TEMP%\runawfe_uninstall.log"

msg * /TIME:20 "Выполняется остановка службы сервера RunaWFE. Это может занять порядка минуты. После этого деинсталляция продолжится автоматически."

:: Очистка лога
echo. > "%LOGFILE%" 2>nul

echo [1/4] Остановка сервера WildFly... >> "%LOGFILE%"
call "$INSTALL_PATH\$server.subpath\bin\jboss-cli.bat" --connect --controller=localhost:$jboss.management.http.port --command=:shutdown >> "%LOGFILE%" 2>&1

echo [2/4] Завершение процесса jbosssvc.exe... >> "%LOGFILE%"
taskkill /F /IM jbosssvc.exe >> "%LOGFILE%" 2>&1

echo [3/4] Удаление службы >> "%LOGFILE%"
sc delete $jboss.servicename >> "%LOGFILE%" 2>&1

echo [4/4] Поиск и завершение java.exe, связанного с сервером >> "%LOGFILE%"
taskkill /F /IM java.exe /FI "MODULES eq jboss-modules.jar" >> "%LOGFILE%" 2>&1