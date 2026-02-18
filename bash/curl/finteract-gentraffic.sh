
# Continuous traffic generation loop
REQUEST_COUNT=0
SUCCESS_COUNT=0
ERROR_COUNT=0

GATEWAY=$(kubectl get svc external-gateway -n tetrate-system -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

while true; do
  REQUEST_COUNT=$((REQUEST_COUNT + 1))

  printf "───────────────────────────────────────────\n"
  printf "📊 Request #%d | ✅ Success: %d | ❌ Errors: %d\n\n" "$REQUEST_COUNT" "$SUCCESS_COUNT" "$ERROR_COUNT"

  # Test 1: List all clients
  printf "👥 Clients...\n"
  HTTP_CODE=$(curl -s -k -o /dev/null -w "%{http_code}" --resolve "fineract.dynabank.com:443:$GATEWAY" -u mifos:password -H "Fineract-Platform-TenantId: default" -H "Host: fineract.dynabank.com" "https://fineract.dynabank.com/fineract-provider/api/v1/clients" 2>&1)
  if [ "$HTTP_CODE" = "200" ]; then
    printf "   ✅ %s\n" "$HTTP_CODE"
    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
  else
    printf "   ❌ %s\n" "$HTTP_CODE"
    ERROR_COUNT=$((ERROR_COUNT + 1))
  fi

  # Test 2: List all loans
  printf "💰 Loans...\n"
  HTTP_CODE=$(curl -s -k -o /dev/null -w "%{http_code}" --resolve "fineract.dynabank.com:443:$GATEWAY" -u mifos:password -H "Fineract-Platform-TenantId: default" -H "Host: fineract.dynabank.com" "https://fineract.dynabank.com/fineract-provider/api/v1/loans" 2>&1)
  if [ "$HTTP_CODE" = "200" ]; then
    printf "   ✅ %s\n" "$HTTP_CODE"
    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
  else
    printf "   ❌ %s\n" "$HTTP_CODE"
    ERROR_COUNT=$((ERROR_COUNT + 1))
  fi

  # Test 3: List all savings accounts
  printf "💵 Savings...\n"
  HTTP_CODE=$(curl -s -k -o /dev/null -w "%{http_code}" --resolve "fineract.dynabank.com:443:$GATEWAY" -u mifos:password -H "Fineract-Platform-TenantId: default" -H "Host: fineract.dynabank.com" "https://fineract.dynabank.com/fineract-provider/api/v1/savingsaccounts" 2>&1)
  if [ "$HTTP_CODE" = "200" ]; then
    printf "   ✅ %s\n" "$HTTP_CODE"
    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
  else
    printf "   ❌ %s\n" "$HTTP_CODE"
    ERROR_COUNT=$((ERROR_COUNT + 1))
  fi

  # Test 4: List all offices
  printf "🏢 Offices...\n"
  HTTP_CODE=$(curl -s -k -o /dev/null -w "%{http_code}" --resolve "fineract.dynabank.com:443:$GATEWAY" -u mifos:password -H "Fineract-Platform-TenantId: default" -H "Host: fineract.dynabank.com" "https://fineract.dynabank.com/fineract-provider/api/v1/offices" 2>&1)
  if [ "$HTTP_CODE" = "200" ]; then
    printf "   ✅ %s\n" "$HTTP_CODE"
    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
  else
    printf "   ❌ %s\n" "$HTTP_CODE"
    ERROR_COUNT=$((ERROR_COUNT + 1))
  fi

  printf "\n"

  # Wait 5 seconds before next batch
  sleep 5
done
