#!/bin/bash
FREE_RAM=$(free -m | awk 'NR==2 {print $4}')
TOTAL_RAM=$(free -m | awk 'NR==2 {print $2}')
echo "Total RAM: ${TOTAL_RAM}MB | Free RAM: ${FREE_RAM}MB"

if [ "$FREE_RAM" -lt 500 ]; then
    echo "WARNING: Low available memory!"
else
    echo "Memory usage is optimal."
fi
