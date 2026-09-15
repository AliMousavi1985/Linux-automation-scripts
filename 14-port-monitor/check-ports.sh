#!/bin/bash

# Port Monitoring Script
PORTS=(22 80 443 3306)

echo "[*] Checking listening ports..."
for port in "${PORTS[@]}"; do
    if ss -tulpn | grep -q ":$port "; then
        echo "[✔] Port $port is ACTIVE and listening."
    else
        echo "[-] WARNING: Port $port is NOT listening!"
    fi
done
