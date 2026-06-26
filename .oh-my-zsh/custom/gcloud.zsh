# ------------------------------------------------------------------------------
# Google Cloud SDK
# ------------------------------------------------------------------------------
# Adds the gcloud SDK to PATH (including gke-gcloud-auth-plugin, which kubectl
# invokes as an exec credential plugin for GKE clusters). Guarded so this stays
# portable across machines where the SDK isn't installed.

# Common install locations: Homebrew cask (macOS), and the tarball installer
# default (~/google-cloud-sdk) used on Linux/WSL.
for gcloud_root in \
  /opt/homebrew/share/google-cloud-sdk \
  /usr/local/share/google-cloud-sdk \
  "$HOME/google-cloud-sdk"; do
  if [ -f "$gcloud_root/path.zsh.inc" ]; then
    source "$gcloud_root/path.zsh.inc"
    [ -f "$gcloud_root/completion.zsh.inc" ] && source "$gcloud_root/completion.zsh.inc"
    break
  fi
done
