#!/bin/bash

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root or with sudo."
    exit 1
fi

# Update system and clean up
echo "Updating system and cleaning up..."
apt-get update -y
apt-get upgrade -y
apt autoremove -y

# Install required packages for Nekoray
echo "Installing dependencies for Nekoray..."
apt install -y build-essential \
               libfontconfig1 \
               libqt5network5 \
               libqt5widgets5 \
               libqt5x11extras5 \
               libqt5gui5

# Download and run Nekoray installer
echo "Downloading and installing Nekoray..."
wget -qO- https://raw.githubusercontent.com/ohmydevops/nekoray-installer/main/installer.sh | bash

# Install required packages for XFCE and XRDP
echo "Installing XFCE4, XRDP, and Firefox..."
apt install -y xfce4 xfce4-goodies xrdp firefox

# Configure xrdp to use XFCE4
echo "Configuring XRDP to use XFCE4..."
sed -i 's/^test -x \/etc\/X11\/Xsession && exec \/etc\/X11\/Xsession/#&/' /etc/xrdp/startwm.sh
sed -i 's/^exec \/bin\/sh \/etc\/X11\/Xsession/#&/' /etc/xrdp/startwm.sh
echo "startxfce4" >> /etc/xrdp/startwm.sh

# Restart xrdp service
echo "Restarting XRDP service..."
service xrdp restart

# Configure firewall (optional: disable UFW and allow RDP port)
echo "Configuring firewall..."
ufw disable
ufw allow 3389

echo "Setup completed successfully!"
