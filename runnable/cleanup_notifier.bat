@echo off
if exist "$rtn.properties.folder" (
    rmdir /s /q "$rtn.properties.folder" >nul 2>&1
)
exit /b 0