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


if [ -d $HOME/.kube/config.d ] && [ $(ls $HOME/.kube/config.d | wc -l) -gt 0 ]; then
  export KUBECONFIG=$KUBECONFIG$(ls $HOME/.kube/config.d/* | awk -F '/' '{printf ":%s",$0} END {print ""}')
fi

export KUBECONFIG=~/.kube/config:$KUBECONFIG:~/.kube/config
