#!/bin/bash

CONTAINERS=( $(pct list | grep running | awk '{print $1}') )

for CONTAINER in ${CONTAINERS[@]}
do
    has_crowdsec=$(pct exec $CONTAINER -- test -d /etc/crowdsec && echo "yes" || echo "no")
    if [[ $has_crowdsec == "yes"  ]]; then
        echo "# Configuring Discord notifications on container $CONTAINER -----------------------------------------------------------------------------------"
        pct push $CONTAINER ./discord.yaml /etc/crowdsec/notifications/discord.yaml
        pct exec $CONTAINER -- bash -c "cat /etc/crowdsec/profiles.yaml  | sed '/on_success:/i notifications:\n - discord' > /etc/crowdsec/profiles.yaml"
        pct exec $CONTAINER -- systemctl restart crowdsec
    fi
done
