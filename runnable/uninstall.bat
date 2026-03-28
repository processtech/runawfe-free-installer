@echo off
set "TEMP_JAVA=%TEMP%\RunaWFE_uninstall_java_%RANDOM%"
xcopy "$java.path" "%TEMP_JAVA%" /E /I /Y >nul
"%TEMP_JAVA%\bin\javaw.exe" -jar "${INSTALL_PATH}\Uninstaller\uninstaller.jar"