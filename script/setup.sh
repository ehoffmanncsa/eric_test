#!/bin/bash

# Check and wait for Selenium Grid connection
echo 'Checking Selenium Grid ready status'
while true; do
  curl "http://localhost:$1/wd/hub/status" > json
  cat json
  status=$(jq '.value.ready' json)
  if [ $status == 'true' ]; then
    # Just to space out the content of the outputs for easy reading purpose
    echo ""
    echo ""
    break
  fi
done

rm json

# Copy freetds tar file, sql and postgres creds files for test container to use
echo "*** Copy freetds ***"
if [ ! -f freetds-1.00.21.tar.gz ]; then
  cp /var/lib/jenkins/deploy_files/freetds/freetds-1.00.21.tar.gz freetds-1.00.21.tar.gz
fi

echo "*** Copy Postgres DB YAML ***"
cp /var/lib/jenkins/deploy_files/qa_regression/postgres_databases.yml config/postgres_databases.yml

echo "*** Copy SQL DB YAML ***"
cp /var/lib/jenkins/deploy_files/qa_regression/sql_databases.yml config/sql_databases.yml

echo "*** Copy .env file ***"
cp /var/lib/jenkins/deploy_files/qa_regression/.staging-docker.env .staging-docker.env
