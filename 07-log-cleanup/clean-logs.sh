#!/bin/bash
LOG_DIR="/var/log/myapp"
DAYS=7

if [ -d "$LOG_DIR" ]; then
    find "$LOG_DIR" -type f -name "*.log" -mtime +$DAYS -exec rm -f {} \;
    echo "Old log files older than $DAYS days have been cleaned up."
else
    echo "Log directory does not exist."
fi
