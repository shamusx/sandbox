#!/usr/bin/env bash

HOST="dynabank.com"
URL="http://172.171.142.173/"
INTERVAL=5  # seconds between checks

echo "Checking $HOST every $INTERVAL seconds..."
echo "-------------------------------------------"

while true; do
  STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" -H "Host: $HOST" "$URL")
  TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
  echo "[$TIMESTAMP] Host: $HOST | Status: $STATUS_CODE"
  sleep $INTERVAL
done