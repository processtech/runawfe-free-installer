#!/bin/sh
cd "$(dirname "$0")"
if [ -f "../install_desktop_shortcut.sh" ]; then
    ../install_desktop_shortcut.sh "Task notifier"
fi
LOGDIR="\$HOME/.local/runawfe-notifier"
mkdir -p "\$LOGDIR"
"@java.executable" -Dorg.eclipse.swt.browser.UseWebKitGTK=true -Drtn.log.dir="\$LOGDIR" -cp "@INSTALL_PATH/@rtn.subpath/rtn.jar" ru.runa.notifier.PlatformLoader