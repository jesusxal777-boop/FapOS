#!/bin/bash
set -e

echo "========================================"
echo "  FapOS Installer"
echo "========================================"

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (sudo bash install.sh)"
  exit 1
fi

# Detect real user (the one who called sudo)
REAL_USER=${SUDO_USER:-$USER}
REAL_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)

echo "[1/7] Updating package list..."
apt-get update -qq

echo "[2/7] Installing dependencies..."
apt-get install -y \
  plank \
  xprintidle \
  libnotify-bin \
  notify-osd \
  git \
  curl \
  wget \
  unzip \
  sassc \
  libglib2.0-dev-bin \
  imagemagick \
  plymouth \
  plymouth-themes \
  || true

echo "[3/7] Installing WhiteSur theme (macOS-like)..."
if [ ! -d /tmp/WhiteSur-gtk-theme ]; then
  git clone --depth=1 https://github.com/vinceliuice/WhiteSur-gtk-theme.git /tmp/WhiteSur-gtk-theme
fi
cd /tmp/WhiteSur-gtk-theme
./install.sh -d /usr/share/themes -c Dark -t purple -l || true

# Icons
if [ ! -d /tmp/WhiteSur-icon-theme ]; then
  git clone --depth=1 https://github.com/vinceliuice/WhiteSur-icon-theme.git /tmp/WhiteSur-icon-theme
fi
cd /tmp/WhiteSur-icon-theme
./install.sh -d /usr/share/icons || true

echo "[4/7] Setting up FapOS branding..."
mkdir -p /usr/share/backgrounds/fapos
mkdir -p /etc/fapos

# os-release
cat > /etc/os-release << 'EOF'
PRETTY_NAME="FapOS 1.0"
NAME="FapOS"
VERSION_ID="1.0"
VERSION="1.0 (Horny)"
VERSION_CODENAME=horny
ID=fapos
ID_LIKE=ubuntu debian
HOME_URL="https://github.com/jesusxal777-boop/FapOS"
SUPPORT_URL="https://github.com/jesusxal777-boop/FapOS/issues"
BUG_REPORT_URL="https://github.com/jesusxal777-boop/FapOS/issues"
PRIVACY_POLICY_URL="https://github.com/jesusxal777-boop/FapOS"
UBUNTU_CODENAME=noble
EOF

# hostname
hostnamectl set-hostname fapos || echo "fapos" > /etc/hostname

echo "[5/7] Installing idle monitor..."
cp /home/"$REAL_USER"/FapOS/scripts/fapos-idle-monitor.sh /usr/local/bin/ 2>/dev/null || \
cp scripts/fapos-idle-monitor.sh /usr/local/bin/
chmod +x /usr/local/bin/fapos-idle-monitor.sh

# Systemd user service
mkdir -p "$REAL_HOME"/.config/systemd/user
cat > "$REAL_HOME"/.config/systemd/user/fapos-idle.service << EOF
[Unit]
Description=FapOS Idle Monitor
After=graphical-session.target

[Service]
ExecStart=/usr/local/bin/fapos-idle-monitor.sh
Restart=always
RestartSec=10
Environment=DISPLAY=:0

[Install]
WantedBy=default.target
EOF

chown -R "$REAL_USER":"$REAL_USER" "$REAL_HOME"/.config/systemd

echo "[6/7] Configuring Plank dock and autostart..."
mkdir -p "$REAL_HOME"/.config/autostart
cat > "$REAL_HOME"/.config/autostart/plank.desktop << EOF
[Desktop Entry]
Type=Application
Name=Plank
Exec=plank
X-GNOME-Autostart-enabled=true
EOF

cat > "$REAL_HOME"/.config/autostart/fapos-idle.desktop << EOF
[Desktop Entry]
Type=Application
Name=FapOS Idle Monitor
Exec=/usr/local/bin/fapos-idle-monitor.sh
X-GNOME-Autostart-enabled=true
EOF

chown -R "$REAL_USER":"$REAL_USER" "$REAL_HOME"/.config

echo "[7/7] Enabling user service..."
su - "$REAL_USER" -c "systemctl --user daemon-reload" || true
su - "$REAL_USER" -c "systemctl --user enable fapos-idle.service" || true

echo ""
echo "========================================"
echo "  FapOS installation complete!"
echo "========================================"
echo ""
echo "Next steps:"
echo "1. Log out and log back in (or reboot)"
echo "2. Apply WhiteSur theme in Settings → Appearance"
echo "3. Put your R34 wallpapers in /usr/share/backgrounds/fapos/"
echo "4. Start Plank if it doesn't auto-start"
echo ""
echo "Idle monitor will start automatically."
echo "Enjoy FapOS."
