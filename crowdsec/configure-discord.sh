#!/bin/bash

CONTAINERS=( $(pct list | grep running | awk '{print $1}') )

for CONTAINER in ${CONTAINERS[@]}
do
    CONTAINER=102
    if [[ -d /etc/crowdsec ]]; then
        echo "# Configuring Discord notifications on container $CONTAINER -----------------------------------------------------------------------------------"
        pct push ./discord.yaml /etc/crowdsec/notifications/
        pct exec $CONTAINER -- bash -c "cat /etc/crowdsec/profiles.yaml  | sed '/on_success:/i notifications:\n - discord' > /etc/crowdsec/profiles.yaml"
        pct exec $CONTAINER -- systemctl restart crowdsec
    fi
done


