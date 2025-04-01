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

# Password change section
echo ""
echo "Setting up user password:"
read -p "Enter username to change password: " username

# Check if user exists
if id "$username" &>/dev/null; then
    # Secure password prompt
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
    echo "$username:$password" | chpasswd
    echo "Password updated successfully for $username"
else
    echo "Error: User $username does not exist!"
    exit 1
fi

echo "Setup completed successfully!"
