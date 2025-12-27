set "ACTIVEMQ_CACHE_DIR=%APPDATA%\$APP_NAME\jboss\data\activemq"

if exist "%ACTIVEMQ_CACHE_DIR%" (
    rmdir /s /q "%ACTIVEMQ_CACHE_DIR%"
)