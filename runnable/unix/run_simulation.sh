#!/bin/sh

JAVA_HOME="@java.path"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

JBOSS_LOG_DIR="$XDG_STATE_HOME/@simulator.jboss.log.subdir"
JBOSS_TEMP_DIR="$XDG_CACHE_HOME/@APP_NAME/jboss/tmp"

if [ -f "@INSTALL_PATH/install_desktop_shortcut.sh" ]; then
    "@INSTALL_PATH/install_desktop_shortcut.sh" "@simstart.shortcut.name"
    "@INSTALL_PATH/install_desktop_shortcut.sh" "@simstop.shortcut.name"
    "@INSTALL_PATH/install_desktop_shortcut.sh" "@simulator.shortcut.name"
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