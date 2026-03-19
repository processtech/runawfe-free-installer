#!/bin/sh
LOGDIR="\$HOME/.local/runawfe-notifier"
mkdir -p "\$LOGDIR"
"@java.executable" -Dorg.eclipse.swt.browser.UseWebKitGTK=true -Drtn.log.dir="\$LOGDIR" -cp "@INSTALL_PATH/@rtn.subpath/rtn.jar" ru.runa.notifier.PlatformLoader