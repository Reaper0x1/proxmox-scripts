#!/bin/bash

if [[ -d /etc/crowdsec  ]]; then
    echo "# Configuring Discord notifications-----------------------------------------------------------------------------------"

    printf "# Enter your Discord Webhook URL: "
    read -r discord_webhook

    wget https://raw.githubusercontent.com/Reaper0x1/proxmox-scripts/main/crowdsec/discord.yaml -O /etc/crowdsec/notifications/discord.yaml
    sed -i "s/<discord-webhook>/$discord_webhook/g" /etc/crowdsec/notifications/discord.yaml

    sed '/on_success:/i notifications:\n - discord' /etc/crowdsec/profiles.yaml > /tmp/profiles.yaml && mv /tmp/profiles.yaml /etc/crowdsec/profiles.yaml
    systemctl restart crowdsec
fi
