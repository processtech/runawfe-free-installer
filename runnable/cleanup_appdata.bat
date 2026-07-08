@echo off
if exist "$appdata.install.path" (
    rmdir /s /q "$appdata.install.path" >nul 2>&1
)
exit /b 0