# ------------------------------------------------------------------------------
# SDKMAN (Java / JVM SDK manager) Configuration
# ------------------------------------------------------------------------------
# NOTE: SDKMAN's installer normally appends this to the very end of ~/.zshrc.
# Loading it here (via oh-my-zsh custom files) works because nothing later in
# the shell startup touches Java or the PATH entries SDKMAN manages.

export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

export JAVA_HOME="$HOME/.sdkman/candidates/java/current"
