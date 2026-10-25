// Sanity checks for smarthome-config.yaml before it is committed. Read-only.
//   node validate_config.js [path/to/smarthome-config.yaml]
// Checks: every motion device is in exactly one entry, profile and trigger names fit the entry's
// sensor type, every referenced resource and condition exists, no duplicate resource ids.
// It cannot check that the Home Assistant entities and labels behind the resources exist: a missing
// entity or a label without scenes makes the whole smarthome4 refresh fail, so verify those first.
const { createRequire } = require('module');
const fs = require('fs');
const os = require('os');
const jsYaml = createRequire(os.homedir() + '/repos/smarthome4-ui/frontend/')('js-yaml');
const file = process.argv[2] || os.homedir() + '/repos/homelab-environments/hess.pm/smarthome4-config/smarthome-config.yaml';
const c = jsYaml.load(fs.readFileSync(file, 'utf8')).smartHome;
const ids = new Set(c.homeAssistantResources.map(r => r.id));
const conds = new Set(c.conditions.map(x => x.id));
const pref = {
  AqaraFP300: ['AqaraFP300LightDefault', 'AQARA_FP300_'], AqaraFP1E: ['AqaraFP1ELightDefault', 'AQARA_FP1E_'],
  HueSML001: ['HueSML001LightDefault', 'HUE_SML001_'], HueSML004: ['HueSML004LightDefault', 'HUE_SML004_'],
};
const seen = {}, problems = [];
for (const s of c.sensors) {
  const p = pref[s.type];
  for (const g of s.groups || []) {
    const res = [...(g.homeAssistantResources || [])];
    if (p && g.profile !== p[0]) problems.push(`${s.name}: profile ${g.profile} does not fit ${s.type}`);
    for (const t of g.triggers || []) {
      if (p && !t.trigger.startsWith(p[1])) problems.push(`${s.name}: trigger ${t.trigger} does not fit ${s.type}`);
      for (const q of t.sequences || []) {
        res.push(...q.homeAssistantResources);
        if (q.condition && !conds.has(q.condition)) problems.push(`${s.name}: unknown condition ${q.condition}`);
      }
    }
    for (const r of res) if (!ids.has(r)) problems.push(`${s.name}: unknown resource ${r}`);
  }
  if (p) for (const d of s.devices) { if (seen[d]) problems.push(`device ${d} in two entries: ${seen[d]} and ${s.name}`); seen[d] = s.name; }
}
const dups = c.homeAssistantResources.length - ids.size;
if (dups) problems.push(`${dups} duplicate resource id(s)`);
console.log(problems.length ? 'PROBLEMS:\n' + problems.join('\n') : 'ok: no problems found', `(${c.sensors.length} sensors, ${ids.size} resources)`);
process.exit(problems.length ? 1 : 0);
