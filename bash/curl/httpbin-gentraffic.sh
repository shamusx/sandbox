#!/bin/bash

# Continuous traffic generation loop
REQUEST_COUNT=0
SUCCESS_COUNT=0
ERROR_COUNT=0

GATEWAY=$(kubectl get svc external-gateway -n tetrate-system -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# Define the hostname and paths
HOSTNAME="httpbin.sandbox.tetrate.io"
PATHS=(
  "/"
  "/productpage"
  "/get"
  "/uuid"
  "/user-agent"
  "/headers"
  "/ip"
  "/delay/1"
  "/delay/2"
  "/delay/3"
  "/drip?duration=1&numbytes=5&code=200"
  "/base64/SFRUUEJJTiBpcyBhd2Vzb21l"
  "/json"
  "/html"
  "/xml"
  "/robots.txt"
  "/cache"
  "/cache/60"
  "/bytes/1024"
  "/stream-bytes/1024"
  "/links/10"
  "/image"
  "/image/jpeg"
  "/image/png"
  "/image/svg"
  "/image/webp"
  "/status/200"
  "/status/404"
  "/status/500"
)

while true; do
  REQUEST_COUNT=$((REQUEST_COUNT + 1))

  printf "───────────────────────────────────────────\n"
  printf "📊 Request #%d | ✅ Success: %d | ❌ Errors: %d\n\n" "$REQUEST_COUNT" "$SUCCESS_COUNT" "$ERROR_COUNT"

  # Randomly select a path
  RANDOM_PATH=${PATHS[$RANDOM % ${#PATHS[@]}]}
  
  printf "🌐 Testing: %s\n" "$RANDOM_PATH"
  HTTP_CODE=$(curl -s -k -o /dev/null -w "%{http_code}" -H "x-b3-sampled: 1" "https://$HOSTNAME$RANDOM_PATH" 2>&1)
  
  if [[ "$HTTP_CODE" =~ ^[2-3][0-9][0-9]$ ]]; then
    printf "   ✅ %s\n" "$HTTP_CODE"
    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
  else
    printf "   ❌ %s\n" "$HTTP_CODE"
    ERROR_COUNT=$((ERROR_COUNT + 1))
  fi

  printf "\n"

  # Wait 2 seconds before next request
  sleep 2
done
