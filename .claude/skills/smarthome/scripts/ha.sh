#!/usr/bin/env bash
# Home Assistant REST helper. Credentials are read at runtime (see creds.sh) and never printed.
#   ha.sh get <entity_id>                  state of one entity (read-only)
#   ha.sh find <regex>                     entities whose id or friendly name matches (read-only)
#   ha.sh template '<jinja>'               evaluate a template (read-only)
#   ha.sh call <domain>/<service> '<json>' call a service (MUTATES the real system: lights, relays, helpers)
# HA answers 503 while it restarts (about a minute after a config push); retry later.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/creds.sh"
cmd="${1:-}"; shift || true
auth=(-H "Authorization: Bearer $HA_API_TOKEN")
case "$cmd" in
  get)
    curl -s -m 20 "${auth[@]}" "$HA_BASE_URL/api/states/$1" | python3 -c '
import sys, json
e = json.load(sys.stdin); print(e["entity_id"], "|", e["state"], "| changed", e["last_changed"][:19] + "Z")' ;;
  find)
    curl -s -m 30 "${auth[@]}" "$HA_BASE_URL/api/states" | python3 -c '
import sys, json, re
rx = re.compile(sys.argv[1], re.I)
for e in sorted(json.load(sys.stdin), key=lambda e: e["entity_id"]):
    n = e["attributes"].get("friendly_name") or ""
    if rx.search(e["entity_id"]) or rx.search(n):
        print(e["entity_id"], "|", n, "|", e["state"], "|", e["last_changed"][:19] + "Z")' "$1" ;;
  template)
    python3 -c 'import json,sys;print(json.dumps({"template":sys.argv[1]}))' "$1" |
      curl -s -m 20 -X POST "${auth[@]}" -H "Content-Type: application/json" -d @- "$HA_BASE_URL/api/template"; echo ;;
  call)
    curl -s -m 30 -o /dev/null -w "http=%{http_code}\n" -X POST "${auth[@]}" -H "Content-Type: application/json" -d "$2" "$HA_BASE_URL/api/services/$1" ;;
  *) sed -n '2,8p' "$0"; exit 1 ;;
esac
