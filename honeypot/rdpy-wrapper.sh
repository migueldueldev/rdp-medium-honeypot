#!/bin/bash

# Capture RDP packets with tcpdump
tcpdump tcp port 3389 -i any \
  -w "/data/pcaps/rdp.$(date +%F-%H).pcap" \
  -C 100 -W 24 -U &

# Run RDPY honeypot and process logs
/usr/bin/stdbuf -oL -eL rdpy-rdphoneypot.py /honeypot/rss/${RSS_FILE} 2>&1 | \
  tee -a /data/logs/rdpy-raw.log | \
  python3 /honeypot/rdpy-log-formatter.py >> /data/logs/rdpy.json