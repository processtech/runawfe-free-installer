@echo off
SET JBOSS_LOG_DIR="%TEMP%\$APP_NAME\jboss\log"

del /F /S /Q "$appdata.install.path\jboss\configuration"
del /F /S /Q "$appdata.install.path\jboss\deployments"
del /F /S /Q "$appdata.install.path\jboss\wfe.custom"
del /F /S /Q "$appdata.install.path\jboss\wfe.data-sources"
xcopy "$standalone.path\configuration" "$appdata.install.path\jboss\configuration" /D /I /S /Y /R
xcopy "$standalone.path\deployments" "$appdata.install.path\jboss\deployments" /D /I /S /Y /R
xcopy "$standalone.path\wfe.custom" "$appdata.install.path\jboss\wfe.custom" /D /I /S /Y /R
xcopy "$standalone.path\wfe.data-sources" "$appdata.install.path\jboss\wfe.data-sources" /D /I /S /Y /R

if not exist "$appdata.install.path\jboss\data" (
  xcopy "$standalone.path\data\demo-db" "$appdata.install.path\jboss\data\h2" /D /I /S /Y /R
)

call standalone.bat "-Djboss.server.log.dir=%JBOSS_LOG_DIR%" "-Djboss.server.temp.dir=%TEMP%\$APP_NAME\jboss\tmp" "-Djboss.server.base.dir=$appdata.install.path\jboss"
