#!/bin/sh

if [ -f "@INSTALL_PATH/install_desktop_shortcut.sh" ]; then
    "@INSTALL_PATH/install_desktop_shortcut.sh" "@simstart.shortcut.name" --delete
    "@INSTALL_PATH/install_desktop_shortcut.sh" "@simstop.shortcut.name" --delete
    "@INSTALL_PATH/install_desktop_shortcut.sh" "@simulator.shortcut.name" --delete
fi