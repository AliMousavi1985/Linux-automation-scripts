#!/bin/bash

LOG_FILE="/var/log/syslog"

# Fallback to messages log if syslog doesn't exist (e.g., on RHEL/CentOS)
if [ ! -f "$LOG_FILE" ]; then
    LOG_FILE="/var/log/messages"
fi

echo "=========================================="
echo "       LOG ERROR HUNTER (Last 10 Errors)"
echo "=========================================="

if [ -f "$LOG_FILE" ]; then
    sudo grep -i -E "error|failed|crit" "$LOG_FILE" | tail -n 10
else
    echo "System log file not found."
fi

echo "=========================================="
