#!/usr/bin/env python3
"""Talk to the LOCAL smarthome4-ui backend (start it with run-ui-backend.sh, port 8000).
The deployed UI at lights.hess.pm sits behind a Cognito login and is not reachable from the
Playwright browser, so scenes and labels are created through this local backend instead.

  ui_api.py groups [regex]                         Z2M groups with members and scenes (null for ~10 s after start)
  ui_api.py scene <group> <name> <ieee:bri:mired>...   MUTATING, creates a scene and the lights change physically.
                                                   bri 0-254, mired 150-500 (250 cool white, 370 warm, 400 very warm)
  ui_api.py labels-create <name>...                MUTATING, creates Home Assistant labels
  ui_api.py assign <entity_id>=<label_id>...       MUTATING, assigns labels to scene entities
  ui_api.py unassign <entity_id>=<label_id>...     MUTATING, removes labels from scene entities
  ui_api.py assignments [regex]                    scene entities with their labels (read-only)
A label id is the label name in lowercase with every run of other characters turned into _
(Badezimmer Oben__DimmerSwitch__01__day__1 -> badezimmer_oben_dimmerswitch_01_day_1).
"""
import json, re, sys, urllib.parse, urllib.request
BASE = "http://localhost:8000"
def call(path, body=None):
    req = urllib.request.Request(BASE + path, data=None if body is None else json.dumps(body).encode(),
                                 headers={"Content-Type": "application/json"}, method="GET" if body is None else "POST")
    return json.load(urllib.request.urlopen(req, timeout=90))
a = sys.argv[1:]
if not a: print(__doc__); sys.exit(0)
cmd, rest = a[0], a[1:]
if cmd == "groups":
    d = call("/api/groups")["data"]
    if d is None: sys.exit("backend not ready (MQTT still connecting), retry in a few seconds")
    rx = re.compile(rest[0], re.I) if rest else None
    for g in d:
        if rx and not rx.search(g["friendly_name"]): continue
        print(g["id"], g["friendly_name"], [m["friendly_name"] for m in g["members"]], [(s["id"], s["name"]) for s in g["scenes"]])
elif cmd == "scene":
    group, name, devs = rest[0], rest[1], rest[2:]
    body = {"name": name, "devices": [dict(zip(("ieee_address", "brightness", "color_temp"), (x.split(":")[0], int(x.split(":")[1]), int(x.split(":")[2])))) for x in devs]}
    print(call("/api/groups/%s/scenes" % urllib.parse.quote(group), body))
elif cmd == "labels-create":
    print(call("/api/labels/create", {"names": rest}))
elif cmd == "assign":
    print(call("/api/assignments/apply", {"add": [{"entity_id": x.split("=")[0], "label_id": x.split("=")[1]} for x in rest], "remove": []}))
elif cmd == "unassign":
    print(call("/api/assignments/apply", {"add": [], "remove": [{"entity_id": x.split("=")[0], "label_id": x.split("=")[1]} for x in rest]}))
elif cmd == "assignments":
    d = call("/api/assignments/state")["data"]; names = {l["label_id"]: l["name"] for l in d["labels"]}
    rx = re.compile(rest[0], re.I) if rest else None
    for s in d["scenes"]:
        if not rx or rx.search(s["entity_id"]): print(s["entity_id"], "->", [names.get(i, i) for i in s["label_ids"]])
else:
    print(__doc__)
