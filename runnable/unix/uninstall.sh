#!/bin/sh

TEMP_JAVA="$(mktemp -d /tmp/RunaWFE_uninstall_java_XXXXXX)"
trap 'RC=$?; rm -rf "$TEMP_JAVA"; exit $RC' EXIT INT TERM HUP

cp -Rp "@java.path"/* "$TEMP_JAVA/"
"$TEMP_JAVA/bin/java" -jar "@INSTALL_PATH/Uninstaller/uninstaller.jar"