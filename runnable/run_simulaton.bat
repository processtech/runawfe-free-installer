@echo off
SET JBOSS_LOG_DIR="%TEMP%\$APP_NAME\jboss\log"
call standalone.bat "-Djboss.server.log.dir=%JBOSS_LOG_DIR%" "-Djboss.server.temp.dir=%TEMP%\$APP_NAME\jboss\tmp" "-Djboss.server.base.dir=%APPDATA%\$APP_NAME\jboss"
