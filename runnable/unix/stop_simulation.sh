#!/bin/sh

JAVA_HOME="@java.path"
export JAVA_HOME

"@INSTALL_PATH/@appserver.subpath/bin/jboss-cli.sh" --connect --controller=localhost:@jboss.management.http.port --command=:shutdown 2>/dev/null


if [ $? -eq 0 ]; then
    echo "Симулятор остановлен."
else
    echo "Не удалось остановить симулятор. Возможно, он не запущен."
fi