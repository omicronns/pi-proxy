# pi-proxy

This repository contains set of scripts to configure Raspberry PI as network proxy to intercept traffic for inspection.
It can spawn mitmproxy to perform man in the middle attack, or you can use just tcpdump to inspect packets without traffic interference.

# Usage

Raspberry PI 3 or 4 is required with Manjaro ARM OS.

https://manjaro.org/download/#raspberry-pi-4-minimal

Then clone this repository onto the device.

## Setup

First we need to setup needed packages and configure the device network.

```
sudo ./setup.sh apd|eth|clr
```

There are three options available:

* `apd` - configure Raspberry to expose access point for the target device to connect, outside world connection is done via physical ethernet port
* `eth` - configure Raspberry to connect to the internet via wlan interface, target device shall be connected via phical ethernet port
* `clr` - clear the configuration, brings the device to usual operation prior to the setup (software installed during setup is not removed)

## Mitmproxy with capture

There is a script to configure capture and mitmproxy to intercept the traffic:

```
sudo proxy-and-dump.sh apd|eth TCPDUMP_FILTER
```

We can specify `TCPDUMP_FILTER` to only capture interesting traffic, eg.

```
sudo proxy-and-dump.sh apd "host x.x.x.x"
```

to limit capture to packets only related with specific ip address. Filter must be enclosed in quotes.

## Only tcpdump

If we don't want to use mitmproxy we can capture with only `tcpdump`.

When configured as `apd`:

```
sudo tcpdump -i wlan0 -w dump.pcap
```

When configured as `eth`:

```
sudo tcpdump -i eth0 -w dump.pcap
```
