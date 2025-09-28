#!/bin/bash

# Ensure script runs as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root (use sudo)."
    exit 1
fi

set -e  # Exit on any error

echo "Updating system and installing base utilities..."
apt-get update -y
apt-get upgrade -y
apt autoremove -y
apt install -y curl wget unzip

echo "Installing XFCE desktop environment..."
apt install -y xfce4 xfce4-goodies

echo "Installing xrdp and Firefox..."
apt install -y xrdp firefox

# === INSTALL THRONE (via official .deb) ===
echo "Fetching latest Throne .deb package..."

THRONE_API="https://api.github.com/repos/throneproj/Throne/releases/latest"
DEB_URL=$(curl -s "$THRONE_API" | grep -o '"browser_download_url": "[^"]*Throne.*debian.*\.deb"' | head -1 | cut -d'"' -f4)

if [ -z "$DEB_URL" ]; then
    echo "❌ ERROR: Could not find a Debian/Ubuntu .deb package for Throne."
    echo "Check: https://github.com/throneproj/Throne/releases"
    exit 1
fi

DEB_FILE="/tmp/throne-latest.deb"
echo "Downloading: $(basename "$DEB_URL")"
curl -L --progress-bar -o "$DEB_FILE" "$DEB_URL"

echo "Installing Throne..."
apt install -y ./"$DEB_FILE"

rm -f "$DEB_FILE"

# === CONFIGURE XRDP TO USE XFCE ===
echo "Configuring xrdp to launch XFCE..."

# Backup original (optional)
cp /etc/xrdp/startwm.sh /etc/xrdp/startwm.sh.bak

# Remove default session lines
sed -i '/^test -x \/etc\/X11\/Xsession/d' /etc/xrdp/startwm.sh
sed -i '/^exec \/bin\/sh \/etc\/X11\/Xsession/d' /etc/xrdp/startwm.sh

# Append XFCE startup
echo "startxfce4" >> /etc/xrdp/startwm.sh

chmod +x /etc/xrdp/startwm.sh

echo "Restarting xrdp service..."
systemctl restart xrdp

# === FIREWALL: Allow RDP (port 3389) ===
echo "Configuring firewall..."
ufw --force reset
ufw --force enable
ufw allow 3389/tcp comment 'xrdp RDP'

echo
echo "✅ Installation complete!"
echo "• Connect via RDP to this machine on port 3389"
echo "• Throne is installed system-wide — launch it from Applications > Internet"
echo "• Desktop environment: XFCE"
