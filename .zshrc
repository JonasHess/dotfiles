# ZSH_TMUX_AUTOSTART=true
# export ZSH_TMUX_AUTOSTART=true
# ZSH_ZELLIJ_AUTOSTART=true

# Detect WSL once, so platform-specific tweaks below can branch on it.
if [[ -f /proc/sys/fs/binfmt_misc/WSLInterop ]] || grep -qi 'microsoft\|wsl' /proc/version 2>/dev/null; then
  IS_WSL=true
else
  IS_WSL=false
fi

# Load Homebrew if present. Covers Apple Silicon, Intel macOS, and Linuxbrew/WSL;
# silently skipped on machines without Homebrew so this stays portable.
for brew_path in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
  if [ -x "$brew_path" ]; then
    eval "$("$brew_path" shellenv)"
    break
  fi
done

# WSL ships completion dirs that fail compinit's security check; skip it there.
if [[ "$IS_WSL" == true ]]; then
  export ZSH_DISABLE_COMPFIX="true"
fi

# Auto-attach Herdr (herdr.dev) in interactive terminals. Runs before oh-my-zsh
# so Herdr opens instantly; after detaching (ctrl+b q) the rest of this file
# loads and you land in a normal shell.
#
# One shared Herdr session holds every project as a separate workspace ("space"),
# so all projects stay visible in the sidebar. Before attaching, focus this
# project's workspace (creating it on first use) so the terminal lands in the
# right space instead of wherever Herdr was last. The workspace is named after
# the git repo root (or the current dir), matching Herdr's own default labeling.
#
# Skipped when:
#   - already inside a Herdr pane ($HERDR_SOCKET_PATH is set in panes)
#   - opted out via HERDR_AUTOSTART=false (e.g. `HERDR_AUTOSTART=false zsh`)
if [[ -o interactive ]] \
   && [[ -z "$HERDR_SOCKET_PATH" ]] \
   && [[ "$HERDR_AUTOSTART" != "false" ]] \
   && command -v herdr >/dev/null 2>&1; then
  () {
    local root name list wid
    root="$(git rev-parse --show-toplevel 2>/dev/null)" || root="$PWD"
    name="${root:t}"                    # basename via zsh :t modifier
    name="${name//[^A-Za-z0-9._-]/-}"   # sanitize for use as a workspace label
    [[ -z "$name" ]] && name="home"     # e.g. cwd is "/"

    # If the server is already up, focus this project's workspace (or create it).
    # `herdr workspace list` fails on a cold start; then the plain attach below
    # starts the server, whose first workspace Herdr already labels by directory.
    # Parsing needs python3; without it, fall back to a plain attach rather than
    # risk creating a duplicate workspace from a failed lookup.
    if command -v python3 >/dev/null 2>&1 && list="$(herdr workspace list 2>/dev/null)"; then
      wid="$(HERDR_WS_NAME="$name" python3 - "$list" <<'PY' 2>/dev/null
import json, os, sys
name = os.environ["HERDR_WS_NAME"]
try:
    workspaces = json.loads(sys.argv[1])["result"]["workspaces"]
except Exception:
    sys.exit(0)
for w in workspaces:
    if w.get("label") == name:
        print(w.get("workspace_id", ""))
        break
PY
)"
      if [[ -n "$wid" ]]; then
        herdr workspace focus "$wid" >/dev/null 2>&1
      else
        herdr workspace create --cwd "$root" --label "$name" --focus >/dev/null 2>&1
      fi
    fi

    herdr
  }
fi

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

export ZPWR_EXPAND_BLACKLIST=(grep ls tmux)
# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.

# zsh-abbr
# zellij terraform tmux globalias iterm2 cp git battery kubectl kubectx kube-ps1 git cp zbell jsontools mvn alias-finder aws dirhistory docker helm zsh-autosuggestions zsh-syntax-highlighting)
# zsh-vi-mode
plugins=(copypath terraform globalias iterm2 git kubectl kubectx kube-ps1 alias-finder helm zsh-autosuggestions zsh-syntax-highlighting)
# zstyle :omz:plugins:iterm2 shell-integration yes
source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  # export EDITOR='idea -e --wait'
  export EDITOR='nvim'
fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Kubernetes: quick context/namespace switching (kubectx + kubens, fzf picker).
alias kx='kubectx'   # `kx` = fuzzy-pick context | `kx <name>` = switch | `kx -` = toggle previous
alias kns='kubens'   # `kns` = fuzzy-pick namespace

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Per-machine shell overrides (PATHs, secrets, host-specific tweaks). Git-ignored.
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# SDKMAN (SDK version manager for Java/Kotlin/Gradle/etc). Portable via
# $SDKMAN_DIR and guarded, so it is a no-op when SDKMAN isn't installed.
# THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="${SDKMAN_DIR:-$HOME/.sdkman}"
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
