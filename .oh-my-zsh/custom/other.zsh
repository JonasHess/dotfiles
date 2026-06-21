# Disable terminal bell sound
unsetopt BEEP

# Load and initialize the completion system.
# Skip in WSL, where oh-my-zsh already runs compinit and a second call is both
# redundant and prone to the insecure-directory warning.
if [[ ! -f /proc/sys/fs/binfmt_misc/WSLInterop ]] && ! grep -qi 'microsoft\|wsl' /proc/version 2>/dev/null; then
  autoload -Uz compinit
  compinit
fi