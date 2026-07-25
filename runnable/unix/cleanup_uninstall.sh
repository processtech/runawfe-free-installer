#!/bin/sh

if [ -d "@appdata.install.path" ]; then
    rm -rf "@appdata.install.path" 2>/dev/null || true
fi