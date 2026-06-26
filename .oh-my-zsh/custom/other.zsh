# Disable terminal bell sound
unsetopt BEEP

# NOTE: completion init (compinit) is intentionally NOT done here.
# oh-my-zsh already runs compinit, and this file is only ever sourced *by*
# oh-my-zsh, so a compinit here is always a redundant second pass (~300ms +
# a duplicate compdump). In WSL the insecure-directory warning is handled by
# ZSH_DISABLE_COMPFIX, set in .zshrc before oh-my-zsh loads.