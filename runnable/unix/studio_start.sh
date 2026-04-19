#!/bin/sh
cd "$(dirname "$0")"
if [ -f "../install_desktop_shortcut.sh" ]; then
    ../install_desktop_shortcut.sh "Developer studio"
fi
exec ./runa-gpd -data "$HOME/RunaWFEWorkspace"