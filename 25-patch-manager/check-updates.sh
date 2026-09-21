#!/bin/bash

# ==========================================================
# System Security Updates Checker
# ==========================================================

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RESET='\033[0m'

clear
echo -e "${CYAN}=== SYSTEM UPDATE & PATCH CHECKER ===${RESET}"

if command -v apt-get >/dev/null 2>&1; then
    # Debian / Ubuntu
    sudo apt-get update -qq >/dev/null 2>&1
    UPDATES=$(apt-get -s upgrade | grep -i "upgraded," | awk '{print $1}')
    
    if [ "$UPDATES" -gt 0 ]; then
        echo -e "  ${YELLOW}!${RESET} There are $UPDATES package updates available."
    else
        echo -e "  ${GREEN}✓${RESET} System is fully up to date."
    fi

elif command -v dnf >/dev/null 2>&1; then
    # RHEL / Rocky / AlmaLinux
    UPDATES=$(dnf check-update -q | grep -v "^$" | wc -l)
    
    if [ "$UPDATES" -gt 0 ]; then
        echo -e "  ${YELLOW}!${RESET} There are updates available."
        dnf check-update -q
    else
        echo -e "  ${GREEN}✓${RESET} System is fully up to date."
    fi
else
    echo -e "  ${YELLOW}•${RESET} Package manager not recognized."
fi
echo
