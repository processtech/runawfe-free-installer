@echo off
if exist "$appdata.install.path" (
    rmdir /s /q "$appdata.install.path" >nul 2>&1
)

rmdir /s /q "%TEMP%\$APP_NAME

exit /b 0