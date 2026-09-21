#!/bin/bash

# ==========================================================
# Smart Local Backup & Retention Script
# ==========================================================

CYAN='\033[0;36m'
GREEN='\033[0;32m'
RESET='\033[0m'

BACKUP_DIR="/var/backups/myserver"
TARGET_DIR="/etc"
DATE=$(date +%Y%m%d_%H%M%S)
FILENAME="backup-etc-$DATE.tar.gz"

mkdir -p "$BACKUP_DIR"

clear
echo -e "${CYAN}=== SMART BACKUP UTILITY ===${RESET}"

echo -e "  • Creating backup from $TARGET_DIR..."
tar -czf "$BACKUP_DIR/$FILENAME" "$TARGET_DIR" 2>/dev/null

if [ $? -eq 0 ]; then
    echo -e "  ${GREEN}✓${RESET} Backup created successfully: $FILENAME"
else
    echo -e "  ${RED}✗${RESET} Backup failed!"
fi

# (Retention Policy)
echo -e "  • Cleaning up backups older than 7 days..."
find "$BACKUP_DIR" -name "backup-etc-*.tar.gz" -mtime +7 -exec rm -f {} \;

echo -e "  ${GREEN}✓${RESET} Retention policy applied. Process complete."
echo
