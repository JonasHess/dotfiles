#!/usr/bin/env python3
"""Zigbee2MQTT helper over the MQTT broker. Credentials come from the environment (source creds.sh)
or, if unset, straight from the smarthome4 local profile. Run with the skill venv:
  $HOME/.cache/smarthome-skill/venv/bin/python z2m.py <command> ...

Read-only:
  devices [regex]            list devices (name, ieee, model, power); regex filters on name or model
  motion                     list all devices exposing occupancy or presence
  status                     retained smarthome4/status of the app (state loaded or error)
  watch <device...> [secs]   print button presses (topic <device>/action), default 120 s
  get <device> '<json>'      ask the device to report attributes, e.g. '{"operation_mode_left": ""}'
                             (read-only, the answer shows up in Home Assistant a few seconds later)
MUTATING (changes the real Zigbee network or devices):
  group-create <id> <name> <device...>   create a group and add the devices
  group-add <group> <device...>          add members (DUPLICATE_EXISTS: remove, then add again)
  group-remove <group> <device...>       remove members
  permit-join <seconds>                  open (or with 0 close) the pairing window, max 254
  set <device> '<json>'                  publish to <device>/set, e.g. '{"state_left": "ON"}'
"""
import json, os, re, sys, time
import paho.mqtt.client as mqtt

PROFILE = os.path.expanduser("~/repos/smarthome4/smarthome-core/src/main/resources/application-local.yaml")
def cred(env, key):
    if os.environ.get(env): return os.environ[env]
    return re.search(r'^\s*%s:\s*"([^"]*)"' % key, open(PROFILE).read(), re.M).group(1)

def connect(subs=()):
    got = []
    c = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2, client_id="claude-smarthome-%d" % os.getpid())
    c.username_pw_set(cred("MQTT_USERNAME", "username"), cred("MQTT_PASSWORD", "password"))
    c.on_message = lambda cl, ud, m: got.append((m.topic, m.payload.decode()))
    c.connect(os.environ.get("MQTT_HOST", "192.168.1.3"), int(os.environ.get("MQTT_PORT", "31883")), 30)
    for s in subs: c.subscribe(s)
    c.loop_start()
    return c, got

def props(exposes):
    out = set()
    for e in exposes or []:
        if "property" in e: out.add(e["property"])
        out |= props(e.get("features"))
    return out

def retained(topic, wait=6):
    c, got = connect([topic]); time.sleep(wait); c.loop_stop(); c.disconnect()
    return json.loads(got[-1][1]) if got else None

def request(c, got, topic, payload, wait=4):
    c.publish("zigbee2mqtt/bridge/request/" + topic, json.dumps(payload)); time.sleep(wait)

def main(a):
    if not a: print(__doc__); return
    cmd, rest = a[0], a[1:]
    if cmd in ("devices", "motion"):
        devs = retained("zigbee2mqtt/bridge/devices", 8)
        rx = re.compile(rest[0], re.I) if rest else None
        for d in sorted(devs, key=lambda d: d["friendly_name"]):
            df = d.get("definition") or {}
            if d.get("type") == "Coordinator": continue
            if cmd == "motion" and not (props(df.get("exposes")) & {"occupancy", "presence"}): continue
            if rx and not (rx.search(d["friendly_name"]) or rx.search(df.get("model") or "")): continue
            print(d["friendly_name"], "|", d["ieee_address"], "|", df.get("model"), "|", d.get("power_source"))
    elif cmd == "status":
        print(retained("smarthome4/status"))
    elif cmd == "watch":
        secs = int(rest[-1]) if rest[-1].isdigit() else 120
        names = [r for r in rest if not r.isdigit()]
        c, got = connect(["zigbee2mqtt/%s/action" % n for n in names]); seen = 0; end = time.time() + secs
        while time.time() < end:
            while seen < len(got):
                print(time.strftime("%H:%M:%S"), got[seen][0].split("/")[1], got[seen][1], flush=True); seen += 1
            time.sleep(0.5)
        c.loop_stop(); c.disconnect()
    else:
        c, got = connect(["zigbee2mqtt/bridge/response/#"])
        time.sleep(1)
        if cmd == "group-create":
            gid, name, devices = rest[0], rest[1], rest[2:]
            request(c, got, "group/add", {"friendly_name": name, "id": gid})
            for d in devices: request(c, got, "group/members/add", {"group": name, "device": d})
        elif cmd in ("group-add", "group-remove"):
            for d in rest[1:]: request(c, got, "group/members/" + cmd.split("-")[1], {"group": rest[0], "device": d})
        elif cmd == "permit-join":
            request(c, got, "permit_join", {"time": int(rest[0])}, 2)
        elif cmd == "set":
            c.publish("zigbee2mqtt/%s/set" % rest[0], rest[1]); time.sleep(2)
        elif cmd == "get":
            c.publish("zigbee2mqtt/%s/get" % rest[0], rest[1]); time.sleep(2)
        else:
            print(__doc__)
        for t, p in got: print(t.replace("zigbee2mqtt/bridge/response/", ""), "->", p[:300])
        c.loop_stop(); c.disconnect()

main(sys.argv[1:])
