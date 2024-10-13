#!/bin/bash

# Cloudflare API details
API_TOKEN="your_api_token" # Replace with your Cloudflare API token
ZONE_ID="zone_id" # Zone ID for binjuhor.com
RECORD_ID="record_id" # Record ID for ns.binjuhor.com
RECORD_TYPE="A"
PROXIED=false


# The domain you're updating
DOMAIN="ns.binjuhor.com"

# Get current external IP address of the homelab server
CURRENT_IP=$(curl -s http://ipinfo.io/ip)

# Fetch the current DNS record from Cloudflare
CLOUDFLARE_RECORD=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" \
     -H "Authorization: Bearer $API_TOKEN" \
     -H "Content-Type: application/json")

# Extract the IP currently set in Cloudflare for ns.binjuhor.com
OLD_IP=$(echo "$CLOUDFLARE_RECORD" | jq -r '.result.content')

# Compare the current IP with the IP in Cloudflare
if [ "$CURRENT_IP" = "$OLD_IP" ]; then
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
else
    echo "Failed to update DNS record"
    echo "$UPDATE"
    exit 1
fi
