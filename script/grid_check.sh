#!/bin/bash
# Check and wait for Selenium Grid connection
# Use http://localhost:4444/wd/hub/status locally

echo 'Checking Selenium Grid ready status'
condition='false'
while [ $condition == 'false' ]; do
  curl http://172.17.0.2:24444/wd/hub/status > json
  cat json
  condition=$(jq '.value.ready' json)
done

rm json
