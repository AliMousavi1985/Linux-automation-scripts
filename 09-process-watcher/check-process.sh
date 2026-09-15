#!/bin/bash
PROC_NAME="sshd"

if pgrep -x "$PROC_NAME" > /dev/null; then
    echo "Process $PROC_NAME is running smoothly."
else
    echo "ALERT: Process $PROC_NAME is NOT running!"
fi
