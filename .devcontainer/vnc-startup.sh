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
