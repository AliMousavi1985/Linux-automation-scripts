#!/bin/bash

# ==========================================================
# User & Sudo Security Audit Script
# ==========================================================

CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
RESET='\033[0m'

clear
echo -e "${CYAN}=== SYSTEM USER & SECURITY AUDIT ===${RESET}"
echo

# 1. Check Sudoers
echo -e "${CYAN}[1] Users with Sudo/Root Privileges:${RESET}"
grep -Po '^^([a-zA-Z0-9_-]+)(?=:.*(sudo|wheel))' /etc/group 2>/dev/null | while read -r group; do
    echo "  - Group $group members:"
    getent group "$group" | awk -F: '{print "    • " $4}'
done
echo

# 2. Check users with empty passwords
echo -e "${CYAN}[2] Checking for empty password accounts:${RESET}"
EMPTY_PW=$(awk -F: '($2 == "" ) {print $1}' /etc/shadow 2>/dev/null)
if [ -z "$EMPTY_PW" ]; then
    echo -e "  ${GREEN}✓${RESET} No users with empty passwords found."
else
    echo -e "  ${RED}✗ WARNING:${RESET} Users with empty passwords: $EMPTY_PW"
fi
echo
