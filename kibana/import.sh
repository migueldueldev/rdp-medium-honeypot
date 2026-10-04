#!/bin/sh
set -e

echo 'Waiting for Kibana to be ready...'
until curl -s http://kibana:5601/api/status | grep -q '"level":"available"'; do
  sleep 5
done

echo 'Kibana ready. Importing dashboards...'

if [ -f /templates/honeypot-rdpy.json ]; then
  curl -s -X PUT 'http://elasticsearch:9200/_index_template/honeypot-rdpy' \
    -H 'Content-Type: application/json' \
    -d @/templates/honeypot-rdpy.json
  echo 'Kibana template imported.'

  curl -s -X PUT 'http://elasticsearch:9200/honeypot-rdpy-init' \
  -H 'Content-Type: application/json' \
  -d '{"settings": {"number_of_shards": 1, "number_of_replicas": 0}}'
  echo 'Kibana index created.'
else
  echo 'No Kibana template file found. Skipping import.'
fi

if [ -f /dashboards/rdpy-honeypot-dashboard.ndjson ]; then
  curl -X POST 'http://kibana:5601/api/saved_objects/_import?overwrite=true' \
    -H 'kbn-xsrf: true' \
    -F 'file=@/dashboards/rdpy-honeypot-dashboard.ndjson'
  echo 'Kibana dashboard imported.'
else
  echo 'No Kibana dashboard file found. Skipping import.'
fi