#!/bin/bash
SRC_DIR="/etc"
DEST_DIR="/backup"
DATE=$(date +%F)
BACKUP_FILE="$DEST_DIR/etc_backup_$DATE.tar.gz"

sudo mkdir -p "$DEST_DIR"
sudo tar -czf "$BACKUP_FILE" "$SRC_DIR" 2>/dev/null

if [ $? -eq 0 ]; then
    echo "Backup created successfully: $BACKUP_FILE"
else
    echo "Backup failed!"
fi
