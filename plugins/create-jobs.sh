#!/bin/sh

# Creating jobs
API_KEY=GF4Ktj3ROl9MUeeeM5N2Or1ketKyX2QV
PORT=$CRONICLE_WebServer__http_port
sleep 90s
echo "Creating job $f"

for f in /cronicle/jobs/*.json; do
    [ -e "$f" ] || continue
    curl -X POST  "http://localhost:$PORT/api/app/create_event/v1?&api_key=$API_KEY" -H "content-type:application/json," -d "@/$f"
    echo "Created job $f"
    rm "$f"
  done
