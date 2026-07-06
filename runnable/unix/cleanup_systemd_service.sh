#!/bin/sh

SERVICE_NAME="@jboss.servicename@"
LOG_DIR="@jboss.log.dir@"
SERVICE_FILE="@jboss.service.file@"

systemctl stop "$SERVICE_NAME" 2>/dev/null || true
systemctl disable "$SERVICE_NAME" 2>/dev/null || true
rm -f "$SERVICE_FILE" 2>/dev/null || true
rm -rf "$LOG_DIR" 2>/dev/null || true
systemctl daemon-reload 2>/dev/null || true
