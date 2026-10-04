#!/bin/sh
set -e

GEOIP_DIR=/geoip

if [ -f "$GEOIP_DIR/GeoLite2-City.mmdb" ] && [ -f "$GEOIP_DIR/GeoLite2-ASN.mmdb" ]; then
  echo "GeoIP databases already exist. Skipping download."
  exit 0
fi

echo "Downloading GeoLite2-City..."
curl -L -u "${MAXMIND_ACCOUNT_ID}:${MAXMIND_LICENSE_KEY}" \
  -o /tmp/geo-city.tar.gz \
  "https://download.maxmind.com/geoip/databases/GeoLite2-City/download?suffix=tar.gz"
tar -xzf /tmp/geo-city.tar.gz -C /tmp/
mv /tmp/GeoLite2-City_*/GeoLite2-City.mmdb "$GEOIP_DIR/"

echo "Downloading GeoLite2-ASN..."
curl -L -u "${MAXMIND_ACCOUNT_ID}:${MAXMIND_LICENSE_KEY}" \
  -o /tmp/geo-asn.tar.gz \
  "https://download.maxmind.com/geoip/databases/GeoLite2-ASN/download?suffix=tar.gz"
tar -xzf /tmp/geo-asn.tar.gz -C /tmp/
mv /tmp/GeoLite2-ASN_*/GeoLite2-ASN.mmdb "$GEOIP_DIR/"

echo "GeoIP databases ready."