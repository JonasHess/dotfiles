---
name: smarthome
description: Everything needed to work on Jonas' smarthome - the smarthome4 app, Zigbee2MQTT (Z2M), Home Assistant (HA), the smarthome4-ui and the homelab-environments config repo. Use when the user mentions the smarthome, smarthome4, Zigbee2MQTT, Home Assistant, motion or presence sensors (M01, S23 ...), Aqara or Hue switches (SW-1OG-...), lights, scenes, labels, relays, the bathroom fan, or lights.hess.pm. Holds architecture, access recipes, naming rules, step-by-step procedures, gotchas and tested helper scripts.
---

# Jonas' smarthome

Knowledge collected while wiring switches, sensors, scenes and automations in October 2026.
**State-specific facts (what is deployed, which sensor sits where) go stale. Re-read the live config and the Z2M devices before relying on them.**
The user says the smarthome is NOT "production": the real broker and Home Assistant may be used. That is not a licence to change things silently: see section 3.

## 0. Helper scripts (run `scripts/setup.sh` once)

All in `~/.claude/skills/smarthome/scripts/`. They read credentials at runtime from the gitignored `application-local.yaml` and never print them. Python ones run with `~/.cache/smarthome-skill/venv/bin/python`.

| Script | Does |
|---|---|
| `setup.sh` | creates the venv (paho-mqtt plus the UI backend requirements) |
| `creds.sh` | `source` it to export MQTT_* and HA_* variables (never echo them) |
| `ha.sh get/find/template/call` | Home Assistant REST (only `call` mutates) |
| `z2m.py devices/motion/status/watch` | read Z2M devices, the app status, button presses |
| `z2m.py group-create/group-add/group-remove/permit-join/set` | MUTATING Z2M helpers |
| `pair_cycle.py` | pairs cheap bulbs by power-cycling an Aqara relay (see 6.3) |
| `run-ui-backend.sh` | starts the smarthome4-ui backend locally on port 8000 against the real system |
| `ui_api.py` | scenes, labels, assign and unassign through that local backend |
| `validate_config.js` | checks `smarthome-config.yaml` (devices, types, profiles, references) before a commit |

## 1. Big picture

```
Zigbee devices -> Zigbee2MQTT -> Mosquitto (192.168.1.3:31883) -> smarthome4 app -> Home Assistant REST (lights, scenes)
                      |                                    ^
                      +-> HA via MQTT discovery            +-- smarthome4-ui (React + FastAPI): scenes, labels, config editor
```

| Repo (all under `~/repos/`) | What |
|---|---|
| `smarthome4` | Java/Spring app (`smarthome-core`). Spec: `docs/SMARTHOME_CONFIG_SPEC.md`, project notes: `CLAUDE.md`. CI builds an image on every push to `main`. `application-local.yaml` (gitignored) holds the local credentials. |
| `smarthome4-ui` | React frontend plus FastAPI backend. Deployed at `lights.hess.pm` behind a Cognito login. Backend env: `MQTT_*`, `HA_BASE_URL`, `HA_API_TOKEN`. |
| `homelab-environments` | GitOps repo. **Live smarthome config:** `hess.pm/smarthome4-config/smarthome-config.yaml`. **Home Assistant config:** `hess.pm/homeassistant-config/` (`automations.yaml`, `configuration.yaml`, ...). |

Cluster: kubectl context `config.d-hess.pm`, namespace `argocd` (pods `smarthome4-deployment-*`, `zigbee2mqtt-deployment-*`, `mosquitto-deployment-*`, `smarthome4-ui-deployment-*`). LAN: node and k8s API `192.168.1.3` (API port 16443), gateway `192.168.1.80`. Home Assistant: `https://homeassistant.hess.pm`.

**Deploy path.** Push to `main` of homelab-environments, ArgoCD syncs.
- smarthome4 config: ConfigMap `smarthome4-app-config`. The app refreshes its model about every 10 minutes (the retained topic `smarthome4/status` shows `loaded` or `error` with a timestamp). A pod restart with a bad config leaves it without a model.
- Home Assistant config: ConfigMap `homeassistant-app-config` (`templates/configmap.yaml` lists files explicitly, so a new file must be added there). An init container copies `/configmap/*.yaml` over `/config/` at pod start, so **git wins and UI edits of those files are lost**. A reloader restarted HA within minutes of a push (about 1 minute downtime, API answers 503). A restart from inside HA is NOT enough, only a pod restart re-copies the files.

## 2. Access recipes (what works from Jonas' Mac)

- **MQTT (works):** python with paho, `z2m.py`. `nc`/`curl` also reach `192.168.1.3`.
- **Home Assistant REST (works):** `ha.sh`. Labels are websocket-only, so use the UI backend for them.
- **kubectl (broken here):** fails with "no route to host" for `192.168.1.3:16443` although `curl`, `nc` and python reach it (probably the macOS Local Network permission for that binary). Do not call it a VPN problem. Ask the user to run a `! kubectl ...` command instead, always with `--context config.d-hess.pm`.
- **Playwright browser (cannot reach the LAN hosts):** `lights.hess.pm` redirects to Cognito and then to an unreachable address. Run the UI backend locally and use `ui_api.py`, or localhost URLs.
- **HA MCP server:** had an invalid token (403) and later could not connect. Prefer `ha.sh`.
- **No `mosquitto_pub`** on the machine.
- Z2M does not publish `zigbee2mqtt/bridge/groups` here. List groups and scenes via `ui_api.py groups` (returns null for ~10 s after the backend starts).
- A local `smarthome4` app run must use a unique MQTT client id (`--mqtt.broker.client-id=...`), because the prod pod uses the default `smarthome4-backend` and a duplicate kicks it off the broker. Use a scratch config with only the sensor under test, or every real event is handled twice. It publishes retained `smarthome4/status` and discovery topics (harmless, prod republishes).
- Maven: `mvn -s <empty settings.xml>` goes to Maven Central; `~/.m2/settings.xml` points to a VPN-only Nexus. Never edit `~/.m2/settings.xml`.

## 3. Rules for touching the real system

- Read-only first: states, devices, retained topics, the live config. Say what you saw.
- Anything that moves a relay, switches a light, changes a device setting, creates a group or scene, opens pairing, or sets a helper is a change to the real house. Do it only when the user asked for exactly that or said "do all of this", verify with a read-back, and report it.
- **Side effects to remember and undo or report:** saving a scene leaves the lights ON; turning a relay on can start a fan or a pump; the right relay of `SW-1OG-Badezimmer-Flur` powers the bathroom fan, and it was switched on by mistake once. Before setting relays, find out what hangs on them.
- Commits, pushes and Redmine writes need a fresh explicit OK each time (global CLAUDE.md). "Then commit" means commit only, not push.
- Never print or store tokens and passwords. Tokens that were printed once are in old transcripts; offer to rotate.
- When asked to "summarize my instructions first", do exactly that, flag ambiguities, change nothing until the user has reviewed.
- One question at a time, with a recommendation and a confidence percent.

## 4. Naming and conventions

- **Device ids:** `M01`..`M12` Aqara presence (FP300 = Z2M model `PS-S04D`, battery; FP1E mains), `S19`..`S25` Hue motion (9290012607 = SML001), `M16` Hue outdoor (9290030674, the app type is `HueSML004`), `SW-<floor>-<room>-<n>` Aqara H2 wall switches, lamps by room name.
- **New device or profile types** are named after the exact product model (`HueSML004`, `AqaraFP300`), never generic names. Enums: `SensorType`, `GroupProfile`, `TriggerType` (+ `Application*` twins), profile handler factory, option registry, tests, UI enums.
- **Resource ids:** `light_<room>` for lights (static entity `light.<z2m group name as slug>`), scenes `<Group> DimmerSwitch 01 Day` and `... Night`.
- **Scene labels in HA:** `<Z2M group name>__DimmerSwitch__01__<day|night>__<N>` (N is the cycle position, 1 for a single scene). Label id = lowercase with other characters turned into `_`. The config resource uses `labelRegex: <Group>__DimmerSwitch__01__day__.*`.
- **Z2M groups:** one group per set of lights that shares scenes. A group name must differ from every device name (a one-lamp group cannot be called like the lamp). HA entities appear as `light.<group>` and `scene.<group>_<id>_<scene>`; scenes are named `Bright` (Day) and `Nightlight` (Night).
- **Entry names** in the config are plain room names, e.g. `1OG Badezimmer Motion`, `Treppe Keller Motion Aqara`.

## 5. smarthome4 config facts (details in `docs/SMARTHOME_CONFIG_SPEC.md`)

- **A missing static entity or a label regex without scenes makes the WHOLE refresh fail** (old model stays live, a restart has no model). Create Z2M groups, scenes, labels and HA entities BEFORE pushing a config that uses them. `validate_config.js` cannot check this.
- An entry has exactly one sensor type. Rooms with two types need twin entries with identical lights and scenes (`... Hue`, `... Aqara`). OR aggregation of presence only happens inside one entry, so one sensor clearing can switch lights off while the other still sees someone (fine on stairs, bad in kitchens and living rooms).
- Presence profiles: `offDelaySeconds` (default 60 s), `maxIlluminance` (FP300 and Hue only). An off-delay of 0 with a Hue sensor means lights go off seconds after motion (Hue reports `occupancy: false` after about 3 s), so check the device's `occupancy_timeout`.
- **2-channel Aqara H2 switch:** two groups at the same `position`, profiles `AqaraLightSwitchH2_2ChLeftLightDefault` and `...Right...`, triggers `AQARA_LIGHT_SWITCH_H2_2CH_LEFT_UP` etc. UP runs the sequences, DOWN turns the group's lights off. 1-channel: `AqaraLightSwitchH2_1ChLightDefault` with `AQARA_LIGHT_SWITCH_H2_1CH_SINGLE_UP`. `handledButtons: UP|DOWN` splits one rocker between groups.
- **Conditions** (defined at the top of the config): rooms on the EG/1OG route use `morning_bright_or_day` (Day scene) and `morning_dim` (Night scene); rooms that adjoin a bed (Dach, Schlafzimmer) use `bedtime_bright_or_day` / `bedtime_dim` (motion variants `bedtime_bright` / `bedtime_dim`); the guest room keeps the plain clock conditions `day_or_evening` / `night`. `timeOfDay()` is sun based (DAY or NIGHT).
- **Whole-house-off list:** the DOWN group of the front door master switch lists every Light resource and doubles as the motion-lock scope. Add new light resources there when motion or switches control them.
- Quick TDD for code changes: tests first, `mvn -s <empty settings> -pl smarthome-core -am test`.

## 6. Procedures

### 6.1 Wire a new Aqara H2 switch
1. `z2m.py devices '^SW-'` to confirm it is paired. Look up what each gang and relay is wired to.
2. Set both operation modes to `decoupled` (`ha.sh call select/select_option '{"entity_id":"select.<dev>_operation_mode_left","option":"decoupled"}'`, same for right/up). Then switch the relays ON (`switch.<dev>_left|right|up`): decoupled switches keep smart bulbs powered through an always-on relay. Set `select.<dev>_power_on_behavior` to `off` for relays that carry a fan.
3. Groups, scenes, labels (6.2), then the config entry, `validate_config.js`, commit, push.
4. Test with `z2m.py watch <dev> 300` while the user presses, and check the light states 4+ s later (turn-on can take longer than 4 s).

### 6.2 New group, scenes, labels
1. `z2m.py group-create <free id> "<Name>" <device names...>`. If a lamp answers "Delivery failed" it is offline or its relay is off. `DUPLICATE_EXISTS` means the bulb still remembers the group: `group-remove` then `group-add`.
2. `run-ui-backend.sh &`, wait ~12 s, `ui_api.py groups`.
3. `ui_api.py scene "<Group>" Bright <ieee>:254:250 ...` and `... Nightlight <ieee>:51:400 ...` (brightness 0-254, mired 150-500; defaults used: ceiling Bright 254/250, Night 51 to 76/370 to 400, bedside Bright 152, Night 38). Each call takes about 3 s and switches the lights: turn them off afterwards.
4. `ui_api.py labels-create ...` then `ui_api.py assign scene.<group>_1_bright=<label_id> ...`, then `ui_api.py assignments <regex>` to read back.
5. Stop the backend: `pkill -f "uvicorn app.main:app"`.

### 6.3 Pair cheap Zigbee bulbs behind a relay
`pair_cycle.py <relay device> state_left 3 75`: opens pairing, does exactly 3 slow cycles (3 s on, 3 s off), then stops and waits. More cycles reset bulbs that already joined. A bulb stays in pairing mode only about a minute, so rejoin needs the window open. If it fails, repeat the same recipe. After pairing, add them to the group with `z2m.py group-add`.

### 6.4 Swap or add sensors
Read the current entries, write the plan back to the user, wait for the review, then edit. Keep each device in one entry, split by sensor type, keep scenes and off-delay of the original room, run `validate_config.js`, commit. Warn that a push before the hardware is moved leaves the room without a sensor. A moved Aqara sensor keeps its pairing; only the config changes.

### 6.5 Home Assistant automation or helper (in git)
Edit `hess.pm/homeassistant-config/automations.yaml` or `configuration.yaml` (new `input_number` without `initial:`, like the Katzenalarm ones, so UI values survive restarts). After the deploy: wait for the HA restart (`ha.sh find <name>`), then set helper values once (they start at their minimum). Use `ha.sh template` to test templates. The bathroom fan automation: `automation.1og_bathroom_fan_follows_the_lights` starts `switch.sw_1og_badezimmer_flur_right` after a bathroom light has been on for `input_number.badezimmer_luefter_verzoegerung` minutes (3) and stops it `input_number.badezimmer_luefter_nachlauf` minutes (10) after both lights went off.

### 6.6 "Is it deployed and working?"
`z2m.py status` (state and timestamp of the last refresh), `ha.sh find <new entity>` for HA changes, then a real press with `z2m.py watch`. The app status does not say which config version it holds, so the physical test decides.

## 7. Hardware and wiring facts

- `SW-1OG-Badezimmer-Flur`: left relay powers the 3 ceiling bulbs (`BadezimmerDecke-1..3`, Livarno `HG06492A/HG08130A`, group `Badezimmer Oben`, id 3), right relay powers the fan. Rockers: left = mirror lights, right = ceiling (software, decoupled). `SW-1OG-BAD` (inside the bathroom): its rocker = mirror lights (Hue `Lampe_1OG_Badezimmer_Spiegel_1/2`, group `Badezimmer Spiegel`, id 27).
- `SW-1OG-Gaestezimmer`: left rocker = ceiling lamp (group `Gaestezimmer Deckenlampe`, 25), right rocker = two bedside lamps (group `Gaestezimmer Nachttischlampen`, 26). The old Hue dimmers S47, S56, S63 are still in the `Gästezimmer` entry.
- Aqara H2 button actions on `zigbee2mqtt/<dev>/action`: `single_left`, `single_right`, `single_left_down`, `single_right_down` (2ch), `single`/`single_down` (1ch).
- Z2M API payloads (topics under `zigbee2mqtt/bridge/request/`): `group/add {"friendly_name","id"}`, `group/members/add|remove {"group","device"}`, `permit_join {"time":N}` (max 254), device `set` e.g. `{"state_left":"ON"}`.
- Hue motion sensors report `occupancy` and illuminance as separate messages; `occupancy: false` follows motion after about 3 s unless `occupancy_timeout` is raised (the setting is written to endpoint 2).

## 8. Gotchas

- zsh: `echo "====="` is parsed as a command, `set -- $var` does not word-split, `alias k` breaks function definitions, macOS `sed -i ''`. Use quoted heredocs (`<<'EOF'`) when text contains backticks, or the shell swallows them.
- **The user also changes the house between turns** (renames lamps, rebuilds scenes). Re-read groups, scenes and labels right before applying a plan made from earlier reads. `ui_api.py unassign` reports success even for entities that do not exist, so always read back with `ui_api.py assignments <regex>`.
- **Label order pattern:** every scene of a group has exactly one day label and one night label, numbered by cycle step without repeats (labels move with the scene entity id, not with the scene name). Pattern used: day starts with the brightest scene, night with the dimmest. Label ids for steps 1 to 4 already exist for most groups ("name already in use" on create is fine).
- A freshly restarted HA shows entities as `unknown` until they report.
- After a long run of `permit_join`, close it again (`z2m.py permit-join 0`).
- `ha.sh` and the other scripts must never be pointed at a staging or cloud system.
- Write notes and deliverables as files under `notes-local/` of the relevant repo (gitignored) and open them with `idea -e <path>`.
- Do not leave scratch files in repos; use the session scratchpad.

## 9. Open items at the time of writing (verify before acting)

- The `Terrasse Motion` entry (M16) refers to `light.terrasse` and scenes that do not exist, which can stop the whole refresh. Fix: create the terrace group, scenes and labels, or remove the entry.
- The sensor swap (S19/S20/S21 replace M02/M05/M01, S22/S25 join the cellar stairs, M01 to the bathroom, M02 and M05 to the cellar) is pushed, the hardware still had to be moved. The stairs entries use off-delay 0, so check the Hue sensors' `occupancy_timeout`.
- `SW-1OG-Badezimmer-Flur` rockers were never seen pressing in a test; the fan relay's `power_on_behavior` is not set to `off`.
- `M09` is an FP1E in Z2M but its entry says `AqaraFP300`.
