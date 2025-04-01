Why this shell don't install nekoray?

#!/bin/bash

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root or with sudo."
    exit 1
fi

# Update system and clean up
echo "Updating system and cleaning up..."
apt-get update -y || { echo "Failed to update package lists."; exit 1; }
apt-get upgrade -y || { echo "Failed to upgrade packages."; exit 1; }
apt autoremove -y || { echo "Failed to clean up unused packages."; exit 1; }

# Install required packages for Nekoray
echo "Installing dependencies for Nekoray..."
apt install -y build-essential \
               libfontconfig1 \
               libqt5network5 \
               libqt5widgets5 \
               libqt5x11extras5 \
               libqt5gui5 || { echo "Failed to install dependencies."; exit 1; }

# Download and install Nekoray
echo "Downloading and installing Nekoray..."
NEKORAY_INSTALL_URL="https://raw.githubusercontent.com/ohmydevops/nekoray-installer/main/installer.sh  "
wget -qO /tmp/nekoray-installer.sh "$NEKORAY_INSTALL_URL" || { echo "Failed to download Nekoray installer."; exit 1; }
chmod +x /tmp/nekoray-installer.sh || { echo "Failed to make installer executable."; exit 1; }
/tmp/nekoray-installer.sh || { echo "Failed to install Nekoray."; exit 1; }

# Install required packages for XFCE and XRDP
echo "Installing XFCE4, XRDP, and Firefox..."
apt install -y xfce4 xfce4-goodies xrdp firefox || { echo "Failed to install XFCE4, XRDP, or Firefox."; exit 1; }

# Configure xrdp to use XFCE4
echo "Configuring XRDP to use XFCE4..."
sed -i 's/^test -x \/etc\/X11\/Xsession && exec \/etc\/X11\/Xsession/#&/' /etc/xrdp/startwm.sh || { echo "Failed to modify startwm.sh."; exit 1; }
sed -i 's/^exec \/bin\/sh \/etc\/X11\/Xsession/#&/' /etc/xrdp/startwm.sh || { echo "Failed to modify startwm.sh."; exit 1; }
echo "startxfce4" >> /etc/xrdp/startwm.sh || { echo "Failed to append startxfce4 to startwm.sh."; exit 1; }

# Restart xrdp service
echo "Restarting XRDP service..."
systemctl restart xrdp || service xrdp restart || { echo "Failed to restart XRDP service."; exit 1; }

# Configure firewall
echo "Configuring firewall..."
ufw disable || { echo "Failed to disable UFW."; exit 1; }
ufw allow 3389 || { echo "Failed to allow RDP port."; exit 1; }

echo "Setup completed successfully!"
