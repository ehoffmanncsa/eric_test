#!/bin/bash
# Check and wait for Selenium Grid connection

echo 'Checking Selenium Grid ready status'
while true; do
  curl "http://localhost:$1/wd/hub/status" > json
  cat json
  status=$(jq '.value.ready' json)
  if [ $status == 'true' ]; then
    break
  fi
done

rm json
