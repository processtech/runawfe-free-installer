#!/bin/sh
cd "$(dirname "$0")"
if [ -f "../install_desktop_shortcut.sh" ]; then
    ../install_desktop_shortcut.sh "@rtn.shortcut.name"
    ../install_desktop_shortcut.sh "@server.shortcut.name"
fi
LOGDIR="$HOME/@rtn.log.dir"
mkdir -p "$LOGDIR"
"@java.executable" -Dorg.eclipse.swt.browser.UseWebKitGTK=true -Drtn.log.dir="$LOGDIR" -cp "@INSTALL_PATH/@rtn.subpath/rtn.jar" ru.runa.notifier.PlatformLoader