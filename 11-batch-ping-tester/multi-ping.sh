#!/bin/bash
SERVERS=("8.8.8.8" "1.1.1.1" "192.168.1.1")

for ip in "${SERVERS[@]}"; do
    if ping -c 1 -w 2 "$ip" > /dev/null 2>&1; then
        echo "[UP] Server $ip is online."
    else
        echo "[DOWN] Server $ip is unreachable."
    fi
done
