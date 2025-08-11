# ------------------------------------------------------------------------------
# Kubernetes Configuration
# ------------------------------------------------------------------------------

# This script merges multiple Kubernetes configuration files into a single KUBECONFIG environment variable.
# 
# Steps:
# 1. Checks if the directory $HOME/.kube/config.d exists and contains any files.
# 2. If the directory contains files, it appends each file path in the directory to the KUBECONFIG variable, separated by colons.
# 3. Finally, it sets the KUBECONFIG variable to include the default ~/.kube/config file at the beginning and end of the variable.
#
# This allows kubectl and other Kubernetes tools to use multiple configuration files seamlessly.

#
#if [ -d $HOME/.kube/config.d ] && [ $(ls $HOME/.kube/config.d | wc -l) -gt 0 ]; then
#  export KUBECONFIG=$KUBECONFIG$(ls $HOME/.kube/config.d/* | awk -F '/' '{printf ":%s",$0} END {print ""}')
#fi
#
#export KUBECONFIG=~/.kube/config:$KUBECONFIG:~/.kube/config


kubeconfig-reload() {
    # Create backup directory if it doesn't exist
    mkdir -p ~/.kube/backups
    
    # Create timestamped backup of current config
    if [ -f ~/.kube/config ]; then
        local backup_name="config-$(date '+%Y%m%d-%H%M%S')"
        cp ~/.kube/config ~/.kube/backups/"$backup_name"
        echo "Backed up current config to ~/.kube/backups/$backup_name"
    fi
    
    # Start with completely fresh config structure
    cat > ~/.kube/config << 'EOF'
apiVersion: v1
kind: Config
clusters: []
contexts: []
users: []
current-context: ""
EOF
    
    # Find and process config files
    echo "Searching for config files..."
    local config_files=($(find ~/.kube/config.d/ -name '*.yaml' -o -name '*.yml' 2>/dev/null))
    
    if [ ${#config_files[@]} -eq 0 ]; then
        echo "No YAML files found in ~/.kube/config.d/"
        return 1
    fi
    
    echo "Found ${#config_files[@]} config files"
    
    for config_file in "${config_files[@]}"; do
        # Extract directory name for context prefix
        dir_name=$(basename $(dirname "$config_file"))
        echo "Adding $config_file with prefix $dir_name"
        kubecm add -f "$config_file" --context-prefix "$dir_name" --silence-table --cover
        echo "  ✓ Success"
    done
    
    # Fix file permissions for security
    chmod 600 ~/.kube/config
    
    echo "kubeconfig-reload completed"
}
