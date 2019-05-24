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

# Copy freetds tar file for test container to install
echo 'Looking for freetds tar file'
if [ ! -f freetds-1.00.21.tar.gz ]; then
  echo "*** Copy freetds ***"
  cp /var/lib/jenkins/deploy_files/freetds/freetds-1.00.21.tar.gz freetds-1.00.21.tar.gz
fi
