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
  rmdir /s /q "%TEMP%\$APP_NAME"
)
exit /b 0
