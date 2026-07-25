if "$delete.gpd" == "true" (
  rmdir /s /q "$INSTALL_PATH\$gpd.subpath"
  rmdir /s /q "$appdata.install.path\$gpd.subpath"
)
if "$delete.rtn" == "true" (
  rmdir /s /q "$INSTALL_PATH\$rtn.subpath"
  del "$appdata.install.path\rtn.log"
  del "%USERPROFILE%\config.properties"
)
if "$delete.simulator" == "true" (
  rmdir /s /q "$INSTALL_PATH\$simulator.subpath"
  rmdir /s /q "$appdata.install.path\jboss"
  del "%TEMP%\$simulator.jboss.log.subdir\server.log"
  rmdir /s /q "%TEMP%\$APP_NAME\jboss\tmp"
)
exit /b 0
