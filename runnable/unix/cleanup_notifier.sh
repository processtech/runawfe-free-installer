#!/bin/sh

if [ -d "$rtn.properties.folder" ]; then
    rm -rf "$rtn.properties.folder" 2>/dev/null || true
fi
exit 0