#!/bin/bash

# Set -e so that if any command fails the script will exit immediately.
set -e

# Install packages
pacman -Syu --needed \
    mitmproxy dnsmasq hostapd tcpdump

# Configure

bak() {
    if [ ! -e $1.bak ]; then
        cp $1 $1.bak
    fi
}

unbak() {
    if [ -e $1.bak ]; then
        cp $1.bak $1
    fi
}

setup_apd_target() {
    cp config/apd_target/dhcpcd.conf /etc/dhcpcd.conf
    cp config/apd_target/dnsmasq.conf /etc/dnsmasq.conf
    cp config/apd_target/iptables.rules /etc/iptables/iptables.rules

    cp config/apd_target/hostapd.conf /etc/hostapd/hostapd.conf
    cp config/apd_target/hostapd /etc/default/hostapd

    systemctl unmask hostapd
    systemctl enable hostapd
}

setup_eth_target() {
    cp config/eth_target/dhcpcd.conf /etc/dhcpcd.conf
    cp config/eth_target/dnsmasq.conf /etc/dnsmasq.conf
    cp config/eth_target/iptables.rules /etc/iptables/iptables.rules

    systemctl disable hostapd
    systemctl mask hostapd
}

setup_common() {
    bak /etc/dhcpcd.conf

    cp config/99-sysctl.conf /etc/sysctl.d/99-sysctl.conf

    systemctl stop systemd-resolved
    systemctl disable systemd-resolved
    systemctl mask systemd-resolved

    systemctl enable iptables
    systemctl enable dnsmasq
}

setup_clear() {
    systemctl disable hostapd
    systemctl mask hostapd

    systemctl disable iptables
    systemctl disable dnsmasq

    systemctl unmask systemd-resolved
    systemctl enable systemd-resolved

    unbak /etc/dhcpcd.conf
}

if [ "$1" = "apd" ]; then
    echo "[I] Setting up proxy for wlan connected device"
    setup_common
    setup_apd_target
    echo "[I] Please reboot to finish configuring the network."
elif [ "$1" = "eth" ]; then
    echo "[I] Setting up proxy for eth connected device"
    setup_common
    setup_eth_target
    echo "[I] Please reboot to finish configuring the network."
elif [ "$1" = "clr" ]; then
    setup_clear
    echo "[I] Please reboot to finish configuring the network."
else
    echo "[E] Unknown setup, choose one of: apd|eth|clr"
fi
