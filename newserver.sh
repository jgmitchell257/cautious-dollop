#!/usr/bin/env bash

echo "Checking to see if you are root..."
echo ""

# Quick check to see if user has root permissions
if [ "$EUID" -ne 0 ] 
	then echo "You do not have the needed permissions to run this script."
	exit
fi

echo "You are root!"
echo ""
echo "Press the enter key to continue..."
read

echo "Installing updates and essential tools"
# Install OS updates and essential tools
apt update && apt upgrade -y
apt install net-tools sudo ufw -y


echo "Enabling firewall on start"
ufw enable
echo "Configuring firewall to allow SSH traffic"
ufw allow ssh

# Typical server tasks
echo "Enter a new server name"
read servername
echo "Setting hostname to $servername"
hostname $servername
echo $servername > /etc/hostname
echo "127.0.0.1		$servername" >> /etc/hosts
echo "[+] Done - server name changed to $servername"

# Update SSH Keys
echo -n "Should the SSH keys be regenerated? [y/N]: "
read -r regen
if [[ $regen == y ]]
	then
		echo "Deleting SSH keys"
		rm /etc/ssh/ssh_host_*
		echo "[+] Done - removed existing keys"
		dpkg-reconfigure openssh-server
else
	echo "Skipping SSH key regeneration"
fi

# Add new user account
echo "Creating a new user account"
echo -n "Enter account username: "
read -r acctname
adduser $acctname
echo "[+] Done - user created"
echo "Adding $acctname to sudo group"
usermod -aG sudo $acctname
echo "[+] Done - user added to sudo"
echo "Creating /home/$acctname/.ssh"
mkdir /home/$acctname/.ssh

# This should be a valid ssh key
echo "Writing public key to authorized keys"
echo  ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDQdkd9C0WorWwgkKHJdbEaQ+x60/YJb46GpMaIUeKLV5wNMHcjaMD7/gCReXY3eKFjXPRNGaoy2e1H2uCRoOgQ3ztvRcRSqc7aAlJmVxtwe4NHLAaM8xumJWb7hIyR1XDoUGXaFeSZHAKcs92OiqLCwaYCLcl+ASmDA6k59kxPRvXhaHspgqO4/ZKN5LPwkFyfXyJCBJetnGie+Mtt0qPbGZFDpx0F1BbNGJCdEiyO+6EpCHZAqa/uyqUmTGbz1n/p9QQMrQ/c5K/qSAZ6eStgldJwa+wJP2D+/BEWTGaO8RlKTZXaumE4pd1PtLpoOPfKgDVjmb8UVVx5NpDLChTxr2wjVoFUPK1XSRp7W77GuZPbnOvFUqOgRpof7jSIVvUSyJJ7XZ3NEsrfJ8odbNoaCmV34p5+lVUNZPo/0ZnwnNI9IyQZARO2xbUdaVHQn82/RLM4k4upmjXqTt5YIej1wvXG5YKpRT8Y2Hf5V3Kjgj0Z/YtbNJHqKQES9cwhpVhwXb5K/+uwM/Uz4CLkiCXIbf1IG1BC49ERw1zabSCz3vN3GRaHywl/HAAu8hgHxRyUjYVerSPR+eysN1bSm4Nl8PFf3VUbB2zqieEqx4aTNrd3P2TzG5B1o2lZXBQNn30lXpDxKG7SqSPAIyFB3XDZlmM6woREmR2G1aLL/peyTQ== jgm@debian >> /home/$acctname/.ssh/authorized_keys
chmod -R go= /home/$acctname/.ssh
chown -R $acctname:$acctname /home/$acctname/.ssh
echo ""
echo "Securing SSH settings"
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/ChallengeResponseAuthentication yes/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config
sed -i 's/UsePAM yes/UsePAM no/' /etc/ssh/sshd_config

# Remove default user and home folder
echo "Deleting defaultuser account"
deluser --remove-home defaultuser
echo "[+] Done - user removed"

echo "Cleaning up"
echo "Removing new server script"
rm newserver.sh
echo "[+] Done"
echo "Rebooting server now"
shutdown -r now
