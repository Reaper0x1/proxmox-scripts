#!/bin/bash

if [[ -d /etc/crowdsec  ]]; then
    echo "# Configuring Discord notifications on container $CONTAINER -----------------------------------------------------------------------------------"
    wget https://raw.githubusercontent.com/Reaper0x1/proxmox-scripts/main/crowdsec/discord.yaml -O /etc/crowdsec/notifications/discord.yaml
    cat /etc/crowdsec/profiles.yaml  | sed '/on_success:/i notifications:\n - discord' > /etc/crowdsec/profiles.yaml
    systemctl restart crowdsec
fi
