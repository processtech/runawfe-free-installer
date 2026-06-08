#!/bin/sh
cd "$(dirname "$0")"
if [ -f "../install_desktop_shortcut.sh" ]; then
    ../install_desktop_shortcut.sh "@ds.shortcut.name"
    ../install_desktop_shortcut.sh "@server.shortcut.name"
fi
exec ./runa-gpd -data "$HOME/RunaWFEWorkspace"