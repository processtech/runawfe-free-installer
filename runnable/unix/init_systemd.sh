#!/bin/sh
set -e

SERVICE_NAME="runawfe-server-@WFE.version@"
LOG_DIR="/var/log/$SERVICE_NAME"
SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME.service"

if ! pidof systemd > /dev/null; then
    echo "Systemd not found, skipping service setup."
    exit 0
fi

if ! id runawfe >/dev/null 2>&1; then
    useradd -r -M -d "@INSTALL_PATH@/@appserver.subpath@" runawfe
    chown -R runawfe:runawfe "@INSTALL_PATH@"
fi

mkdir -p $LOG_DIR
chown -R runawfe $LOG_DIR

if [ ! -f "$SERVICE_FILE" ]; then
    echo "Warning: Service file $SERVICE_FILE not found. Service may not have been installed."
else
    systemctl daemon-reload
    systemctl enable "$SERVICE_NAME" > /dev/null 2>&1
    systemctl start "$SERVICE_NAME"
fi
