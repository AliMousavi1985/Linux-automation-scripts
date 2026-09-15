#!/bin/bash
TARGET_FILE="/etc/passwd"
BASELINE_FILE="/tmp/passwd_baseline.md5"

if [ ! -f "$BASELINE_FILE" ]; then
    md5sum "$TARGET_FILE" | awk '{print $1}' > "$BASELINE_FILE"
    echo "Baseline created for $TARGET_FILE"
    exit 0
fi

CURRENT_HASH=$(md5sum "$TARGET_FILE" | awk '{print $1}')
SAVED_HASH=$(cat "$BASELINE_FILE")
current_date=$(date +%F-%H:%M:%S)

if [ "$CURRENT_HASH" == "$SAVED_HASH" ]; then
    echo "File integrity OK: $TARGET_FILE has not changed - $current_date"
else
    echo "ALERT: $TARGET_FILE has been modified! - $current_date"
fi
