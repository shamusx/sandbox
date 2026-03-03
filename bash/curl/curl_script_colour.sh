#!/bin/bash

# Get the name of the pod with the label app=sleep in the sleep namespace
CURL_POD_NAME=$(kubectl get pods -l app=sleep -n sleep -o jsonpath='{.items[0].metadata.name}')

# Initialize the counter
COUNTER=0

# Infinite loop to perform the curl command at specified intervals
while true; do
  # Perform the curl command every 5 seconds
  if (( COUNTER % 5 == 0 )); then
    # Execute the curl command inside the sleep container of the sleep pod
    RESPONSE=$(kubectl exec $CURL_POD_NAME -n sleep -c sleep -- curl -sS -I httpbingo.httpbin:80/status/200)
    # Check if the response contains "200 OK"
    if echo "$RESPONSE" | grep -q "200 OK"; then
      # Print the response in green color if it contains "200 OK"
      echo -e "\e[32mResponse from curl_every_5_seconds: $RESPONSE\e[0m"
    else
      # Print the response without color if it does not contain "200 OK"
      echo "Response from curl_every_5_seconds: $RESPONSE"
    fi
  fi

  # Sleep for 1 second before the next iteration
  sleep 1
  # Increment the counter
  COUNTER=$((COUNTER + 1))
done
