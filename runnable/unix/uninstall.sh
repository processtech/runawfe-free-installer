#!/bin/sh

TEMP_JAVA="$(mktemp -d /tmp/RunaWFE_uninstall_java_XXXXXX)"
cp -Rp "@java.path"/* "$TEMP_JAVA/"
exec "$TEMP_JAVA/bin/java" -jar "@INSTALL_PATH/Uninstaller/uninstaller.jar"