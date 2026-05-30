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
