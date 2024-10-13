#!/bin/bash
# Cloudflare API details
API_TOKEN="your_token" # Replace with your Cloudflare API token
ZONE_ID="Zone_ID" # Zone ID for domain.com
RECORD_ID="Record_ID" # Record ID for ns.domain.com
RECORD_TYPE="A"
PROXIED=false

# The domain you're updating
DOMAIN="domain.com"

# File to store the last known IP address
IP_FILE="./last_known_ip.txt" # Replace with the path where you want to store the file

# Get current external IP address of the homelab server
CURRENT_IP=$(curl -s http://ipinfo.io/ip)

# Check if the IP file exists, and read the stored IP from the file
if [ -f "$IP_FILE" ]; then
    STORED_IP=$(cat "$IP_FILE")
else
    STORED_IP=""
fi

# Compare the current IP with the stored IP
if [ "$CURRENT_IP" = "$STORED_IP" ]; then
    echo "IP address ($CURRENT_IP) hasn't changed. No update needed."
    exit 0
fi

# Update the DNS record on Cloudflare
UPDATE=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" \
     -H "Authorization: Bearer $API_TOKEN" \
     -H "Content-Type: application/json" \
     --data "{\"type\":\"$RECORD_TYPE\",\"name\":\"$DOMAIN\",\"content\":\"$CURRENT_IP\",\"ttl\":1,\"proxied\":$PROXIED}")

# Check if the update was successful
if echo "$UPDATE" | grep -q '"success":true'; then
    echo "DNS record updated successfully to $CURRENT_IP"

    # Store the new IP in the file
    echo "$CURRENT_IP" > "$IP_FILE"
else
    echo "Failed to update DNS record"
    echo "$UPDATE"
    exit 1
fi
