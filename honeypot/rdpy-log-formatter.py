#!/usr/bin/env python3
import sys, json, re
from datetime import datetime, timezone

conn_pattern = re.compile(
    r'Connection from (?P<src_ip>[\d.]+):(?P<src_port>\d+)',
    re.IGNORECASE
)
user_pattern = re.compile(r'username\s*:\s*(?P<username>\S+)', re.IGNORECASE)
pass_pattern = re.compile(r'password\s*:\s*(?P<password>\S+)', re.IGNORECASE)
domain_pattern = re.compile(r'domain\s*:\s*(?P<domain>\S+)', re.IGNORECASE)
host_pattern = re.compile(r'hostname\s*:\s*(?P<hostname>\S+)', re.IGNORECASE)

current_event = None

for line in sys.stdin:
    line = line.strip()
    if not line:
        continue

    conn_match = conn_pattern.search(line)
    if conn_match:
        if current_event:
            print(json.dumps(current_event), flush=True)
        current_event = {
            "@timestamp": datetime.now(timezone.utc).isoformat(),
            "honeypot": "rdpy",
            "message": line,
            "event_type": "rdp_connection_attempt",
            "src_ip": conn_match.group("src_ip"),
            "src_port": int(conn_match.group("src_port"))
        }
        continue

    if current_event:
        if user_pattern.search(line):
            current_event["username"] = user_pattern.search(line).group("username")
        if pass_pattern.search(line):
            current_event["password"] = pass_pattern.search(line).group("password")
        if domain_pattern.search(line):
            current_event["domain"] = domain_pattern.search(line).group("domain")
        if host_pattern.search(line):
            current_event["hostname"] = host_pattern.search(line).group("hostname")
        if any(x in line for x in ["Unhandled Error", "InvalidSize", "InvalidExpected"]):
            print(json.dumps(current_event), flush=True)
            current_event = None