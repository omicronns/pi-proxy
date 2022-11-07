#!/bin/bash

if [ "$1" = "wlan" ]; then
    interface=wlan0
elif [ "$1" = "eth" ]; then
    interface=eth0
else
    echo "[E] Unknown mode, choose one of: wlan|eth"
    exit
fi

dump_ts=$(date +%s)
tcpdump_filter=$2
capture_file=/tmp/capture.pcap
keylog_file=/tmp/ssl_keylog

# These iptables rules will route traffic to the mitmproxy
add_firewall_rules () {
    echo "Setting up firewall rules"
    sudo iptables -t nat -A PREROUTING -i $interface -p tcp --dport 80 -j REDIRECT --to-port 8080
    sudo iptables -t nat -A PREROUTING -i $interface -p tcp --dport 443 -j REDIRECT --to-port 8080
    echo "Done"
}

remove_firewall_rules () {
    echo "Removing firewall rules"
    sudo iptables -t nat -D PREROUTING -i $interface -p tcp --dport 80 -j REDIRECT --to-port 8080
    sudo iptables -t nat -D PREROUTING -i $interface -p tcp --dport 443 -j REDIRECT --to-port 8080
    echo "Done"
}

# This will create traffic and keys dump
create_dump () {
    dump_path=dump_$dump_ts
    echo -e "Dumping to $dump_path"
    mkdir $dump_path
    cp $capture_file $dump_path
    cp $keylog_file $dump_path
}

# Setup
add_firewall_rules

# Post Capture Steps
post_capture () {
    remove_firewall_rules
    create_dump
}

echo "Capturing traffic to: ${capture_file}"
echo "Logging TLS keys to: ${keylog_file}"
touch ${keylog_file}

# Proxy and capture
trap 'kill %1; kill %2; post_capture' SIGINT; \
    sudo tcpdump -i $interface -w ${capture_file} ${tcpdump_filter} & \
    MITMPROXY_SSLKEYLOGFILE="${keylog_file}" mitmweb -m transparent --web-host 0.0.0.0
