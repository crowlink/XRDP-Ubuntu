#!/bin/bash

# Exit immediately if any command fails
set -e
# Enable pipefail to catch errors in pipes
set -o pipefail

# Error handling function
handle_error() {
    echo "Error occurred in command at line $1"
    exit 1
}

# Trap errors and call handler
trap 'handle_error $LINENO' ERR

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root or with sudo."
    exit 1
fi

# Function to check command success
check_success() {
    if [ $? -ne 0 ]; then
        echo "Error: $1 failed"
        exit 1
    fi
}

# Update system and clean up
echo "Updating system packages..."
apt-get update -y
check_success "System update"

apt-get upgrade -y
check_success "System upgrade"

apt autoremove -y
check_success "Package cleanup"

# Install base packages
echo "Installing base packages..."
{
    apt install -y xfce4 xfce4-goodies \
    xrdp \
    firefox
} > /dev/null
check_success "Base package installation"

# Install Nekoray dependencies
echo "Installing Nekoray dependencies..."
{
    apt install -y build-essential \
    libfontconfig1 \
    libqt5network5 \
    libqt5widgets5 \
    libqt5x11extras5 \
    libqt5gui5
} > /dev/null
check_success "Nekoray dependency installation"

# Install Nekoray
echo "Installing Nekoray..."
wget -qO- https://raw.githubusercontent.com/ohmydevops/nekoray-installer/main/installer.sh | bash
check_success "Nekoray installation"

# Configure xrdp
echo "Configuring xrdp..."
sed -i 's/^test -x \/etc\/X11\/Xsession && exec \/etc\/X11\/Xsession/#&/' /etc/xrdp/startwm.sh
sed -i 's/^exec \/bin\/sh \/etc\/X11\/Xsession/#&/' /etc/xrdp/startwm.sh
echo "startxfce4" >> /etc/xrdp/startwm.sh
check_success "xrdp configuration"

# Restart xrdp service
echo "Restarting xrdp service..."
systemctl restart xrdp || service xrdp restart
check_success "xrdp service restart"

# Configure firewall
echo "Configuring firewall..."
ufw disable
check_success "Firewall disable"

ufw allow 3389
check_success "Firewall rule addition"

# Password change section
echo -e "\nSetting up user password:"
read -p "Enter username to change password: " username

# Check if user exists
if ! id "$username" &>/dev/null; then
    echo "Error: User $username does not exist!"
    exit 1
fi

# Password validation loop
while true; do
    read -sp "Enter new password for $username: " password
    echo
    read -sp "Confirm password: " password_confirm
    echo
    
    if [ "$password" != "$password_confirm" ]; then
        echo "Passwords do not match. Please try again."
    elif [ -z "$password" ]; then
        echo "Password cannot be empty. Please try again."
    else
        break
    fi
done

# Change password
echo "Updating password..."
echo "$username:$password" | chpasswd
check_success "Password change"

echo -e "\nSetup completed successfully!"
