#!/bin/bash
echo "Currently logged-in users:"
who
USER_COUNT=$(who | wc -l)
echo "Total active sessions: $USER_COUNT"
