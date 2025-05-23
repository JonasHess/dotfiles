# ------------------------------------------------------------------------------
# NodeJs and NVM Configuration
# -----------------------------------------------------

# Set up NVM directory
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
mkdir -p "$NVM_DIR"


# Performance optimization: Use lazy loading by default
# Set NVM_LAZY_LOAD=false in your environment to disable lazy loading
NVM_LAZY_LOAD="${NVM_LAZY_LOAD:-true}"

if [[ "$NVM_LAZY_LOAD" == "false" ]]; then
    # Immediate loading mode
    # Load NVM - try multiple common locations
    if [ -s "$NVM_DIR/nvm.sh" ]; then
        source "$NVM_DIR/nvm.sh"
    elif [ -s "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" ]; then
        source "$HOMEBREW_PREFIX/opt/nvm/nvm.sh"
    elif [ -s "/usr/local/opt/nvm/nvm.sh" ]; then
        source "/usr/local/opt/nvm/nvm.sh"
    fi

    # Load NVM bash completion
    if [ -s "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm" ]; then
        source "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm"
    elif [ -s "$NVM_DIR/bash_completion" ]; then
        source "$NVM_DIR/bash_completion"
    fi
else
    # Lazy loading mode (default)
    # Create placeholder functions that load NVM on first use
    __nvm_lazy_load() {
        # Remove placeholder functions
        unset -f nvm node npm npx yarn pnpm bun deno __nvm_lazy_load
        
        # Load NVM - try multiple common locations
        if [ -s "$NVM_DIR/nvm.sh" ]; then
            source "$NVM_DIR/nvm.sh"
        elif [ -s "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" ]; then
            source "$HOMEBREW_PREFIX/opt/nvm/nvm.sh"
        elif [ -s "/usr/local/opt/nvm/nvm.sh" ]; then
            source "/usr/local/opt/nvm/nvm.sh"
        fi

        # Load NVM bash completion
        if [ -s "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm" ]; then
            source "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm"
        elif [ -s "$NVM_DIR/bash_completion" ]; then
            source "$NVM_DIR/bash_completion"
        fi
        
        # Run the auto-use function after loading
        __nvm_auto_use
    }

    # Create placeholder functions for common commands
    for cmd in nvm node npm npx yarn pnpm bun deno; do
        eval "${cmd}() { 
            __nvm_lazy_load
            ${cmd} \"\$@\"
        }"
    done
fi

# Auto-use Node version from .nvmrc if it exists
__nvm_auto_use() {
    local nvmrc_path
    nvmrc_path="$(nvm_find_nvmrc)"
    
    if [ -n "$nvmrc_path" ]; then
        local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")
        
        if [ "$nvmrc_node_version" = "N/A" ]; then
            nvm install
        elif [ "$nvmrc_node_version" != "$(nvm version)" ]; then
            nvm use
        fi
    elif [ -n "$(nvm version default 2>/dev/null)" ] && [ "$(nvm version 2>/dev/null)" != "$(nvm version default 2>/dev/null)" ]; then
        nvm use default >/dev/null 2>&1
    fi
}

# Set up directory change hook
autoload -U add-zsh-hook

# Hook function that checks if NVM is loaded before calling auto-use
__nvm_chpwd_hook() {
    if command -v nvm_find_nvmrc >/dev/null 2>&1; then
        __nvm_auto_use
    fi
}

# Add hook to run on directory change
add-zsh-hook chpwd __nvm_chpwd_hook

# If not lazy loading, run auto-use on startup
if [[ "$NVM_LAZY_LOAD" == "false" ]]; then
    __nvm_auto_use
fi

# Useful NVM aliases
alias nvm-update='cd "$NVM_DIR" && git fetch --tags origin && git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" $(git rev-list --tags --max-count=1)` && cd -'
alias nvm-list-remote='nvm ls-remote --lts | grep -E "Latest LTS|v[0-9]+\.[0-9]+\.[0-9]+.*Latest" | tail -10'


