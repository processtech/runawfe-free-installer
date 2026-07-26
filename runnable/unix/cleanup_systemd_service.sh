#!/bin/sh

SERVICE_NAME="@jboss.servicename@"
LOG_DIR="@server.jboss.log.dir@"
SERVICE_FILE="@jboss.service.file@"

systemctl stop "$SERVICE_NAME" 2>/dev/null || true
systemctl disable "$SERVICE_NAME" 2>/dev/null || true
rm -f "$SERVICE_FILE" 2>/dev/null || true
rm -rf "$LOG_DIR" 2>/dev/null || true

if id runawfe >/dev/null 2>&1; then
    userdel runawfe 2>/dev/null || true
fi

systemctl daemon-reload 2>/dev/null || true
