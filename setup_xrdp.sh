#!/bin/bash

# ... [Keep previous check_root and other functions unchanged] ...

# Install Nekoray with dependencies
install_nekoray() {
    echo -e "\n\033[1;33m=== INSTALLING NEKORAY ===\033[0m"
    
    # Install required dependencies
    echo "Installing dependencies..."
    apt install -y build-essential \
                   libfontconfig1 \
                   libqt5network5 \
                   libqt5widgets5 \
                   libqt5x11extras5 \
                   libqt5gui5 || {
        echo "Dependency installation failed"
        return 1
    }

    # Download and run installer as regular user
    echo "Downloading Nekoray installer..."
    sudo -u $SUDO_USER bash -c 'wget -qO- https://raw.githubusercontent.com/ohmydevops/nekoray-installer/main/installer.sh | bash' || {
        echo "Nekoray installation failed"
        return 1
    }

    echo -e "\n\033[1;32mNekoray installed successfully!\033[0m"
    echo "You can now find Nekoray in your applications menu or desktop"
}

# Modified firewall configuration (keep enabled + RDP port)
configure_firewall() {
    echo -e "\n\033[1;33m=== FIREWALL CONFIGURATION ===\033[0m"
    
    # Enable UFW if not active
    if ! ufw status | grep -q "active"; then
        echo "Enabling UFW firewall..."
        ufw --force enable || { echo "Failed to enable UFW"; return 1; }
    fi

    # Allow XRDP port
    echo "Allowing RDP port 3389..."
    ufw allow 3389/tcp || { echo "Failed to allow RDP port"; return 1; }
    
    # Reload firewall
    ufw reload
    echo -e "\n\033[1;32mFirewall configured successfully!\033[0m"
    echo "Current firewall status:"
    ufw status
}

# Main menu
show_menu() {
    clear
    echo -e "\n\033[1;36m=== SYSTEM CONFIGURATION MENU ===\033[0m"
    echo "1. System Update & Upgrade"
    echo "2. Install XFCE4 Desktop + XRDP + Firefox"
    echo "3. Configure XRDP Service"
    echo "4. Install Nekoray (VPN Client)"
    echo "5. Configure Firewall (Allow RDP)"
    echo "6. Change User Password"
    echo "7. Exit"
    echo -n "Enter your choice [1-7]: "
}

# ... [Rest of the script remains unchanged] ...
