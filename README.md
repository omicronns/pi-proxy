# Pi-in-the-Middle

This is a collection of scripts to configure a 
[Raspberry Pi](https://www.raspberrypi.org/) as a wireless access point and
install [mitmproxy](https://mitmproxy.org) to act as an HTTP & HTTPS proxy. It
can be configured as a transparent proxy and network traffic can be recorded
using tcpdump and uploaded to [CloudShark](https://cloudshark.io) with the
SSL/TLS master keys automatically applied for decryption.

## Installation

This was tested using a [Raspberry Pi 3 Model B](https://www.raspberrypi.org/products/raspberry-pi-3-model-b/)
running [raspios_lite_armhf-2020-12-02](https://downloads.raspberrypi.org/raspios_lite_armhf/images/).

### Pip and mitmproxy

In this git repository the
[install-python-mitmproxy.sh](/install-python-mitmproxy.sh)
script will install pip and mitmproxy on your Raspberry Pi. 

## Network Configuration

The [setup-network.sh](/setup-network.sh) will install the packages necessary
to configure the device as a wireless access point and tcpdump to capture the
network traffic. This script must be run as root using sudo:

```
sudo ./setup-network.sh
```

After running this script the Raspberry Pi should be rebooted to finish the
network configuration.

By default the Raspberry Pi will act as a wireless AP for the `pi in the
middle` network and this is also the WPA pre-shared key. This can be configured
in the [/etc/hostapd/hostapd.conf](/etc/hostapd.conf) file. The `wlan0` will be
configured with a static IP address of `192.168.1.1/24` and will serve IP
addresses via DHCP from the range 192.168.1.50-192.168.1.100. This can be
modified in the file [/etc/dnsmasq.conf](/etc/dnsmasq.conf)

## Capturing and dump

The [capture-and-dump.sh](/capture-and-dump.sh) starts by configuring the
firewall to direct HTTP & HTTPS traffic to our mitmproxy acting as a
[transparent proxy](https://docs.mitmproxy.org/stable/concepts-modes/#transparent-proxy).

Next it begins capturing HTTP and HTTPS traffic on the `eth0` interface using
tcpdump and starts `mitmdump` to act as our man-in-the-middle proxy. This will
also dump the [SSLKEYLOGFILE](https://docs.mitmproxy.org/stable/howto-wireshark-tls/)
so that HTTPS traffic can be decrypted.

Clients connecting to the `pi in the middle` wireless traffic will now have all
of their HTTP and HTTPS traffic being proxied though mitmproxy but may not
trust its built-in certificate authority. There is a built in certificate
installation app clients can use by brwosing to `mitm.it`.
[Here](https://docs.mitmproxy.org/stable/concepts-certificates/) is more
information on the mitmproxy certificate authority and how it can be
configured.

Once the script is killed using `Ctrl+c` the proxy and network capture will be
stopped and the capture file will be dumped. 
