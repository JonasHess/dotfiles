# ------------------------------------------------------------------------------
# NodeJs and NVM Configuration (lazy-loaded)
# ------------------------------------------------------------------------------
# Sourcing nvm.sh and running its .nvmrc auto-use on every shell costs ~1s, and
# dominates zsh startup. So we defer all of it: nvm is loaded the first time you
# run node/npm/npx/nvm, or the first time you cd into a directory that pins a
# Node version (.nvmrc / .node-version). Shells that never touch Node stay fast,
# while .nvmrc auto-switching still works inside Node projects.

# Resolve NVM_DIR (XDG-aware): explicit $NVM_DIR wins, else an existing
# ~/.config/nvm, else the classic ~/.nvm.
if [ -z "$NVM_DIR" ]; then
    if [ -d "${XDG_CONFIG_HOME:-$HOME/.config}/nvm" ]; then
        export NVM_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvm"
    else
        export NVM_DIR="$HOME/.nvm"
    fi
fi
mkdir -p "$NVM_DIR"

# Locate nvm.sh WITHOUT sourcing it (NVM_DIR, then Homebrew, then /usr/local).
__NVM_SH=""
for __nvm_candidate in \
    "$NVM_DIR/nvm.sh" \
    "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" \
    "/usr/local/opt/nvm/nvm.sh"; do
    if [ -s "$__nvm_candidate" ]; then
        __NVM_SH="$__nvm_candidate"
        break
    fi
done
unset __nvm_candidate

if [ -n "$__NVM_SH" ]; then
    autoload -U add-zsh-hook

    # Auto-use the Node version from the directory's .nvmrc. Only ever called
    # once nvm itself is loaded.
    __nvm_auto_use() {
        local nvmrc_path
        nvmrc_path="$(nvm_find_nvmrc)"
        if [ -n "$nvmrc_path" ]; then
            local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")
            if [ "$nvmrc_node_version" = "N/A" ]; then
                nvm install
            elif [ "$nvmrc_node_version" != "$(nvm version)" ]; then
                nvm use >/dev/null 2>&1
            fi
        fi
    }

    # The real loader: source nvm.sh + completion once, drop the shims, swap the
    # lightweight hook for the real per-directory one, and auto-use the CWD.
    __nvm_load() {
        unfunction nvm node npm npx 2>/dev/null
        source "$__NVM_SH"
        if [ -s "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm" ]; then
            source "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm"
        elif [ -s "$NVM_DIR/bash_completion" ]; then
            source "$NVM_DIR/bash_completion"
        fi
        add-zsh-hook -d chpwd __nvm_lazy_chpwd 2>/dev/null
        add-zsh-hook chpwd __nvm_auto_use
        __nvm_auto_use
    }

    # First use of any Node tool loads nvm for real, then re-dispatches the call.
    nvm()  { __nvm_load; nvm "$@"; }
    node() { __nvm_load; node "$@"; }
    npm()  { __nvm_load; npm "$@"; }
    npx()  { __nvm_load; npx "$@"; }

    # Lightweight hook: only pay the nvm load cost when entering a directory that
    # actually pins a Node version.
    __nvm_lazy_chpwd() {
        if [ -f .nvmrc ] || [ -f .node-version ]; then
            __nvm_load
        fi
    }
    add-zsh-hook chpwd __nvm_lazy_chpwd
    __nvm_lazy_chpwd   # honor a .nvmrc in the directory the shell starts in

    # Useful NVM aliases (work transparently via the lazy shims).
    alias nvm-update='cd "$NVM_DIR" && git fetch --tags origin && git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" $(git rev-list --tags --max-count=1)` && cd -'
    alias nvm-list-remote='nvm ls-remote --lts | grep -E "Latest LTS|v[0-9]+\.[0-9]+\.[0-9]+.*Latest" | tail -10'
fi
