# ------------------------------------------------------------------------------
# NodeJs and NVM Configuration
# ------------------------------------------------------------------------------
# This script sets up Node Version Manager (NVM) for managing multiple Node.js versions.
# 
# Steps:
# 1. Source the main NVM script from the default NVM installation directory.
# 2. Create the NVM directory in the user's home directory if it doesn't already exist.
# 3. Set the NVM_DIR environment variable to point to the NVM directory.
# 4. If the NVM script installed via Homebrew exists, source it to load NVM.
# 5. If the NVM bash completion script installed via Homebrew exists, source it to enable bash completion for NVM commands.

source ~/.nvm/nvm.sh

# NVM   Node Version Manager
mkdir -p $HOME/.nvm
export NVM_DIR="$HOME/.nvm"
    [ -s "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" ] && \. "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" # This loads nvm
    [ -s "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm" ] && \. "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm" # This loads nvm bash_completion
