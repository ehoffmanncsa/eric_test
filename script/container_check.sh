#!/bin/bash
# Make sure all Selenium Grids are shutdown

echo 'If Selenium Grid dependencies are still up shut em down'
docker ps -a | grep sel | awk '{print $1}' > temp
while read line; do
  echo $line
  docker rm -f $line
done < temp

rm temp
