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
