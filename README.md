# RDP Medium Honeypot

A medium interactivity RDP honeypot built on [RDPY](https://github.com/citronneur/rdpy). It presents a pre-recorded Windows RDP login screen to incoming connections, capturing submitted credentials and client metadata without requiring a live Windows VM. Logs are processed through the ELK stack (Elasticsearch, Logstash, and Kibana) with GeoIP enrichment for geographic attribution.

## How it works

RDPY replays a pre-recorded `.rss` session file to simulate a Windows login screen. When an attacker connects on port 3389, RDPY engages them with the fake prompt and logs any credentials they submit along with their source IP, hostname, and domain fields.

The included RSS file (`data/rss/win2008r2-rdp.rss`) emulates a Windows Server 2008 R2 host. To record your own, run a MitM capture against a real Windows host with NLA disabled using RDPY's `rdpy-rdpmitm.py` tool, then update `RSS_FILE` in `.env`.

## Services

| Service | Role |
|---|---|
| `honeypot` | Listens on port 3389, emulates RDP login, writes logs |
| `filebeat` | Sends structured JSON logs to Logstash |
| `logstash` | Enriches events with GeoIP/ASN data, forwards to Elasticsearch |
| `elasticsearch` | Stores and indexes all events |
| `kibana` | Visualises attack traffic via pre-built dashboard |
| `geoip-db` | Downloads MaxMind GeoLite2 databases if needed |
| `kibana-import` | Loads pre-defined Kibana dashboards on startup |

Two isolated Docker networks keep the honeypot container separated from the analysis stack. The honeypot can reach Logstash but cannot reach Elasticsearch or Kibana directly.

## Collected data

Each connection attempt produces a JSON event with:

| Field | Description |
|---|---|
| `@timestamp` | UTC time of the connection |
| `src_ip` / `src_port` | Source address and port |
| `username` | Credential submitted at the login prompt |
| `password` | Credential submitted at the login prompt |
| `domain` | Windows domain field sent by the client |
| `hostname` | Client hostname from the RDP handshake |
| `geoip.*` | City, country, coordinates |
| `asn.*` | ASN number and organisation |

## Prerequisites

- Docker and Docker Compose
- A free [MaxMind account](https://www.maxmind.com/en/geolite2/signup) for GeoIP database downloads
- Port 3389 open and reachable from the internet on the host machine

## Setup

**1. Configure environment variables**

```bash
cp .env.example .env
```

Edit `.env` with your configurations:

```env
MAXMIND_ACCOUNT_ID=<your-account-id>
MAXMIND_LICENSE_KEY=<your-license-key>
RSS_FILE=win2008r2-rdp.rss
```

**2. Start all services**

```bash
docker compose up -d
```

**3. Open Kibana**

The `kibana-import` service imports the dashboard automatically. Once running, open `http://localhost:5601` and navigate to **Dashboards > rdpy-honeypot-dashboard**.

## Logs

| Path | Content |
|---|---|
| `data/logs/rdpy-raw.log` | Raw RDPY honeypot logs |
| `data/logs/rdpy.json` | Structured JSON events (one per connection) |
| `data/pcaps/rdp.*.pcap` | Hourly PCAP (network packets) files |

## Stopping

```bash
docker compose down
```

To also remove stored Elasticsearch data:

```bash
docker compose down -v
```