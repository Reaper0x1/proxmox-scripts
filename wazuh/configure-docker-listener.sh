#!/bin/bash

CONTAINERS=( $(pct list | grep running | awk '{print $1}') )
WAZUH_MANAGER_CONTAINER=107

for CONTAINER in ${CONTAINERS[@]}
do
    has_agent=$(pct exec $CONTAINER -- test -d /var/ossec && echo "yes" || echo "no")
    has_docker=$(pct exec $CONTAINER -- docker --version &> /dev/null && echo "yes" || echo "no")
    if [[ $has_agent == "yes" && $CONTAINER != $WAZUH_MANAGER_CONTAINER && $has_docker ]]; then

        echo "# Configuring $CONTAINER -----------------------------------------------------------------------------------"
        echo "# Has docker: $has_docker"
        echo "# Has wazuh agent: $has_agent"
        sleep 1

        echo "# [$CONTAINER] - Installing Python and pip..."
        pct exec $CONTAINER -- apt update && apt install python3 python3-pip
        
        echo "# [$CONTAINER] - Installing python docker module..."
        pct exec $CONTAINER -- pip3 install docker==4.2.0 --break-system-packages

        echo "#[$CONTAINER] - Enabling the Wazuh agent to receive remote commands from the Wazuh server..."
        pct exec $CONTAINER -- echo "logcollector.remote_commands=1" >> /var/ossec/etc/local_internal_options.conf

        echo "#[$CONTAINER] - Restarting the agent..."
        pct exec $CONTAINER -- systemctl restart wazuh-agent
    fi
done