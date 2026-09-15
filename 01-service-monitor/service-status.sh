#!/bin/bash
SERVICE="nginx"
if systemctl is-active --quiet "$SERVICE"; then
    echo "Service $SERVICE is running."
else
    echo "Service $SERVICE is NOT running!"
    systemctl restart "$SERVICE"
fi
