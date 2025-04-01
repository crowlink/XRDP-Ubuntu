#!/bin/bash

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root or with sudo."
    exit 1
fi

# Update system and clean up
apt-get update -y
apt-get upgrade -y
apt autoremove -y

# Install required packages
apt install xfce4 xfce4-goodies -y
apt install xrdp -y
apt-get install firefox -y

# Configure xrdp to use xfce4
sed -i 's/^test -x \/etc\/X11\/Xsession && exec \/etc\/X11\/Xsession/#&/' /etc/xrdp/startwm.sh
sed -i 's/^exec \/bin\/sh \/etc\/X11\/Xsession/#&/' /etc/xrdp/startwm.sh
echo "startxfce4" >> /etc/xrdp/startwm.sh

# Restart xrdp service
service xrdp restart

# Configure firewall
ufw disable
ufw allow 3389

echo "Setup completed successfully!"
