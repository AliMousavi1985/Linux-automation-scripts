#!/bin/bash
LOG_FILE="/var/log/named_status.log"
netstat -nlu | grep :53 | grep -v udp6 > /dev/null
named_status=$?
current_date=$(date +%F-%H:%M:%S)
sudo mkdir -p /var/log

if [ $named_status -eq 0 ]; then
    echo "DNS service is running correctly - $current_date" >> "$LOG_FILE"
else
    echo "DNS service is stopped - $current_date" >> "$LOG_FILE"
fi
