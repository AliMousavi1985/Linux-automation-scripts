#!/bin/bash

echo "=========================================="
echo "       SUDO & USER ACCESS AUDIT"
echo "=========================================="
echo ""

echo "[1] Users with Sudo/Admin Privileges:"
# Checking users in wheel or sudo group, or users with sudoers configuration
grep -Po '^^\w+(?=:) /etc/passwd' | while read -r user; do
    if groups "$user" | grep -E -q '\b(sudo|wheel)\b'; then
        echo " - $user (Has Sudo Group Access)"
    fi
done

echo ""
echo "[2] Recently Created Users (Last 10 entries in passwd):"
tail -n 10 /etc/passwd | awk -F: '{print " - " $1 " (UID: " $3 ", Home: " $6 ")"}'

echo ""
echo "=========================================="
