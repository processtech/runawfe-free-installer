set "ECLIPSE_USER_DIR=%USERPROFILE%\.eclipse"

if exist "%ECLIPSE_USER_DIR%" (
    rmdir /s /q "%ECLIPSE_USER_DIR%"
)