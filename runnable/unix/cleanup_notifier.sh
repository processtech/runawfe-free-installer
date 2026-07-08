#!/bin/sh

if [ -d "@rtn.properties.folder" ]; then
    rm -rf "@rtn.properties.folder" 2>/dev/null || true
fi

rm -f "/etc/xdg/autostart/@{rtn.shortcut.name}.desktop"

rm -rf "$HOME/@rtn.log.dir" 2>/dev/null || true

if [ -f "@INSTALL_PATH/install_desktop_shortcut.sh" ]; then
    "@INSTALL_PATH/install_desktop_shortcut.sh" "@rtn.shortcut.name" --delete
fi

exit 0