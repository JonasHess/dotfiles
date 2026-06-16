# ------------------------------------------------------------------------------
# SDKMAN (Java / JVM SDK manager) Configuration
# ------------------------------------------------------------------------------
# NOTE: SDKMAN's installer normally appends this to the very end of ~/.zshrc.
# Loading it here (via oh-my-zsh custom files) works because nothing later in
# the shell startup touches Java or the PATH entries SDKMAN manages.

export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# JAVA_HOME is managed by SDKMAN: sdkman-init.sh sets it to the current
# default candidate, and (with sdkman_auto_env=true) the chpwd hook updates it
# to the version pinned in a project's .sdkmanrc when you cd into it. Don't
# hardcode it here — that would override the per-project switching.
