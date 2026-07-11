#!/bin/sh

if [ -f "@INSTALL_PATH/install_desktop_shortcut.sh" ]; then
    "@INSTALL_PATH/install_desktop_shortcut.sh" "@simstart.shortcut.name" --delete
    "@INSTALL_PATH/install_desktop_shortcut.sh" "@simstop.shortcut.name" --delete
    "@INSTALL_PATH/install_desktop_shortcut.sh" "@simulator.shortcut.name" --delete
fi

XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
rm -rf "$XDG_STATE_HOME/@simulator.jboss.log.subdir" 2>/dev/null || true