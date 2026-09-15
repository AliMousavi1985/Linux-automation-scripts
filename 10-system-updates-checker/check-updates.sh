#!/bin/bash
if command -v apt &> /dev/null; then
    UPDATES=$(apt-get -s upgrade | grep -i "upgraded," | awk '{print $1}')
    echo "Available security/package updates: $UPDATES"
else
    echo "Package manager not supported by this script."
fi
