#!/bin/sh
cd "$(dirname "$0")"
if [ -f "../install_desktop_shortcut.sh" ]; then
    ../install_desktop_shortcut.sh "Task notifier"
    ../install_desktop_shortcut.sh "Server web interface"
fi
LOGDIR="\$HOME/.local/@rtn.appname"
mkdir -p "\$LOGDIR"
"@java.executable" -Dorg.eclipse.swt.browser.UseWebKitGTK=true -Drtn.log.dir="\$LOGDIR" -cp "@INSTALL_PATH/@rtn.subpath/rtn.jar" ru.runa.notifier.PlatformLoader