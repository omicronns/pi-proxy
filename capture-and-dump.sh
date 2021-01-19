#!/bin/bash

capture_file=$(mktemp /tmp/capture.XXXXXXXX)
keylog_file=$(mktemp /tmp/keylog.XXXXXXXX)

capture_filter="port 443 or port 80"

# These iptables rules will route traffic to the mitmproxy
add_firewall_rules () {
  echo "Setting up firewall rules"
  sudo iptables -t nat -A PREROUTING -i wlan0 -p tcp --dport 80 -j REDIRECT --to-port 8080
  sudo iptables -t nat -A PREROUTING -i wlan0 -p tcp --dport 443 -j REDIRECT --to-port 8080
  echo "Done"
}

remove_firewall_rules () {
  echo "Removing firewall rules"
  sudo iptables -t nat -D PREROUTING -i wlan0 -p tcp --dport 80 -j REDIRECT --to-port 8080
  sudo iptables -t nat -D PREROUTING -i wlan0 -p tcp --dport 443 -j REDIRECT --to-port 8080
  echo "Done"
}

# This will create traffic and keys dump
create_dump () {
  dump_path=dump_$(date +%s)
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

# Capture and dump
trap 'kill %1; kill %2; post_capture' SIGINT; \
  sudo tcpdump -i eth0 -w ${capture_file} ${capture_filter} & \
  MITMPROXY_SSLKEYLOGFILE="${keylog_file}" mitmweb -m transparent --web-host 0.0.0.0
