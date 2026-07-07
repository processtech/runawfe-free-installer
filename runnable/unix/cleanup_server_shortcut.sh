#!/bin/sh

if [ -f "@INSTALL_PATH/install_desktop_shortcut.sh" ]; then
    "@INSTALL_PATH/install_desktop_shortcut.sh" "@server.shortcut.name" --delete
fi