---
name: smarthome
description: Work on the smarthome4 home-automation stack - the smarthome4 app, Zigbee2MQTT (Z2M), Home Assistant (HA), the smarthome4-ui, and the homelab-environments GitOps repo. Use when the user mentions the smarthome, smarthome4, Zigbee2MQTT, Home Assistant, motion or presence sensors (M.. / S..), Aqara or Hue switches (SW-..), lights, scenes, labels, relays, the bathroom fan, or a lights.<domain> UI. Holds the shared architecture, tools, naming conventions, procedures, gotchas and helper scripts; concrete endpoints and device inventory are per-environment and read live.
---

# smarthome4 home automation

This dotfiles repo is shared, and more than one person runs the same smarthome4 stack, each in their OWN environment. Known environments: **hess.pm** (Jonas) and **zimmermann.lat** (Michael). They share the architecture, tools, conventions and procedures below. Everything concrete - domain, LAN addresses, cluster context, device inventory, room wiring, what is deployed - is per-environment and must be read from that environment's own config and live systems. Never assume one environment's values for another, and never point a tool at someone else's environment.

**State-specific facts go stale.** Which sensor sits where, which relay drives what, what is currently deployed: re-read the live Z2M devices and the live config before relying on any of it.

The smarthome may be the real, running home: the broker and Home Assistant in use can be live. That is not a licence to change things silently - see section 3.

## Per-environment values (never hardcode - look them up)

Each environment defines its own values. Get connection endpoints from that environment's gitignored credentials (`creds.sh` / the app's `application-local.yaml`); get config and inventory from that environment's folder in `homelab-environments` and from the live Z2M/HA systems. Ask the user which environment you are working in if it is not obvious; do not guess.

| What | Shape / where to get it |
|---|---|
| Domain | e.g. `hess.pm` or `zimmermann.lat` |
| smarthome4-ui URL | `lights.<domain>` (typically behind a Cognito login) |
| Home Assistant URL | `https://homeassistant.<domain>` |
| MQTT broker / LAN node | `host:port` from `creds.sh` (`MQTT_*`); the broker commonly listens on `31883` |
| kubectl context / namespace | context `config.d-<domain>`, namespace `argocd` |
| Live smarthome4 config | `homelab-environments/<domain>/smarthome4-config/smarthome-config.yaml` |
| Home Assistant config | `homelab-environments/<domain>/homeassistant-config/` |

Always pass an explicit `--context config.d-<domain>` to kubectl; never rely on whatever context is current. The concrete device inventory and physical wiring are NOT in this skill on purpose - they differ per home and go stale. Read them from the live config and the live Z2M/HA systems.

## Keep this skill improving (self-maintenance)

Treat this file as a living document and improve it continuously. Whenever you learn something durable that a future session would want - a new gotcha, a corrected or better procedure, a tool quirk, a fixed recipe, a wrong detail - update this `SKILL.md` (and the `scripts/`) right then, as a matter of course, not only when asked.

- Keep every addition environment-neutral: shared knowledge belongs here; environment-specific state (device inventory, wiring, what is currently deployed) does NOT - that stays in the live config and per-deployment notes (see section 9).
- After improving it, COMMIT the change to the dotfiles repo yourself with an honest message (`smarthome skill - <what changed>`). Do NOT push - leave pushing to the user.
- This is a deliberate, user-granted exception to the global "ask before every commit" rule, and it is NARROW: it covers ONLY this skill's own files (`SKILL.md` and `scripts/`). Everything else - the smarthome config, the `homelab-environments` repo, any change to the real system - still needs a fresh explicit OK for each commit and is NEVER pushed by you.
- Never commit secrets, and run the global stray-character byte-check after editing.

## 0. Helper scripts (run `scripts/setup.sh` once)

All in `~/.claude/skills/smarthome/scripts/`. They read credentials at runtime from the gitignored `application-local.yaml` and never print them, so the same scripts work in any environment once its credentials are in place. Python ones run with `~/.cache/smarthome-skill/venv/bin/python`.

| Script | Does |
|---|---|
| `setup.sh` | creates the venv (paho-mqtt plus the UI backend requirements) |
| `creds.sh` | `source` it to export `MQTT_*` and `HA_*` variables (never echo them) |
| `ha.sh get/find/template/call` | Home Assistant REST (only `call` mutates) |
| `z2m.py devices/motion/status/watch` | read Z2M devices, the app status, button presses |
| `z2m.py group-create/group-add/group-remove/permit-join/set` | MUTATING Z2M helpers |
| `pair_cycle.py` | pairs cheap bulbs by power-cycling a relay (see 6.3) |
| `run-ui-backend.sh` | starts the smarthome4-ui backend locally on port 8000 against the configured system |
| `ui_api.py` | scenes, labels, assign and unassign through that local backend |
| `validate_config.js` | checks `smarthome-config.yaml` (devices, types, profiles, references) before a commit |

## 1. Big picture

```
Zigbee devices -> Zigbee2MQTT -> Mosquitto (<mqtt-host>:31883) -> smarthome4 app -> Home Assistant REST (lights, scenes)
                      |                                    ^
                      +-> HA via MQTT discovery            +-- smarthome4-ui (React + FastAPI): scenes, labels, config editor
```

| Repo (all under `~/repos/`) | What |
|---|---|
| `smarthome4` | Java/Spring app (`smarthome-core`). Spec: `docs/SMARTHOME_CONFIG_SPEC.md`, project notes: `CLAUDE.md`. CI builds an image on every push to `main`. `application-local.yaml` (gitignored) holds the local credentials. |
| `smarthome4-ui` | React frontend plus FastAPI backend. Deployed at `lights.<domain>` behind a Cognito login. Backend env: `MQTT_*`, `HA_BASE_URL`, `HA_API_TOKEN`. |
| `homelab-environments` | GitOps repo, one folder per environment keyed by domain. Live smarthome config: `<domain>/smarthome4-config/smarthome-config.yaml`. Home Assistant config: `<domain>/homeassistant-config/`. |

Cluster: kubectl context `config.d-<domain>`, namespace `argocd` (pods `smarthome4-deployment-*`, `zigbee2mqtt-deployment-*`, `mosquitto-deployment-*`, `smarthome4-ui-deployment-*`). The LAN node / k8s API address and gateway are per-environment (from `creds.sh`). Home Assistant: `https://homeassistant.<domain>`.

**Deploy path.** Push to `main` of homelab-environments, ArgoCD syncs.
- smarthome4 config: ConfigMap `smarthome4-app-config`. The app refreshes its model about every 10 minutes (the retained topic `smarthome4/status` shows `loaded` or `error` with a timestamp). A pod restart with a bad config leaves it without a model.
- Home Assistant config: ConfigMap `homeassistant-app-config` (`templates/configmap.yaml` lists files explicitly, so a new file must be added there). An init container copies `/configmap/*.yaml` over `/config/` at pod start, so **git wins and UI edits of those files are lost**. A reloader restarts HA within minutes of a push (about 1 minute downtime, API answers 503). A restart from inside HA is NOT enough, only a pod restart re-copies the files.

## 2. Access recipes

Some of these are properties of the stack (true everywhere); some are quirks of one person's machine. Treat machine quirks as "may differ for you" and confirm against your own setup.

- **MQTT (works):** python with paho, `z2m.py`. `nc`/`curl` also reach the broker host.
- **Home Assistant REST (works):** `ha.sh`. Labels are websocket-only, so use the UI backend for them.
- **kubectl:** when the LAN k8s API is unreachable from a tool but `curl`/`nc`/python reach the same host:port, it is usually a local-machine issue (e.g. macOS Local Network permission for that binary), not a VPN problem. Ask the user to run a `! kubectl ...` command instead, always with `--context config.d-<domain>`.
- **Playwright browser:** `lights.<domain>` redirects through Cognito and may be unreachable headless. Run the UI backend locally and use `ui_api.py`, or localhost URLs.
- **HA MCP server:** has been unreliable (bad token / cannot connect). Prefer `ha.sh`.
- `mosquitto_pub` may not be installed; use the python/paho helpers instead.
- Z2M may not publish `zigbee2mqtt/bridge/groups`; list groups and scenes via `ui_api.py groups` (returns null for ~10 s after the backend starts).
- **Unique MQTT client id for a local app run (important):** a local `smarthome4` run must use a unique `--mqtt.broker.client-id=...`, because the deployed pod uses the default `smarthome4-backend` and a duplicate kicks it off the broker. Use a scratch config with only the sensor under test, or every real event is handled twice. A local run publishes retained `smarthome4/status` and discovery topics (harmless, the deployed app republishes).
- **Maven:** building `smarthome-core` may need the project's own Maven settings/mirror; a bare `mvn -s <empty settings.xml>` goes to Maven Central. Do not edit a machine's `~/.m2/settings.xml`.

## 3. Rules for touching the real system

- Read-only first: states, devices, retained topics, the live config. Say what you saw.
- Anything that moves a relay, switches a light, changes a device setting, creates a group or scene, opens pairing, or sets a helper is a change to the real house. Do it only when the user asked for exactly that or said "do all of this", verify with a read-back, and report it.
- **Side effects to remember and undo or report:** saving a scene leaves the lights ON; turning a relay on can start a fan or a pump. Some relays carry a fan/pump rather than a light. Before setting any relay, find out what is wired to it.
- Commits, pushes and Redmine writes need a fresh explicit OK each time (global CLAUDE.md). "Then commit" means commit only, not push.
- Never print or store tokens and passwords. Tokens that were printed once are in old transcripts; offer to rotate.
- When asked to "summarize my instructions first", do exactly that, flag ambiguities, change nothing until the user has reviewed.
- One question at a time, with a recommendation and a confidence percent.

## 4. Naming and conventions

These conventions are shared across environments; the concrete ids/ranges a given home uses are read from its live config.

- **Device ids:** `M<nn>` for Aqara presence sensors, `S<nn>` for Hue motion sensors, `SW-<floor>-<room>-<n>` for Aqara H2 wall switches, lamps by room name. (Example models seen: Aqara FP300 = Z2M model `PS-S04D` battery, FP1E mains; Hue SML001 = `9290012607`; Hue outdoor `9290030674` with app type `HueSML004`.)
- **New device or profile types** are named after the exact product model (`HueSML004`, `AqaraFP300`), never generic names. Touch the matching set: enums `SensorType`, `GroupProfile`, `TriggerType` (+ `Application*` twins), the profile handler factory, option registry, tests, UI enums.
- **Resource ids:** `light_<room>` for lights (static entity `light.<z2m group name as slug>`); scenes `<Group> DimmerSwitch 01 Day` and `... Night`.
- **Scene labels in HA:** `<Z2M group name>__DimmerSwitch__01__<day|night>__<N>` (N is the cycle position, 1 for a single scene). Label id = lowercase with other characters turned into `_`. The config resource uses `labelRegex: <Group>__DimmerSwitch__01__day__.*`.
- **Z2M groups:** one group per set of lights that shares scenes. A group name must differ from every device name (a one-lamp group cannot be named like the lamp). HA entities appear as `light.<group>` and `scene.<group>_<id>_<scene>`; scenes are named `Bright` (Day) and `Nightlight` (Night).
- **Entry names** in the config are plain room names.

## 5. smarthome4 config facts (details in `docs/SMARTHOME_CONFIG_SPEC.md`)

- **A missing static entity or a label regex without scenes makes the WHOLE refresh fail** (old model stays live, a restart has no model). Create Z2M groups, scenes, labels and HA entities BEFORE pushing a config that uses them. `validate_config.js` cannot check this.
- An entry has exactly one sensor type. Rooms with two types need twin entries with identical lights and scenes (`... Hue`, `... Aqara`). OR aggregation of presence only happens inside one entry, so one sensor clearing can switch lights off while the other still sees someone (fine on stairs, bad in kitchens and living rooms).
- Presence profiles: `offDelaySeconds` (default 60 s), `maxIlluminance` (FP300 and Hue only). An off-delay of 0 with a Hue sensor means lights go off seconds after motion (Hue reports `occupancy: false` after about 3 s), so check the device's `occupancy_timeout`.
- **2-channel Aqara H2 switch:** two groups at the same `position`, profiles `AqaraLightSwitchH2_2ChLeftLightDefault` and `...Right...`, triggers `AQARA_LIGHT_SWITCH_H2_2CH_LEFT_UP` etc. UP runs the sequences, DOWN turns the group's lights off. 1-channel: `AqaraLightSwitchH2_1ChLightDefault` with `AQARA_LIGHT_SWITCH_H2_1CH_SINGLE_UP`. `handledButtons: UP|DOWN` splits one rocker between groups.
- **Conditions** are defined at the top of the config and referenced by entries to pick a Day vs Night scene. Typical pattern: general rooms use day/night variants tied to `timeOfDay()` (sun based: DAY or NIGHT); rooms adjoining a bed use `bedtime_*` variants so they stay dim at night. Read the actual condition names from the live config rather than assuming them.
- **Whole-house-off list:** the DOWN group of the front-door master switch lists every Light resource and doubles as the motion-lock scope. Add new light resources there when motion or switches control them.
- Quick TDD for code changes: tests first, `mvn -s <settings> -pl smarthome-core -am test`.

## 6. Procedures

### 6.1 Wire a new Aqara H2 switch
1. `z2m.py devices '^SW-'` to confirm it is paired. Look up what each gang and relay is wired to.
2. Set both operation modes to `decoupled` (`ha.sh call select/select_option '{"entity_id":"select.<dev>_operation_mode_left","option":"decoupled"}'`, same for right/up). Then switch the relays ON (`switch.<dev>_left|right|up`): decoupled switches keep smart bulbs powered through an always-on relay. Set `select.<dev>_power_on_behavior` to `off` for relays that carry a fan.
3. Groups, scenes, labels (6.2), then the config entry, `validate_config.js`, commit, push.
4. Test with `z2m.py watch <dev> 300` while the user presses, and check the light states 4+ s later (turn-on can take longer than 4 s).

### 6.2 New group, scenes, labels
1. `z2m.py group-create <free id> "<Name>" <device names...>`. If a lamp answers "Delivery failed" it is offline or its relay is off. `DUPLICATE_EXISTS` means the bulb still remembers the group: `group-remove` then `group-add`.
2. `run-ui-backend.sh &`, wait ~12 s, `ui_api.py groups`.
3. `ui_api.py scene "<Group>" Bright <ieee>:254:250 ...` and `... Nightlight <ieee>:51:400 ...` (brightness 0-254, mired 150-500; sensible defaults: ceiling Bright 254/250, Night 51 to 76/370 to 400, bedside Bright 152, Night 38). Each call takes about 3 s and switches the lights: turn them off afterwards.
4. `ui_api.py labels-create ...` then `ui_api.py assign scene.<group>_1_bright=<label_id> ...`, then `ui_api.py assignments <regex>` to read back.
5. Stop the backend: `pkill -f "uvicorn app.main:app"`.

### 6.3 Pair cheap Zigbee bulbs behind a relay
`pair_cycle.py <relay device> state_left 3 75`: opens pairing, does exactly 3 slow cycles (3 s on, 3 s off), then stops and waits. More cycles reset bulbs that already joined. A bulb stays in pairing mode only about a minute, so rejoin needs the window open. If it fails, repeat the same recipe. After pairing, add them to the group with `z2m.py group-add`.

### 6.4 Swap or add sensors
Read the current entries, write the plan back to the user, wait for the review, then edit. Keep each device in one entry, split by sensor type, keep scenes and off-delay of the original room, run `validate_config.js`, commit. Warn that a push before the hardware is moved leaves the room without a sensor. A moved Aqara sensor keeps its pairing; only the config changes.

### 6.5 Home Assistant automation or helper (in git)
Edit `<domain>/homeassistant-config/automations.yaml` or `configuration.yaml` (add a new `input_number` without `initial:` so UI values survive restarts). After the deploy: wait for the HA restart (`ha.sh find <name>`), then set helper values once (they start at their minimum). Use `ha.sh template` to test templates. Follow-the-lights style automations (e.g. a bathroom fan that runs a relay a few minutes after a light goes on and stops it some minutes after the lights go off) are driven by `input_number` helpers for the delay and run-on times; read the live automation for the exact entity and helper names.

### 6.6 "Is it deployed and working?"
`z2m.py status` (state and timestamp of the last refresh), `ha.sh find <new entity>` for HA changes, then a real press with `z2m.py watch`. The app status does not say which config version it holds, so the physical test decides.

## 7. Hardware and protocol facts

- Aqara H2 button actions on `zigbee2mqtt/<dev>/action`: `single_left`, `single_right`, `single_left_down`, `single_right_down` (2ch), `single_up`/`single_down` (1ch).
- Z2M API payloads (topics under `zigbee2mqtt/bridge/request/`): `group/add {"friendly_name","id"}`, `group/members/add|remove {"group","device"}`, `permit_join {"time":N}` (max 254), device `set` e.g. `{"state_left":"ON"}`.
- Hue motion sensors report `occupancy` and illuminance as separate messages; `occupancy: false` follows motion after about 3 s unless `occupancy_timeout` is raised (the setting is written to endpoint 2).
- The concrete per-home wiring (which relay drives which bulbs or fan, group ids, which rocker does what) lives in the live config and the Z2M devices - read it there, it is not duplicated here.

## 8. Gotchas

- zsh: `echo "====="` is parsed as a command, `set -- $var` does not word-split, `alias k` breaks function definitions, macOS `sed -i ''`. Use quoted heredocs (`<<'EOF'`) when text contains backticks, or the shell swallows them.
- **The home changes between turns** (lamps renamed, scenes rebuilt). Re-read groups, scenes and labels right before applying a plan made from earlier reads. `ui_api.py unassign` reports success even for entities that do not exist, so always read back with `ui_api.py assignments <regex>`.
- **Label order pattern:** every scene of a group has exactly one day label and one night label, numbered by cycle step without repeats (labels move with the scene entity id, not with the scene name). Pattern: day starts with the brightest scene, night with the dimmest. Label ids for steps 1 to 4 often already exist ("name already in use" on create is fine).
- A freshly restarted HA shows entities as `unknown` until they report.
- After a long run of `permit_join`, close it again (`z2m.py permit-join 0`).
- `ha.sh` and the other scripts must only point at the environment you are working in - never at a staging or cloud system, and never at another person's environment.
- Write notes and deliverables as files under `notes-local/` of the relevant repo (gitignored) and open them with `idea -e <path>`.
- Do not leave scratch files in repos; use the session scratchpad.

## 9. Per-deployment state (read live, not from here)

The current device inventory, room-by-room wiring, and any open/half-finished items are environment-specific and change constantly, so they are intentionally NOT kept in this shared skill. Before acting:
- read the live `homelab-environments/<domain>/smarthome4-config/smarthome-config.yaml`,
- read the live Z2M devices/groups (`z2m.py devices`, `ui_api.py groups`) and HA entities (`ha.sh find`),
- if the user keeps a per-deployment notes file, read that too.
Then write any plan back to the user before changing the real house.
