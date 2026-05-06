#!/bin/sh

JAVA_HOME="@java.path"
JBOSS_LOG_DIR="$XDG_RUNTIME_DIR/@APP_NAME/jboss/log"
JBOSS_TEMP_DIR="$XDG_RUNTIME_DIR/@APP_NAME/jboss/tmp"

if [ -f "@INSTALL_PATH/install_desktop_shortcut.sh" ]; then
    "@INSTALL_PATH/install_desktop_shortcut.sh" "Start simulation"
    "@INSTALL_PATH/install_desktop_shortcut.sh" "Stop simulation"
    "@INSTALL_PATH/install_desktop_shortcut.sh" "Simulator web interface"
fi

mkdir -p "@appdata.install.path/jboss"
mkdir -p "$JBOSS_LOG_DIR"
mkdir -p "$JBOSS_TEMP_DIR"

rm -rf "@appdata.install.path/jboss/configuration"
rm -rf "@appdata.install.path/jboss/deployments"
rm -rf "@appdata.install.path/jboss/wfe.custom"
rm -rf "@appdata.install.path/jboss/wfe.data-sources"

cp -Rp "@standalone.path/configuration" "@appdata.install.path/jboss/"
cp -Rp "@standalone.path/deployments" "@appdata.install.path/jboss/"
cp -Rp "@standalone.path/wfe.custom" "@appdata.install.path/jboss/"
cp -Rp "@standalone.path/wfe.data-sources" "@appdata.install.path/jboss/"

if [ ! -d "@appdata.install.path/jboss/data" ]; then
    mkdir -p "@appdata.install.path/jboss/data"
    cp -Rp "@standalone.path/data/demo-db" "@appdata.install.path/jboss/data/h2"
fi

cd "@INSTALL_PATH/@appserver.subpath/bin"
export JAVA_HOME
./standalone.sh -Djboss.server.log.dir="$JBOSS_LOG_DIR" -Djboss.server.temp.dir="$JBOSS_TEMP_DIR" -Djboss.server.base.dir="@appdata.install.path/jboss"