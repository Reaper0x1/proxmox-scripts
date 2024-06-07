#!/bin/bash

CONTAINERS=( $(pct list | grep running | awk '{print $1}') )

for CONTAINER in ${CONTAINERS[@]}
do
  echo "# Updating $CONTAINER -----------------------------------------------------------------------------------"
  pct exec $CONTAINER -- apt purge wazuh-agent -y
done