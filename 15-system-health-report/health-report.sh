#!/bin/bash

# Define report file path
REPORT_FILE="/tmp/system_health_report.txt"
current_date=$(date "+%Y-%m-%d %H:%M:%S")

{
    echo "=========================================="
    echo "       SYSTEM HEALTH REPORT"
    echo "       Generated on: $current_date"
    echo "=========================================="
    echo ""
    
    echo "[1] UPTIME & LOAD AVERAGE:"
    uptime
    echo ""
    
    echo "[2] MEMORY USAGE:"
    free -h
    echo ""
    
    echo "[3] DISK USAGE (Root Partition):"
    df -h / | awk 'NR==1 || NR==2'
    echo ""
    
    echo "[4] TOP 3 CPU CONSUMING PROCESSES:"
    ps -eo pid,ppid,cmd,%cpu --sort=-%cpu | head -n 4
    echo ""
    
    echo "=========================================="
    echo "       REPORT COMPLETED SUCCESSFULLY"
    echo "=========================================="
} > "$REPORT_FILE"

# Print the report to the terminal as well
cat "$REPORT_FILE"
echo ""
echo "Report successfully saved to $REPORT_FILE"
