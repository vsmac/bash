#!/bin/bash

# Usage: ./compare_latency.sh https://staging.example.com https://prod.example.com

if [ $# -ne 2 ]; then
  echo "Usage: $0 <staging-url> <prod-url>"
  exit 1
fi

STAGING=$1
PROD=$2

echo "🔎 Comparing Latency for:"
echo "Staging: $STAGING"
echo "Prod:    $PROD"
echo "-----------------------------------"

function test_url() {
  URL=$1
  echo "👉 Testing $URL"
  TIMES=$(curl -o /dev/null -s -w "%{time_namelookup} %{time_connect} %{time_appconnect} %{time_starttransfer} %{time_total}\n" "$URL")
  echo "$TIMES" | awk '{printf "DNS: %.0fms | Connect: %.0fms | SSL: %.0fms | TTFB: %.0fms | Total: %.0fms\n", $1*1000, $2*1000, $3*1000, $4*1000, $5*1000}'
  echo ""
}

test_url $STAGING
test_url $PROD
