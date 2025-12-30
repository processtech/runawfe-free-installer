@echo off
SET JBOSS_LOG_DIR="%TEMP%\$APP_NAME\jboss\log"
call standalone.bat "-Djboss.server.log.dir=%TEMP%\$APP_NAME\jboss\log" "-Djboss.server.temp.dir=%TEMP%\$APP_NAME\jboss\tmp" "-Djboss.server.base.dir=%APPDATA%\$APP_NAME\jboss"
