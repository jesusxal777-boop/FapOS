#!/bin/bash
set -e

echo "========================================"
echo "  FapOS Installer — Liquid Glass"
echo "========================================"

if [ "$EUID" -ne 0 ]; then
  echo "Ejecuta como root: sudo bash install.sh"
  exit 1
fi

REAL_USER=${SUDO_USER:-$USER}
REAL_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)

echo "[1/7] Actualizando lista de paquetes..."
apt-get update -qq

echo "[2/7] Instalando dependencias..."
apt-get install -y \
  plank \
  xprintidle \
  libnotify-bin \
  notification-daemon \
  git \
  curl \
  wget \
  unzip \
  sassc \
  libglib2.0-dev-bin \
  imagemagick \
  plymouth \
  plymouth-themes \
  sound-theme-freedesktop \
  libcanberra-gtk3-module \
  || true

echo "[3/7] Instalando WhiteSur (look macOS / Liquid Glass)..."
if [ ! -d /tmp/WhiteSur-gtk-theme ]; then
  git clone --depth=1 https://github.com/vinceliuice/WhiteSur-gtk-theme.git /tmp/WhiteSur-gtk-theme
fi
cd /tmp/WhiteSur-gtk-theme
./install.sh -d /usr/share/themes -c Dark -t purple -l || true

if [ ! -d /tmp/WhiteSur-icon-theme ]; then
  git clone --depth=1 https://github.com/vinceliuice/WhiteSur-icon-theme.git /tmp/WhiteSur-icon-theme
fi
cd /tmp/WhiteSur-icon-theme
./install.sh -d /usr/share/icons || true

echo "[4/7] Branding FapOS..."
mkdir -p /usr/share/backgrounds/fapos
mkdir -p /etc/fapos

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
PRIVACY_POLICY_URL="https://github.com/jesusxal777-boop/FapOS"
UBUNTU_CODENAME=noble
EOF

hostnamectl set-hostname fapos 2>/dev/null || echo "fapos" > /etc/hostname

echo "[5/7] Instalando Idle Monitor v2 (más interactivo)..."
SCRIPT_SRC=""
if [ -f "$(dirname "$0")/scripts/fapos-idle-monitor.sh" ]; then
  SCRIPT_SRC="$(dirname "$0")/scripts/fapos-idle-monitor.sh"
elif [ -f /home/"$REAL_USER"/FapOS/scripts/fapos-idle-monitor.sh ]; then
  SCRIPT_SRC=/home/"$REAL_USER"/FapOS/scripts/fapos-idle-monitor.sh
elif [ -f scripts/fapos-idle-monitor.sh ]; then
  SCRIPT_SRC=scripts/fapos-idle-monitor.sh
fi

if [ -n "$SCRIPT_SRC" ]; then
  cp "$SCRIPT_SRC" /usr/local/bin/fapos-idle-monitor.sh
else
  echo "No se encontró fapos-idle-monitor.sh — saltando copia"
fi
chmod +x /usr/local/bin/fapos-idle-monitor.sh 2>/dev/null || true

mkdir -p "$REAL_HOME"/.config/systemd/user
cat > "$REAL_HOME"/.config/systemd/user/fapos-idle.service << EOF
[Unit]
Description=FapOS Idle Monitor v2
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

chown -R "$REAL_USER":"$REAL_USER" "$REAL_HOME"/.config/systemd

echo "[6/7] Autostart Plank + Idle Monitor..."
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

echo "[7/7] Activando servicio de usuario..."
su - "$REAL_USER" -c "systemctl --user daemon-reload" 2>/dev/null || true
su - "$REAL_USER" -c "systemctl --user enable --now fapos-idle.service" 2>/dev/null || true

echo ""
echo "========================================"
echo "  FapOS Liquid Glass listo"
echo "========================================"
echo ""
echo "Siguiente:"
echo "1. Cierra sesión y vuelve a entrar (o reinicia)"
echo "2. Aplica WhiteSur en Ajustes → Apariencia"
echo "3. Pon wallpapers R34 en /usr/share/backgrounds/fapos/"
echo "4. El monitor ya está activo: a los 3 min de idle te va a buscar"
echo ""
echo "Usuario live (ISO): usuario  |  Contraseña: (ninguna)"
echo "Disfruta. Que te tiente."
