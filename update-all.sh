#!/bin/bash

CONTAINERS=( $(pct list | grep running | awk '{print $1}') )

for CONTAINER in ${CONTAINERS[@]}
do
  echo "# Updating $CONTAINER -----------------------------------------------------------------------------------"
  pct exec $CONTAINER -- apt update
  pct exec $CONTAINER -- apt dist-upgrade -y
  pct exec $CONTAINER -- apt clean
  pct exec $CONTAINER -- apt autoremove -y
done