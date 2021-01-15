#!/bin/bash

# Set -e so that if any command fails the script will exit immediately.
set -e

# Install packages
pacman -Syu dnsmasq hostapd tcpdump

# Configure

bak_cp() {
    _dir=$(dirname $2)
    [ -e $_dir ] || mkdir -p $_dir
    [ -e "$2" ] && cp $2 $2.bak
    cp $1 $2
}

bak_cp ${PWD}/etc/dhcpcd.conf /etc/dhcpcd.conf
bak_cp ${PWD}/etc/dnsmasq.conf /etc/dnsmasq.conf
bak_cp ${PWD}/etc/hostapd.conf /etc/hostapd/hostapd.conf
bak_cp ${PWD}/etc/sysctl.conf /etc/sysctl.conf
bak_cp ${PWD}/default/hostapd /etc/default/hostapd

# Enable services
systemctl unmask hostapd
systemctl enable hostapd
systemctl enable dnsmasq

iptables-save > /etc/iptables/iptables.rules.bak

# Setup iptables
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE  
iptables -A FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT  
iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT

iptables-save > /etc/iptables/iptables.rules

echo "Please reboot to finish configuring the network."
