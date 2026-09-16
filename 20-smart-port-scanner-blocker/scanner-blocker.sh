#!/bin/bash

# Ensure script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "[-] Please run as root (sudo)."
  exit 1
fi

# File to track offender IPs and their hit counts
TRACK_FILE="/var/log/nmap_offenders.log"
touch "$TRACK_FILE"

# Simulated or captured attacker IP
ATTACKER_IP="192.168.1.50" 

if [ -z "$ATTACKER_IP" ]; then
    exit 0
fi

# Count previous offenses
COUNT=$(grep -c "$ATTACKER_IP" "$TRACK_FILE")

if [ "$COUNT" -eq 0 ]; then
    # --- First Offense: Temporary Block (4 Hours) ---
    echo "$ATTACKER_IP" >> "$TRACK_FILE"
    iptables -A INPUT -s "$ATTACKER_IP" -j DROP

    # Release after 4 hours (14400 seconds) in the background
    (sleep 14400 && iptables -D INPUT -s "$ATTACKER_IP" -j DROP 2>/dev/null) &

    echo "[!] IP $ATTACKER_IP blocked temporarily for 4 hours (First offense)."

else
    # --- Second Offense and Beyond: Permanent Block ---
    echo "$ATTACKER_IP" >> "$TRACK_FILE"

    # Remove any existing temporary rule and apply permanent drop
    iptables -D INPUT -s "$ATTACKER_IP" -j DROP 2>/dev/null
    iptables -A INPUT -s "$ATTACKER_IP" -j DROP

    echo "[X] IP $ATTACKER_IP is now PERMANENTLY blocked (Repeat offender)."
fi
