#!/bin/bash

# ==========================================================
# Simple & Human-Friendly Server Health Check
# Compatible with Debian/Ubuntu & RHEL/CentOS/Rocky
# ==========================================================

# Colors for readability
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

clear
echo -e "${CYAN}=== SERVER HEALTH & SERVICES CHECK ===${RESET}"
echo "Hostname : $(hostname)"
echo "Date     : $(date)"
echo

# ----------------------------------------------------------
# 1. Check Core Services Status
# ----------------------------------------------------------
echo -e "${CYAN}[1] Core Services Status${RESET}"

# List of important services to check (adjust as needed)
SERVICES=("nginx" "apache2" "named" "bind9" "dhcpd" "isc-dhcp-server" "ntp" "chrony" "sshd")

for srv in "${SERVICES[@]}"; do
    if systemctl list-unit-files | grep -q "^${srv}\.service"; then
        if systemctl is-active --quiet "$srv"; then
            echo -e "  ${GREEN}✓${RESET} $srv is running"
        else
            echo -e "  ${RED}✗${RESET} $srv is STOPPED or failed"
        fi
    fi
done
echo

# ----------------------------------------------------------
# 2. Check SSL Certificate Expiry (Optional Domain/File)
# ----------------------------------------------------------
echo -e "${CYAN}[2] SSL Certificate Check${RESET}"

# Change this to your domain or local certificate path if you have one
SSL_DOMAIN="example.com" 

if command -v openssl >/dev/null 2>&1; then
    # Checking via network domain as an example
    EXPIRY_DATE=$(echo | openssl s_client -servername "$SSL_DOMAIN" -connect "$SSL_DOMAIN:443" 2>/dev/null | openssl x509 -noout -enddate 2>/dev/null | cut -d= -f2)
    
    if [ -n "$EXPIRY_DATE" ]; then
        EXPIRY_EPOCH=$(date -d "$EXPIRY_DATE" +%s 2>/dev/null || date -j -f "%b %d %T %Y %Z" "$EXPIRY_DATE" +%s 2>/dev/null)
        CURRENT_EPOCH=$(date +%s)
        DAYS_LEFT=$(( (EXPIRY_EPOCH - CURRENT_EPOCH) / 86400 ))

        if [ "$DAYS_LEFT" -lt 15 ]; then
            echo -e "  ${RED}✗${RESET} SSL Certificate for $SSL_DOMAIN expires in $DAYS_LEFT days! ($EXPIRY_DATE)"
        elif [ "$DAYS_LEFT" -lt 30 ]; then
            echo -e "  ${YELLOW}!${RESET} SSL Certificate for $SSL_DOMAIN expires soon: $DAYS_LEFT days left."
        else
            echo -e "  ${GREEN}✓${RESET} SSL Certificate for $SSL_DOMAIN is valid ($DAYS_LEFT days remaining)."
        fi
    else
        echo -e "  ${YELLOW}•${RESET} Could not check SSL for $SSL_DOMAIN (Domain not reachable or offline check needed)."
    fi
else
    echo -e "  ${YELLOW}•${RESET} 'openssl' command not found."
fi
echo

# ----------------------------------------------------------
# 3. Open Listening Ports & Associated Services
# ----------------------------------------------------------
echo -e "${CYAN}[3] Active Listening Ports${RESET}"

if command -v ss >/dev/null 2>&1; then
    # Shows listening ports clearly with process names if possible (-p requires root)
    ss -tulpn | awk 'NR==1 || /LISTEN/' | sed 's/^/  /'
else
    echo -e "  ${YELLOW}•${RESET} 'ss' command not available."
fi

echo
echo -e "${CYAN}=== Check Complete ===${RESET}"
