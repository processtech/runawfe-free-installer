#!/bin/sh

TEMP_JAVA="$(mktemp -d /tmp/RunaWFE_uninstall_java_XXXXXX)"

trap 'rm -rf "$TEMP_JAVA"' EXIT INT TERM HUP

cp -Rp "@java.path"/* "$TEMP_JAVA/"

if [ "$(id -u)" -ne 0 ] && command -v sudo >/dev/null 2>&1; then
    sudo -E "$TEMP_JAVA/bin/java" -jar "@INSTALL_PATH/Uninstaller/uninstaller.jar" &
else
    "$TEMP_JAVA/bin/java" -jar "@INSTALL_PATH/Uninstaller/uninstaller.jar" &
fi

MAIN_PID=$!

wait $MAIN_PID 2>/dev/null

while GUI_PID=$(pgrep -f "$TEMP_JAVA/bin/java"); do
    wait $GUI_PID 2>/dev/null || sleep 1
done
