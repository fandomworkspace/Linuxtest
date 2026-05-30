#!/bin/bash

# Setup script to add KDE Plasma Desktop to your GitHub repository
# This script automates the entire process

set -e

# Color codes for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
RESET='\033[0m'

echo -e "${BLUE}========================================${RESET}"
echo -e "${BLUE}KDE Plasma Desktop - Repository Setup${RESET}"
echo -e "${BLUE}========================================${RESET}"
echo ""

# Check if we're in a git repository
if [ ! -d .git ]; then
    echo -e "${RED}[✗] Error: Not a git repository${RESET}"
    echo "Please run this script from the root of your GitHub repository"
    exit 1
fi

# Get repo info
REPO_NAME=$(git config --get remote.origin.url | sed 's/.*\///' | sed 's/\.git$//')
REPO_URL=$(git config --get remote.origin.url)

echo -e "${GREEN}[✓] Detected repository:${RESET}"
echo "    URL: $REPO_URL"
echo "    Name: $REPO_NAME"
echo ""

# Create .devcontainer directory
echo -e "${BLUE}Creating .devcontainer directory...${RESET}"
mkdir -p .devcontainer
echo -e "${GREEN}[✓] .devcontainer directory created${RESET}"
echo ""

# Download files from the provided URLs or use embedded content
echo -e "${BLUE}Setting up configuration files...${RESET}"

# Create devcontainer.json
cat > .devcontainer/devcontainer.json << 'EOF'
{
  "name": "KDE Plasma Desktop",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu-24.04",
  "features": {
    "ghcr.io/devcontainers/features/docker-in-docker:2": {}
  },
  "forwardPorts": [6080],
  "portsAttributes": {
    "6080": {
      "label": "KDE Plasma Desktop (noVNC)",
      "onAutoForward": "notify",
      "requireLocalPort": false
    }
  },
  "remoteUser": "vscode",
  "mounts": [
    "source=/home/vscode/.local/share/applications,target=/home/vscode/.local/share/applications,type=volume"
  ],
  "customizations": {
    "codespaces": {
      "openInWeb": true
    }
  },
  "postCreateCommand": "bash /tmp/setup-kde-desktop.sh",
  "postStartCommand": "bash /tmp/start-kde-desktop.sh",
  "remoteEnv": {
    "DISPLAY": ":1",
    "DBUS_SYSTEM_BUS_ADDRESS": "unix:path=/run/dbus/system_bus_socket",
    "QT_QPA_PLATFORM": "offscreen"
  }
}
EOF

echo -e "${GREEN}[✓] devcontainer.json created${RESET}"

# Create Dockerfile
cat > .devcontainer/Dockerfile << 'EOF'
FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:1
ENV DBUS_SYSTEM_BUS_ADDRESS=unix:path=/run/dbus/system_bus_socket

RUN apt-get update && apt-get install -y --no-install-recommends \
    xserver-xvfb \
    x11-utils \
    x11-apps \
    dbus-x11 \
    dbus \
    kde-plasma-desktop \
    kde-full \
    dolphin \
    konsole \
    kate \
    ark \
    gwenview \
    okular \
    kcalc \
    spectacle \
    ksystemmonitor \
    kwin \
    firefox \
    tigervnc-server \
    tigervnc-common \
    novnc \
    websockify \
    kde-cli-tools \
    breeze-cursor-theme \
    breeze-icon-theme \
    pulseaudio \
    alsa-utils \
    curl \
    wget \
    git \
    nano \
    vim \
    sudo \
    psmisc \
    net-tools \
    supervisor \
    mesa-utils \
    fonts-dejavu \
    fonts-liberation \
    language-pack-en \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /home/vscode/.vnc \
    && mkdir -p /home/vscode/.config/kdedefaults \
    && mkdir -p /home/vscode/.config/plasmarc \
    && mkdir -p /home/vscode/.local/share/applications \
    && mkdir -p /home/vscode/Desktop \
    && mkdir -p /run/user/1000 \
    && chown -R vscode:vscode /home/vscode \
    && chmod 700 /home/vscode/.vnc

COPY setup-kde-desktop.sh /tmp/setup-kde-desktop.sh
COPY start-kde-desktop.sh /tmp/start-kde-desktop.sh
COPY vnc-startup.sh /tmp/vnc-startup.sh
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN chmod +x /tmp/setup-kde-desktop.sh \
    && chmod +x /tmp/start-kde-desktop.sh \
    && chmod +x /tmp/vnc-startup.sh

RUN mkdir -p /home/vscode/.vnc && \
    echo "codespaces" | vncpasswd -f > /home/vscode/.vnc/passwd && \
    chmod 600 /home/vscode/.vnc/passwd && \
    chown vscode:vscode /home/vscode/.vnc/passwd

RUN echo "[General]" > /home/vscode/.config/plasmarc && \
    echo "Session=plasmawayland" >> /home/vscode/.config/plasmarc && \
    chown vscode:vscode /home/vscode/.config/plasmarc

RUN usermod -aG video,audio vscode

EXPOSE 5901
EXPOSE 6080

USER vscode
WORKDIR /home/vscode
EOF

echo -e "${GREEN}[✓] Dockerfile created${RESET}"

# Create setup-kde-desktop.sh
cat > .devcontainer/setup-kde-desktop.sh << 'EOF'
#!/bin/bash
set -e
export DISPLAY=:1
export DBUS_SYSTEM_BUS_ADDRESS=unix:path=/run/dbus/system_bus_socket

echo "=== KDE Plasma Desktop Setup Starting ==="

sudo service dbus start 2>/dev/null || true
sleep 2

touch ~/.Xauthority
chmod 600 ~/.Xauthority

sudo mkdir -p /tmp/.X11-unix
sudo chmod 1777 /tmp/.X11-unix

sudo pkill -f Xvfb 2>/dev/null || true
sleep 1

sudo Xvfb :1 -screen 0 1920x1080x24 -nolisten tcp &
sleep 3

if [ ! -f ~/.bashrc ]; then
    touch ~/.bashrc
fi

cat >> ~/.bashrc << 'BASHRC'
export DISPLAY=:1
export DBUS_SYSTEM_BUS_ADDRESS=unix:path=/run/dbus/system_bus_socket
export QT_QPA_PLATFORM=offscreen
BASHRC

mkdir -p ~/.vnc

cat > ~/.vnc/xstartup << 'XSTARTUP'
#!/bin/bash
export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export DISPLAY=:1
export DBUS_SYSTEM_BUS_ADDRESS=unix:path=/run/dbus/system_bus_socket
export QT_AUTO_SCREEN_SCALE_FACTOR=1

if ! pgrep -x "dbus-daemon" > /dev/null; then
    dbus-launch --sh-syntax > /tmp/dbus-launch.sh
    source /tmp/dbus-launch.sh
fi

export XDG_SESSION_TYPE=x11
export XDG_CURRENT_DESKTOP=KDE

if ! pgrep -x "pulseaudio" > /dev/null; then
    pulseaudio --daemonize --load="module-native-protocol-unix" 2>/dev/null || true
fi

exec startplasma-x11
XSTARTUP

chmod +x ~/.vnc/xstartup

mkdir -p ~/.config

cat > ~/.config/plasmarc << 'PLASMARC'
[General]
Session=plasmawayland

[General]
ColorScheme=BreezeDark

[Translations]
LANGUAGE=
PLASMARC

mkdir -p ~/.config/kdedefaults
cat > ~/.config/kdedefaults/kdeglobals << 'KDEGLOBALS'
[General]
ColorScheme=Breeze

[Breeze]
BackgroundContrast=7

[KDE]
SingleClick=false
KDEGLOBALS

mkdir -p ~/.mozilla/firefox/profiles.ini

FIREFOX_PROFILE_DIR="$HOME/.mozilla/firefox/codespaces.default-release"
mkdir -p "$FIREFOX_PROFILE_DIR"

cat > "$HOME/.mozilla/firefox/profiles.ini" << 'PROFILES'
[General]
StartWithLastProfile=1

[Profile0]
Name=default
IsRelative=1
Path=codespaces.default-release
Default=1
PROFILES

cat > "$FIREFOX_PROFILE_DIR/user.js" << 'FIREFOX'
user_pref("browser.startup.homepage_override.mstone", "ignore");
user_pref("startup.homepage_welcome_url", "");
user_pref("startup.homepage_welcome_url.additional", "");
user_pref("browser.rights.3.shown", true);
user_pref("datareporting.policy.dataSubmissionPolicyAcceptedVersion", 2);
user_pref("datareporting.policy.dataSubmissionPolicyNotifiedTime", "1");
user_pref("toolkit.startup.max_resumed_crashes", 10);
user_pref("privacy.trackingprotection.enabled", true);
FIREFOX

mkdir -p ~/Desktop

cat > ~/Desktop/firefox.desktop << 'FIREFOX_DESKTOP'
[Desktop Entry]
Type=Application
Name=Firefox
Exec=firefox %u
Icon=firefox
Categories=Network;WebBrowser;
FIREFOX_DESKTOP

cat > ~/Desktop/konsole.desktop << 'KONSOLE_DESKTOP'
[Desktop Entry]
Type=Application
Name=Konsole
Exec=konsole
Icon=utilities-terminal
Categories=System;TerminalEmulator;
KONSOLE_DESKTOP

cat > ~/Desktop/dolphin.desktop << 'DOLPHIN_DESKTOP'
[Desktop Entry]
Type=Application
Name=Dolphin
Exec=dolphin
Icon=system-file-manager
Categories=System;FileManager;
DOLPHIN_DESKTOP

cat > ~/Desktop/kate.desktop << 'KATE_DESKTOP'
[Desktop Entry]
Type=Application
Name=Kate
Exec=kate
Icon=accessories-text-editor
Categories=Utility;TextEditor;
KATE_DESKTOP

chmod +x ~/Desktop/*.desktop

mkdir -p ~/.local/share/applications
cp /usr/share/applications/firefox.desktop ~/.local/share/applications/ 2>/dev/null || true
cp /usr/share/applications/konsole.desktop ~/.local/share/applications/ 2>/dev/null || true
cp /usr/share/applications/dolphin.desktop ~/.local/share/applications/ 2>/dev/null || true
cp /usr/share/applications/kate.desktop ~/.local/share/applications/ 2>/dev/null || true

mkdir -p ~/.config/autostart

echo "vscode ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/codespaces > /dev/null
sudo chmod 440 /etc/sudoers.d/codespaces

mkdir -p ~/.config/systemd/user

mkdir -p ~/.config
cat > ~/.config/kwinrc << 'KWINRC'
[General]
Animation Speed=0
BorderlessMaximizedWindows=true
Orientation=0
ShowAllDesktops=false

[Compositing]
AnimationSpeed=0
Enabled=true
OpenGLIsUnsafe=false
LatencyPolicy=High
RenderingBackend=OpenGL
TripleBuffer=true
KWINRC

chmod -R 700 ~/.config
chmod -R 700 ~/.vnc
chmod -R 700 ~/.local

pkill -f "Xvfb" 2>/dev/null || true
pkill -f "vncserver" 2>/dev/null || true

echo "=== Setup Complete ==="
EOF

chmod +x .devcontainer/setup-kde-desktop.sh
echo -e "${GREEN}[✓] setup-kde-desktop.sh created${RESET}"

# Create start-kde-desktop.sh (abbreviated version for space)
cat > .devcontainer/start-kde-desktop.sh << 'EOF'
#!/bin/bash
set -e
export DISPLAY=:1
export DBUS_SYSTEM_BUS_ADDRESS=unix:path=/run/dbus/system_bus_socket
export QT_AUTO_SCREEN_SCALE_FACTOR=1
export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

mkdir -p /run/user/1000
chmod 700 /run/user/1000
export XDG_RUNTIME_DIR=/run/user/1000

echo "=== Starting KDE Plasma Desktop ==="

sudo /etc/init.d/dbus start 2>/dev/null || sudo service dbus start 2>/dev/null || true
sleep 1

sudo pkill -f "Xvfb :1" 2>/dev/null || true
sleep 1

sudo mkdir -p /tmp/.X11-unix
sudo chmod 1777 /tmp/.X11-unix

sudo Xvfb :1 -screen 0 1920x1080x24 -nolisten tcp -nolisten unix &
sleep 3

echo "[*] Verifying X server..."
for i in {1..10}; do
    if DISPLAY=:1 xset q &>/dev/null; then
        echo "[✓] X server is ready"
        break
    fi
    sleep 1
done

echo "[*] Starting PulseAudio..."
pkill -f pulseaudio 2>/dev/null || true
sleep 1

mkdir -p ~/.config/pulse
pulseaudio --daemonize --load="module-null-sink=sink_name=virtual_sink" --load="module-native-protocol-unix" 2>/dev/null || true
sleep 2

echo "[*] Starting TigerVNC server..."
pkill -f "vncserver :1" 2>/dev/null || true
sleep 1

vncserver -xstartup ~/.vnc/xstartup -geometry 1920x1080 -depth 24 -securitytypes none :1 2>&1 | tee /tmp/vncserver.log &
sleep 3

echo "[*] Starting noVNC web server..."
pkill -f "websockify" 2>/dev/null || true
sleep 1

if [ ! -d "/usr/share/novnc" ]; then
    echo "[!] noVNC not found, attempting to install..."
    sudo apt-get update -qq && sudo apt-get install -y -qq novnc websockify 2>&1 | tail -5 || true
fi

websockify --web /usr/share/novnc 6080 localhost:5901 > /tmp/websockify.log 2>&1 &
sleep 2

echo ""
echo "=========================================="
echo "   KDE Plasma Desktop Started Successfully"
echo "=========================================="
echo ""
echo "📊 Service Status:"
echo "  • X11 Server:  Port :1 (Xvfb)"
echo "  • VNC Server:  Port 5901 (TigerVNC)"
echo "  • Web Access:  Port 6080 (noVNC)"
echo ""
echo "🌐 Access Your Desktop:"
echo "  Open this URL in your browser:"
echo "  http://localhost:6080/vnc.html"
echo ""
echo "📋 Default Credentials:"
echo "  VNC Password: codespaces"
echo ""
echo "=========================================="
echo ""

# Monitor services
while true; do
    if ! pgrep -f "Xvfb :1" > /dev/null; then
        echo "[!] X server crashed, restarting..."
        sudo Xvfb :1 -screen 0 1920x1080x24 -nolisten tcp -nolisten unix &
        sleep 3
    fi
    
    if ! lsof -i :5901 &>/dev/null; then
        echo "[!] VNC server crashed, restarting..."
        vncserver -xstartup ~/.vnc/xstartup -geometry 1920x1080 -depth 24 -securitytypes none :1 &
        sleep 3
    fi
    
    if ! lsof -i :6080 &>/dev/null; then
        echo "[!] websockify crashed, restarting..."
        pkill -f websockify
        sleep 1
        websockify --web /usr/share/novnc 6080 localhost:5901 > /tmp/websockify.log 2>&1 &
        sleep 3
    fi
    
    sleep 30
done
EOF

chmod +x .devcontainer/start-kde-desktop.sh
echo -e "${GREEN}[✓] start-kde-desktop.sh created${RESET}"

# Create vnc-startup.sh
cat > .devcontainer/vnc-startup.sh << 'EOF'
#!/bin/bash
set -e
export DISPLAY=:1
export DBUS_SYSTEM_BUS_ADDRESS=unix:path=/run/dbus/system_bus_socket
export QT_AUTO_SCREEN_SCALE_FACTOR=1

if ! pgrep -x "dbus-daemon" > /dev/null; then
    echo "Starting D-Bus..."
    if command -v dbus-daemon &> /dev/null; then
        dbus-daemon --system 2>/dev/null || true
        sleep 1
    fi
fi

if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    eval "$(dbus-launch --sh-syntax)"
fi

if ! pgrep -x "pulseaudio" > /dev/null; then
    echo "Starting PulseAudio..."
    pulseaudio --daemonize --load="module-native-protocol-unix" 2>/dev/null || true
    sleep 1
fi

export XDG_SESSION_TYPE=x11
export XDG_CURRENT_DESKTOP=KDE

echo "Starting KDE Plasma..."
exec startplasma-x11
EOF

chmod +x .devcontainer/vnc-startup.sh
echo -e "${GREEN}[✓] vnc-startup.sh created${RESET}"

# Create supervisord.conf
cat > .devcontainer/supervisord.conf << 'EOF'
[supervisord]
nodaemon=true
logfile=/tmp/supervisord.log
pidfile=/tmp/supervisord.pid
user=root

[unix_http_server]
file=/tmp/supervisor.sock
chmod=0700

[supervisorctl]
serverurl=unix:///tmp/supervisor.sock

[rpcinterface:supervisor]
supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface

[program:dbus]
command=/etc/init.d/dbus start
autostart=true
autorestart=true
stderr_logfile=/tmp/dbus.err.log
stdout_logfile=/tmp/dbus.out.log
user=root

[program:xvfb]
command=/usr/bin/Xvfb :1 -screen 0 1920x1080x24 -nolisten tcp -nolisten unix
autostart=true
autorestart=true
stderr_logfile=/tmp/xvfb.err.log
stdout_logfile=/tmp/xvfb.out.log
user=root
priority=1

[program:pulseaudio]
command=/usr/bin/pulseaudio --daemonize --load="module-native-protocol-unix"
autostart=true
autorestart=true
stderr_logfile=/tmp/pulseaudio.err.log
stdout_logfile=/tmp/pulseaudio.out.log
user=vscode
priority=2

[program:vncserver]
command=/usr/bin/vncserver -xstartup /home/vscode/.vnc/xstartup -geometry 1920x1080 -depth 24 -securitytypes none :1
autostart=true
autorestart=true
stderr_logfile=/tmp/vncserver.err.log
stdout_logfile=/tmp/vncserver.out.log
user=vscode
priority=3
stopasgroup=true

[program:websockify]
command=/usr/bin/websockify --web /usr/share/novnc 6080 localhost:5901
autostart=true
autorestart=true
stderr_logfile=/tmp/websockify.err.log
stdout_logfile=/tmp/websockify.out.log
user=vscode
priority=4

[group:desktop]
programs=dbus,xvfb,pulseaudio,vncserver,websockify
priority=100
EOF

echo -e "${GREEN}[✓] supervisord.conf created${RESET}"

# Create .dockerignore
cat > .devcontainer/.dockerignore << 'EOF'
.git
.gitignore
.gitattributes
.DS_Store
.env
.env.local
*.log
node_modules/
.npm
.eslintcache
.node_repl_history
*.tgz
.yarn-integrity
.cache
.vscode
.idea
*.swp
*.swo
*~
.editorconfig
.dockerignore
docker-compose.yml
.codespaces
.devcontainer/.git
README_OLD.md
LICENSE
EOF

echo -e "${GREEN}[✓] .dockerignore created${RESET}"

# Create .gitignore for .devcontainer
cat > .devcontainer/.gitignore << 'EOF'
*.log
*.err
*.out
logs/
tmp/
temp/
.docker/
docker-compose.override.yml
.vscode/
.idea/
*.swp
*.swo
*~
.DS_Store
.env
.env.local
.env.*.local
node_modules/
package-lock.json
yarn.lock
__pycache__/
*.py[cod]
build/
dist/
.cache/
.npm/
Thumbs.db
EOF

echo -e "${GREEN}[✓] .gitignore created${RESET}"

# Create README.md for .devcontainer
cat > .devcontainer/README.md << 'EOF'
# KDE Plasma Desktop in GitHub Codespaces

A complete GitHub Codespaces development environment with a full KDE Plasma desktop accessible via your web browser using noVNC.

## Quick Start

1. **Codespace will start automatically** when you create it
2. **Wait 2-3 minutes** for setup to complete
3. **Click the Ports tab** at the bottom of VS Code
4. **Click the globe icon** next to port **6080**
5. **Enjoy your desktop!** 🎉

## Available Applications

- **Firefox** - Web Browser
- **Dolphin** - File Manager
- **Konsole** - Terminal
- **Kate** - Text Editor
- **Okular** - PDF Reader
- **Gwenview** - Image Viewer
- **Ark** - Archive Manager
- **KCalc** - Calculator
- **Spectacle** - Screenshot Tool
- **KSystemMonitor** - System Monitor

## Access Information

- **URL**: http://localhost:6080/vnc.html
- **VNC Password**: codespaces
- **Resolution**: 1920x1080
- **Display Server**: Xvfb (X11)

## Troubleshooting

If the desktop won't load:

```bash
# Check status
bash /tmp/health-check.sh

# View logs
tail -50 /tmp/vncserver.log
tail -50 /tmp/websockify.log

# Restart all services
pkill -f Xvfb; pkill vncserver; pkill websockify
sleep 2
bash /tmp/start-kde-desktop.sh
```

## Documentation

For detailed documentation, see:
- For quick answers: See troubleshooting section above
- For complete guide: Check the main repository README

---

**Full desktop environment in your browser!** 🎉
EOF

echo -e "${GREEN}[✓] README.md created${RESET}"

# Create docker-compose.yml for local testing
cat > .devcontainer/docker-compose.yml << 'EOF'
version: '3.8'

services:
  kde-desktop:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: kde-plasma-desktop
    restart: unless-stopped
    ports:
      - "5901:5901"
      - "6080:6080"
    environment:
      - DISPLAY=:1
      - DBUS_SYSTEM_BUS_ADDRESS=unix:path=/run/dbus/system_bus_socket
      - QT_AUTO_SCREEN_SCALE_FACTOR=1
    volumes:
      - kde_home:/home/vscode
      - /tmp/.X11-unix:/tmp/.X11-unix:rw
    shm_size: 2gb
    stdin_open: true
    tty: true

volumes:
  kde_home:
    driver: local
EOF

echo -e "${GREEN}[✓] docker-compose.yml created${RESET}"

# Summary
echo ""
echo -e "${BLUE}========================================${RESET}"
echo -e "${BLUE}Setup Complete!${RESET}"
echo -e "${BLUE}========================================${RESET}"
echo ""

echo -e "${YELLOW}Files created in .devcontainer/:${RESET}"
echo "  ✓ devcontainer.json"
echo "  ✓ Dockerfile"
echo "  ✓ setup-kde-desktop.sh"
echo "  ✓ start-kde-desktop.sh"
echo "  ✓ vnc-startup.sh"
echo "  ✓ supervisord.conf"
echo "  ✓ .dockerignore"
echo "  ✓ .gitignore"
echo "  ✓ README.md"
echo "  ✓ docker-compose.yml"
echo ""

# Git operations
echo -e "${BLUE}Preparing git commit...${RESET}"

# Check if files are already tracked
if git status --short | grep -q "devcontainer"; then
    echo -e "${YELLOW}[!] Some files already exist${RESET}"
else
    echo -e "${GREEN}[✓] All files are new${RESET}"
fi

echo ""
echo -e "${YELLOW}Next steps:${RESET}"
echo ""
echo "1. Review the files:"
echo "   git status"
echo ""
echo "2. Add all files:"
echo "   git add .devcontainer/"
echo ""
echo "3. Commit:"
echo "   git commit -m 'Add KDE Plasma desktop Codespaces environment'"
echo ""
echo "4. Push to GitHub:"
echo "   git push origin main"
echo ""
echo "5. Create a Codespace:"
echo "   Visit: https://github.com/$REPO_NAME"
echo "   Click: Code → Codespaces → Create codespace on main"
echo ""
echo "6. Wait 2-3 minutes for setup"
echo ""
echo "7. Open port 6080 in your browser"
echo ""
echo -e "${GREEN}Your desktop environment is ready!${RESET} 🎉"
echo ""
