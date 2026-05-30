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
