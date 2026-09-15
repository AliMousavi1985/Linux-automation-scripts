#!/bin/bash

DOMAIN="google.com"
PORT="443"

echo "Checking SSL Certificate expiration for: $DOMAIN"

# Get expiration date using openssl
EXPIRY_DATE=$(echo | openssl s_client -connect "$DOMAIN:$PORT" -servername "$DOMAIN" 2>/dev/null | openssl x509 -noout -enddate | cut -d= -f2)

if [ -z "$EXPIRY_DATE" ]; then
    echo "ERROR: Could not retrieve SSL certificate for $DOMAIN."
    exit 1
fi

echo "Certificate expires on: $EXPIRY_DATE"
