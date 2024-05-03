#!/bin/bash

echo "#--[Task 1] User creation-------------------------------------"
sleep 1
printf "# Enter username: "
read -r username

printf "# Enter the password prefix: "
read -r prefix

password="$prefix$(hostname)"

echo "# The current settings are:"
echo "# - Username: $username"
echo "# - Password: $prefix$(hostname)"
printf "# Do you want to continue? [y/n]: "
read -r option

if [[ $option == "n" || $option == "N" ]]; then
        exit 1
fi

sleep 1

echo "# Creating user '$username'"

addgroup --gid 1111 $username
adduser --gecos "" --disabled-password --uid 1111 --gid 1111  $username
echo "$username:$password" | chpasswd
chsh -s /bin/bash $username

sleep 1

echo "# Installing sudo"
apt install sudo -y

sleep 1

echo "# Adding user '$username' to sudo group"
usermod -aG sudo $username

sleep 1

getent passwd hostwrite > /dev/null 2&>1

if [ $? -eq 0 ]; then
    echo "# Hostwrite user/group already exists, adding group to $username"
    usermod -aG hostwrite $username
else
    echo "# Hostwrite user/group not existing, skipping."
fi

echo "#--[Task 2] Starship configuration-----------------------------"
sleep 1
echo "# Installing Starship"
curl -sS https://starship.rs/install.sh | sh

sleep 1

echo "# Updating $username shell"
echo " " >> /home/$username/.bashrc
echo "eval \"\$(starship init bash)\"" >> /home/$username/.bashrc

sleep 1

echo "# Updating root shell"
echo "" >> /root/.bashrc
echo "eval \"\$(starship init bash)\"" >> /root/.bashrc

sleep 1

echo "# Creating configuration folder for user: $username"
userPath=/home/$username/.config
mkdir -p $userPath

sleep 1

echo "# Copying starship.toml"
cp ./starship.toml $userPath/

sleep 1

echo "# Adjusting ownership"
chown -R $username:$username $userPath

sleep 1

echo "# Creating configuration folder for user: root"
rootPath=/root/.config
mkdir -p $rootPath

sleep 1

echo "# Copying starship.toml"
cp ./starship.toml $rootPath/

sleep 1

echo "# Reloading current shell"
source ~/.bashrc

sleep 1

echo "#--[Task 3] SSH Configuration----------------------------------"
echo "# Updating sshd service with public key"
echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
echo "RSAAuthentication yes" >> /etc/ssh/sshd_config
echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config

sleep 1

echo "# Restarting ssh service"
service ssh restart

sleep 1

printf "# Now create a ssh key and paste it:"
read -r pubKey

sleep 1

echo "# Adding key to authorized key of user: $username"

if [ -d '/home/$username/.ssh' ]; then
    echo "$pubKey" >> /home/$username/.ssh/authorized_keys
    chown $username:$username /home/$username/.ssh/authorized_keys
else
    mkdir /home/$username/.ssh
    chown $username:$username /home/$username/.ssh
    echo "$pubKey" >> /home/$username/.ssh/authorized_keys
    chown $username:$username /home/$username/.ssh/authorized_keys
fi



sleep 1

echo "# SSH Configured"

sleep 1

echo "#--[Task 4] MOTD Configuration---------------------------------"
sleep 1

echo "# Installing fancy-motd dependencies"
apt install figlet curl bc fortune lm-sensors -y
sleep 1

echo "# Installing fancy-motd in /home/$username"
git clone https://github.com/bcyran/fancy-motd.git /home/$username/fancy-motd
cp /home/$username/fancy-motd/config.sh.example /home/$username/fancy-motd/config.sh
chmod +x /home/$username/fancy-motd/config.sh
sleep 1

echo "# Updating $username .profile file"
echo "" >> "/home/$username/.profile"
echo "/home/$username/fancy-motd/motd.sh" >> "/home/$username/.profile"
sleep 1

echo "# Deleting turnkey and old motds"
rm /etc/update-motd.d/*
sleep 1




sleep 1
echo "#--Configuration Done------------------------------------------"
