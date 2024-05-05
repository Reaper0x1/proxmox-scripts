#!/bin/bash

CONTAINERS=( $(pct list | grep running | awk '{print $1}') )

for CONTAINER in ${CONTAINERS[@]}
do
        status=$(pct exec $CONTAINER -- test -d /etc/docker && echo "yes" || echo "no")
        if [[ $status == "yes" ]]; then
                echo "# Cleaning [$CONTAINER] ---------------------------------------------------------------------------------"
                pct exec $CONTAINER -- docker system prune -a -f
        fi
done