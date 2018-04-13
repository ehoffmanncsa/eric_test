#!/bin/bash
# Check and wait for Selenium Grid connection

echo 'Checking Selenium Grid ready status'
condition=false
while [ !${condition} ]; do
  curl http://localhost:4444/wd/hub/status > json
  cat json
  status=$(jq '.value.ready' json)
  if [ $status == 'true' ]; then
    condition=true
  fi
done

rm json
