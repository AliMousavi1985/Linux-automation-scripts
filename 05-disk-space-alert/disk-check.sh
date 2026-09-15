#!/bin/bash
THRESHOLD=85
CURRENT_USAGE=$(df / | grep / | awk '{print $5}' | sed 's/%//g')

if [ "$CURRENT_USAGE" -gt "$THRESHOLD" ]; then
    echo "WARNING: Disk space is critically high! Usage is at ${CURRENT_USAGE}%"
else
    echo "Disk space is normal: ${CURRENT_USAGE}%"
fi
