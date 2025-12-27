if "$delete.gpd" == "true" (
    rmdir /s /q "$INSTALL_PATH\$gpd.subpath"
    rmdir /s /q "$appdata\$APP_NAME\$gpd.subpath"
)
if "$delete.rtn" == "true" (
    rmdir /s /q "$INSTALL_PATH\$rtn.subpath"
    del "$appdata\$APP_NAME\rtn.log"
    del "%USERPROFILE%\config.properties"
)