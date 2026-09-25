#!/bin/bash
set -e

echo "========================================"
echo "  FapOS Installer — Liquid Glass v3"
echo "========================================"

if [ "$EUID" -ne 0 ]; then
  echo "Ejecuta: sudo bash install.sh"
  exit 1
fi

REAL_USER=${SUDO_USER:-$USER}
REAL_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)
ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "[1/8] Actualizando paquetes..."
apt-get update -qq

echo "[2/8] Dependencias..."
apt-get install -y \
  plank xprintidle libnotify-bin notification-daemon \
  git curl wget unzip sassc libglib2.0-dev-bin imagemagick \
  sound-theme-freedesktop libcanberra-gtk3-module \
  || true

echo "[3/8] WhiteSur theme..."
if [ ! -d /tmp/WhiteSur-gtk-theme ]; then
  git clone --depth=1 https://github.com/vinceliuice/WhiteSur-gtk-theme.git /tmp/WhiteSur-gtk-theme
fi
cd /tmp/WhiteSur-gtk-theme && ./install.sh -d /usr/share/themes -c Dark -t purple -l || true

if [ ! -d /tmp/WhiteSur-icon-theme ]; then
  git clone --depth=1 https://github.com/vinceliuice/WhiteSur-icon-theme.git /tmp/WhiteSur-icon-theme
fi
cd /tmp/WhiteSur-icon-theme && ./install.sh -d /usr/share/icons || true

echo "[4/8] Branding..."
mkdir -p /usr/share/backgrounds/fapos /etc/fapos
cat > /etc/os-release << 'EOF'
PRETTY_NAME="FapOS 1.0 Liquid Glass"
NAME="FapOS"
VERSION_ID="1.0"
VERSION="1.0 (Liquid Glass / Horny)"
VERSION_CODENAME=liquidglass
ID=fapos
ID_LIKE=ubuntu debian
HOME_URL="https://github.com/jesusxal777-boop/FapOS"
SUPPORT_URL="https://github.com/jesusxal777-boop/FapOS/issues"
BUG_REPORT_URL="https://github.com/jesusxal777-boop/FapOS/issues"
UBUNTU_CODENAME=noble
EOF
hostnamectl set-hostname fapos 2>/dev/null || echo fapos > /etc/hostname

echo "[5/8] Idle monitor v3 + turbo..."
cp "$ROOT_DIR/scripts/fapos-idle-monitor.sh" /usr/local/bin/
cp "$ROOT_DIR/scripts/fapos-turbo" /usr/local/bin/
chmod +x /usr/local/bin/fapos-idle-monitor.sh /usr/local/bin/fapos-turbo

mkdir -p "$REAL_HOME"/.config/systemd/user
cat > "$REAL_HOME"/.config/systemd/user/fapos-idle.service << EOF
[Unit]
Description=FapOS Idle Monitor v3
After=graphical-session.target

[Service]
ExecStart=/usr/local/bin/fapos-idle-monitor.sh
Restart=always
RestartSec=8
Environment=DISPLAY=:0
Environment=XDG_RUNTIME_DIR=%t

[Install]
WantedBy=default.target
EOF
chown -R "$REAL_USER:$REAL_USER" "$REAL_HOME"/.config/systemd

echo "[6/8] Autostart..."
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
chown -R "$REAL_USER:$REAL_USER" "$REAL_HOME"/.config

echo "[7/8] Atajo de teclado (Ctrl+Alt+F = turbo)..."
# GNOME
if command -v gsettings >/dev/null 2>&1; then
  su - "$REAL_USER" -c '
    SCHEMA=org.gnome.settings-daemon.plugins.media-keys
    gsettings set $SCHEMA custom-keybindings "['\''/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/fapos-turbo/'\'']" 2>/dev/null || true
    gsettings set $SCHEMA.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/fapos-turbo/ name "FapOS Turbo" 2>/dev/null || true
    gsettings set $SCHEMA.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/fapos-turbo/ command "/usr/local/bin/fapos-turbo toggle" 2>/dev/null || true
    gsettings set $SCHEMA.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/fapos-turbo/ binding "<Primary><Alt>f" 2>/dev/null || true
  ' 2>/dev/null || true
fi
# XFCE (si aplica)
mkdir -p "$REAL_HOME"/.config/xfce4/xfconf/xfce-perchannel-xml
if [ ! -f "$REAL_HOME"/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml ]; then
  cat > "$REAL_HOME"/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml << 'KEYS'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-keyboard-shortcuts" version="1.0">
  <property name="commands" type="empty">
    <property name="custom" type="empty">
      <property name="&lt;Primary&gt;&lt;Alt&gt;f" type="string" value="/usr/local/bin/fapos-turbo toggle"/>
      <property name="override" type="bool" value="true"/>
    </property>
  </property>
</channel>
KEYS
  chown -R "$REAL_USER:$REAL_USER" "$REAL_HOME"/.config/xfce4
fi

echo "[8/8] Activando servicio..."
su - "$REAL_USER" -c "systemctl --user daemon-reload" 2>/dev/null || true
su - "$REAL_USER" -c "systemctl --user enable --now fapos-idle.service" 2>/dev/null || true

echo ""
echo "========================================"
echo "  Listo — FapOS Liquid Glass v3"
echo "========================================"
echo ""
echo "  Turbo:  Ctrl+Alt+F  o  fapos-turbo"
echo "  Idle normal: 3 min | Turbo: 12 seg"
echo "  Mensajes: 20 juguetones + 5 intensos + 25 hornys"
echo "  Wallpapers: /usr/share/backgrounds/fapos/"
echo ""
echo "Cierra sesión y vuelve a entrar. Que te tiente."
