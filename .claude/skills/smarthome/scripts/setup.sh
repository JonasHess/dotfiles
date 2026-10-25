#!/usr/bin/env bash
# One-time setup: a Python venv with paho-mqtt and the smarthome4-ui backend requirements.
# The venv lives outside every repo, so it survives between sessions.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/creds.sh"
if [ ! -x "$SH_VENV/bin/python" ]; then
  mkdir -p "$(dirname "$SH_VENV")"
  python3 -m venv "$SH_VENV"
fi
"$SH_VENV/bin/pip" install -q --disable-pip-version-check paho-mqtt
REQ="$HOME/repos/smarthome4-ui/backend/requirements.txt"
[ -f "$REQ" ] && "$SH_VENV/bin/pip" install -q --disable-pip-version-check -r "$REQ"
echo "venv ready: $SH_VENV"
