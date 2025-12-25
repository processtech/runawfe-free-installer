if "$delete.gpd" == "true" (
    rmdir /s /q "$INSTALL_PATH\$gpd.subpath"
    rmdir /s /q "$appdata\$APP_NAME"
)
exit /b 0