#!/usr/bin/env python3
"""Pair cheap Zigbee bulbs that are powered through an Aqara relay by power-cycling the relay.
MUTATING: opens the pairing window and switches a relay. Run with the skill venv.

  pair_cycle.py <relay-device> <state_left|state_right> [cycles=3] [wait=75]

The recipe that worked (Livarno GU10 spots, three bulbs on one relay):
  - exactly 3 slow cycles (3 s on, 3 s off), then STOP and leave the relay on
  - more cycles reset bulbs that already joined again (they leave and must rejoin)
  - a bulb stays in pairing mode only about a minute, so keep the window open while cycling
  - joined bulbs may keep a remembered name (BadezimmerDecke-1 ...); the first bulb of a set can
    have a different address prefix than its siblings
The script prints every join and interview event and closes the pairing window at the end.
"""
import json, os, re, sys, time
import paho.mqtt.client as mqtt
PROFILE = os.path.expanduser("~/repos/smarthome4/smarthome-core/src/main/resources/application-local.yaml")
txt = open(PROFILE).read()
def cred(env, key): return os.environ.get(env) or re.search(r'^\s*%s:\s*"([^"]*)"' % key, txt, re.M).group(1)
def log(*a): print(time.strftime("%H:%M:%S"), *a, flush=True)

relay, key = sys.argv[1], sys.argv[2]
cycles = int(sys.argv[3]) if len(sys.argv) > 3 else 3
wait = int(sys.argv[4]) if len(sys.argv) > 4 else 75
present = {}
c = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2, client_id="claude-pair-%d" % os.getpid())
c.username_pw_set(cred("MQTT_USERNAME", "username"), cred("MQTT_PASSWORD", "password"))
def on_message(cl, ud, m):
    try: p = json.loads(m.payload.decode())
    except Exception: return
    t, d = p.get("type"), p.get("data", {})
    if t == "device_joined": present[d.get("ieee_address")] = d.get("friendly_name"); log("JOINED", d.get("friendly_name"), d.get("ieee_address"))
    elif t == "device_interview" and d.get("status") == "successful": log("INTERVIEWED", d.get("friendly_name"))
    elif t == "device_leave": present.pop(d.get("ieee_address"), None); log("LEFT", d.get("friendly_name"))
c.on_message = on_message
c.connect(os.environ.get("MQTT_HOST", "192.168.1.3"), int(os.environ.get("MQTT_PORT", "31883")), 30)
c.subscribe("zigbee2mqtt/bridge/event"); c.loop_start(); time.sleep(1)
permit = lambda s: c.publish("zigbee2mqtt/bridge/request/permit_join", json.dumps({"time": s}))
try:
    permit(240); log("pairing window open")
    for i in range(cycles):
        c.publish("zigbee2mqtt/%s/set" % relay, json.dumps({key: "OFF"})); time.sleep(3)
        c.publish("zigbee2mqtt/%s/set" % relay, json.dumps({key: "ON"})); time.sleep(3)
        log("cycle", i + 1, "of", cycles)
    log("cycling stopped, relay on, waiting", wait, "s for joins")
    time.sleep(wait)
    log("RESULT joined:", sorted(n for n in present.values() if n))
finally:
    c.publish("zigbee2mqtt/%s/set" % relay, json.dumps({key: "ON"})); permit(0); log("relay on, pairing window closed")
    time.sleep(2); c.loop_stop(); c.disconnect()
