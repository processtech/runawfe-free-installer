@echo off
if exist "$rtn.properties.folder" (
    rmdir /s /q "$rtn.properties.folder" >nul 2>&1
)
if exist "$rtn.log.dir" (
    rmdir /s /q "$rtn.log.dir" >nul 2>&1
)
exit /b 0