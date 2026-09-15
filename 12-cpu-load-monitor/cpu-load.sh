#!/bin/bash
LOAD=$(uptime | awk -F'load average:' '{ print $2 }' | cut -d, -f1 | tr -d ' ')
echo "Current 1-minute CPU Load Average is: $LOAD"
