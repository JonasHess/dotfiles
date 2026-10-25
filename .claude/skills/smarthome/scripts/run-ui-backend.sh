#!/usr/bin/env bash
# Start the smarthome4-ui backend locally on port 8000 against the REAL broker and Home Assistant.
# Credentials are read at runtime (creds.sh). Run it in the background and redirect its output:
#   nohup run-ui-backend.sh > "$SCRATCH/ui-backend.log" 2>&1 &
# Stop it with: pkill -f "uvicorn app.main:app"
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/creds.sh"
export HA_API_TOKEN HA_BASE_URL MQTT_HOST MQTT_PORT MQTT_USERNAME MQTT_PASSWORD Z2M_TOPIC
cd "$HOME/repos/smarthome4-ui/backend"
exec "$SH_VENV/bin/uvicorn" app.main:app --port 8000
