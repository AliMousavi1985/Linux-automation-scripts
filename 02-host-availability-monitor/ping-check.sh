#!/bin/bash
TARGET="8.8.8.8"
if ping -c 3 "$TARGET" > /dev/null 2>&1; then
    echo "Host $TARGET is reachable."
else
    echo "ALERT: Host $TARGET is down!"
fi
