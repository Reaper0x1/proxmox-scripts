#!/bin/bash

USERNAME=reaperx
CONTAINERS=( $(pct list | grep running | awk '{print $1}') )
CONFIG_FOLDER="/home/$USERNAME/.config"
ROOT_CONFIG_FOLDER="/root/.config"
LXC_LIST=( "$(pct list | grep running)" )

CONTAINER_TO_UPDATE=""


printf "# Do you wish to update your local starship.toml file? [y/n]: "
read -r update_local

if [[ $update_local == "y" || $update_local == "Y" ]]; then
	echo "# Updating reaperx starship.toml file of: $(hostname)"
	curl -o $CONFIG_FOLDER/starship.toml https://raw.githubusercontent.com/Reaper0x1/proxmox-scripts/main/starship.toml
	echo "# Updating root starship.toml file of: $(hostname)"
	cp $CONFIG_FOLDER/starship.toml $ROOT_CONFIG_FOLDER/starship.toml
	echo "# Update of $(hostname) completed"
fi


printf "# Do you want to update the starship.toml on one container or more? [1/n]: "
read -r containers_num

if [[ $containers_num == "1" ]]; then

	printf "# Enter the container id: "
	read -r container_id
	current_container=$(echo "$LXC_LIST" | grep $container_id | awk '{print $3}')

	printf "# Do you want to update the container with id[$container_id] and hostname[$current_container]? [y/n]:"
	read -r update_one

	if [[ $update_one == "y" || $update_one == "Y" ]]; then
		echo "# Updating reaperx starship.toml file of container: $container_id [$current_container]"
		pct exec $container_id -- curl -o $CONFIG_FOLDER/starship.toml https://raw.githubusercontent.com/Reaper0x1/proxmox-scripts/main/starship.toml
		echo "# Updating root starship.toml file of container: $container_id [$current_container]"
		pct exec $container_id -- cp $CONFIG_FOLDER/starship.toml $ROOT_CONFIG_FOLDER/starship.toml
	else
		echo "# Exiting..."
		exit 1
	fi

	echo "# Update of container $container_id [$current_container] completed"
	exit 0

fi




# Gets the list of lxcs that have the config folder
echo "# Getting the active container list with existing configuration folder"
for lxc in ${CONTAINERS[@]} #$(cat ./lxc.conf)
do
	value=$(pct exec $lxc -- [ -d "$CONFIG_FOLDER" ] && echo "yes" || echo "no")
	if [[ $value == "yes" ]]; then
		CONTAINER_TO_UPDATE="$CONTAINER_TO_UPDATE:$lxc"
	fi

done


CONTAINER_TO_UPDATE=$(echo "$CONTAINER_TO_UPDATE" | sed 's/:/\n/g')

echo "# Containers list:"

for lxc in $CONTAINER_TO_UPDATE
do
	current_container=$(echo "$LXC_LIST" | grep $lxc | awk '{print $3}')
	echo "- $lxc: $current_container"
done

printf "# Do you want to continue updating Starship config for the containers? [y/n]: "
read -r continue_value

if [[ $continue_value == "n" || $continue_value == "N" ]]; then
	echo "# Exiting..."
	exit 1
elif [[ $continue_value != "y" && $continue_value != "Y" ]]; then
	echo "# Wrong value, exiting..."
	exit 1
fi

# Start update
for lxc in $CONTAINER_TO_UPDATE
do
	current_container=$(echo "$LXC_LIST" | grep $lxc | awk '{print $3}')
	echo "# Updating reaperx starship.toml file of container: $lxc [$current_container]"
        pct exec $lxc -- curl -o $CONFIG_FOLDER/starship.toml https://raw.githubusercontent.com/Reaper0x1/proxmox-scripts/main/starship.toml
	echo "# Updating root starship.toml file of container: $lxc [$current_container]"
	pct exec $lxc -- cp $CONFIG_FOLDER/starship.toml $ROOT_CONFIG_FOLDER/starship.toml
done

echo "# Update completed"
