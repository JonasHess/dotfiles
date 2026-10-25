# Source this file:  source ~/.claude/skills/smarthome/scripts/creds.sh
# Reads the smarthome credentials from the gitignored smarthome4 local profile at runtime.
# Nothing is printed and nothing is written to disk. NEVER echo the exported variables.
SH_LOCAL_PROFILE="${SH_LOCAL_PROFILE:-$HOME/repos/smarthome4/smarthome-core/src/main/resources/application-local.yaml}"
_sh_get() { sed -n "s/^ *$1: *\"\([^\"]*\)\".*/\1/p" "$SH_LOCAL_PROFILE" | head -1; }
export MQTT_HOST="${MQTT_HOST:-192.168.1.3}" MQTT_PORT="${MQTT_PORT:-31883}" Z2M_TOPIC="${Z2M_TOPIC:-zigbee2mqtt}"
export MQTT_USERNAME="$(_sh_get username)" MQTT_PASSWORD="$(_sh_get password)"
export HA_BASE_URL="${HA_BASE_URL:-https://homeassistant.hess.pm}" HA_API_TOKEN="$(_sh_get apiToken)"
export SH_VENV="${SH_VENV:-$HOME/.cache/smarthome-skill/venv}"
