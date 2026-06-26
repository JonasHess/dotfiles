# Dotfiles Cheat Sheet

Most important commands, aliases, and shortcuts defined in this repo.
Shell config lives in `.zshrc` and `.oh-my-zsh/custom/*.zsh`; k9s in `.config/k9s/`.

---

## Shell aliases

### General
| Alias | Expands to | What it does |
|---|---|---|
| `c` | `clear` | Clear the terminal |
| `cb` | `pbcopy` | Copy stdin to clipboard |
| `e` / `vim` | `nvim` | Open Neovim |
| `aliases` | `less ~/.oh-my-zsh/custom/aliases.zsh` | View all aliases |
| `latest` | `ls -lt \| head -6` | 6 most recently modified entries |
| `path` | `echo $PATH` (one per line) | Print PATH readably |
| `publicip` | `curl ifconfig.me` | Public IP |
| `localip` | `ipconfig getifaddr en0` | Local IP (macOS) |
| `speedtest` | `speedtest-cli --simple` | Quick speed test |
| `copy` | `rsync -auhvz --progress` | Copy with progress |
| `inspect-cert` | `openssl x509 -text` | Inspect a cert file |
| `j` | `jobs` | List background jobs |

### Navigation
| Alias | Does |
|---|---|
| `..` `...` `....` | Up 1 / 2 / 3 directories |
| `back` | `cd -` (previous directory) |

### Networking / ports
| Alias | Does |
|---|---|
| `ports` | List open ports (`netstat`) |
| `portscan` | Scan all localhost ports (`nmap`) |
| `port-used-by` | Process using port 8080 (`lsof`) |
| `gateway` | Show default gateway |
| `flushdns` | Flush macOS DNS cache |
| `pingg` | Ping google.com |
| `pp` / `upp` | Set / unset corporate `HTTPS_PROXY` |

### System
| Alias | Does |
|---|---|
| `topcpu` / `topmem` | Top 10 processes by CPU / memory |
| `docker-start` | `colima start` (Docker engine) |
| `lens` | Open OpenLens |

---

## Kubernetes

### Quick aliases
| Alias | Does |
|---|---|
| `kx` | kubectx — fuzzy-pick context (`kx <name>` switch, `kx -` toggle) |
| `kns` | kubens — fuzzy-pick namespace |
| `k0s` | `k9s` (Kubernetes TUI) |
| `nmt` | Spin up a throwaway `network-multitool` pod |
| `pf` | Port-forward ArgoCD server to `:8081` |
| `get-argo-admin` | Print ArgoCD initial admin password |
| `get-admin` | Copy Kafka admin password to clipboard |

### Troubleshooting functions
| Command (alias) | Does |
|---|---|
| `k8s-debug` (`k8s_troubleshoot`) | Spawn a Kubernetes troubleshooting pod |
| `pg-debug` (`pg_troubleshoot`) | Spawn a PostgreSQL troubleshooting pod |
| `rclone-debug` (`rclone_troubleshoot`) | Spawn an rclone troubleshooting pod with web UI |
| `rclone-cleanup` (`rclone_cleanup`) | Tear down the rclone troubleshooting resources |
| `kubeconfig-reload` | Merge all kubeconfig files into a single `KUBECONFIG` |

---

## k9s (TUI shortcuts)

Custom plugins in `.config/k9s/plugins.yaml` (press the key on the relevant resource):

| Key | Action |
|---|---|
| `Ctrl-Y` | Copy resource YAML |
| `Ctrl-X` | Connect to cluster |
| `Ctrl-T` | Test cluster |
| `Shift-E` | Watch events |
| `Shift-A` | Sync ArgoCD Application |
| `Ctrl-J` | Download kubeconfig |
| `Shift-D` | Image pull speed (on a pod) |
| `i` / `Shift-S` | CNPG status / verbose status |
| `l` / `Shift-L` | CNPG logs (pretty / raw) |
| `p` | CNPG psql shell |
| `Ctrl-O` / `Ctrl-K` | CNPG promote replica / destroy instance |
| `b` / `r` / `Shift-R` | CNPG backup / reload / restart |
| `h` / `Shift-H` / `Shift-W` | CNPG hibernate: status / on / off |

Resource aliases (`.config/k9s/aliases.yaml`): `dp`=deployments, `sec`=secrets,
`jo`=jobs, `cr`=clusterroles, `crb`=clusterrolebindings, `ro`=roles,
`rb`=rolebindings, `np`=networkpolicies.

---

## Git aliases (`.gitconfig`)

| Alias | Expands to |
|---|---|
| `git c` / `ca` / `cm` / `cam` | `commit` / `-a` / `-m` / `-am` |
| `git d` / `dc` | `diff` / `diff --cached` |
| `git l` | Pretty one-line graph log |

---

## Version managers (auto-loaded)

- **nvm** — `NVM_DIR` auto-discovers `~/.config/nvm` (or `~/.nvm`). **Auto-uses
  the `.nvmrc` version on `cd`**, installing it if missing.
  - `nvm-update` — update nvm to the latest tagged release
  - `nvm-list-remote` — list the latest LTS releases
- **SDKMAN** — `sdk <cmd>`; loaded last in `.zshrc` from `$SDKMAN_DIR` (`~/.sdkman`).

---

## Enabled oh-my-zsh plugins

`copypath terraform globalias iterm2 git kubectl kubectx kube-ps1 alias-finder
helm zsh-autosuggestions zsh-syntax-highlighting`

These add their own aliases — notably **git** (`gst`, `gco`, `gcm`, `gp`, `gl`, …),
**kubectl** (`k`, `kgp`, `kaf`, …), and **kubectx**. Run `alias-finder <cmd>` to
discover a matching alias, or `alias` to list everything active.
