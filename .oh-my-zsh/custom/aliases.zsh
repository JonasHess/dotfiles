# ------------------------------------------------------------------------------
#  Aliases
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
#  General
# ------------------------------------------------------------------------------
alias c='clear' # clear terminal
alias cb='pbcopy' # copy to clipboard
alias e='nvim' # alias e to nvim
#alias e='idea -e --wait'
alias editbrew='nvim ~/repos/mac-os-setup/config.yml' # Edit brew config
alias aliases='cat ~/.oh-my-zsh/custom/aliases.zsh | less' # Edit current zsh file
alias iown='sudo chown -R $(id -u):$(id -g) $HOME/file.txt' # Take ownership of a file or directory (Recursive)
alias latest='ls -lt | head -6' # List the 6 most recently modified files/directories
alias path='echo -e ${PATH//:/\\n}' # Print PATH environment variable with each entry on a new line
alias path+='export PATH=$PATH:' # Append to the PATH variable
alias publicip='curl ifconfig.me' # Get public IP address
alias localip="ipconfig getifaddr en0" # Get local IP address on en0 interface (macOS)
alias speedtest='speedtest-cli --simple' # Run speedtest
alias distro='cat /etc/*-release' # Display OS distribution info
alias compress='tar -czvf example.tar.gz /path/to/directory' # Compress directory to tar.gz
alias decompress='tar -xzvf example.tar.gz' # Decompress tar.gz
alias inspect-cert='openssl x509 -in my_file.crt -text -noout' # Inspect a certificate file
alias copy='rsync -auhvz --progress' # Copy files with rsync
# -a archive mode; equals -rlptgoD (no -H,-A,-X)
# -u update: copy only when the SOURCE file is newer than the destination file or when the destination file is missing
# -v verbose
# -h human readable
# -z compress
# --progress show progress during transfer

# ------------------------------------------------------------------------------
#  Navigation
# ------------------------------------------------------------------------------
alias ..='cd ..' # Go up one directory
alias ...='cd ../..' # Go up two directories
alias ....='cd ../../..' # Go up three directories
alias back='cd -'  # Go to the previous directory

# ------------------------------------------------------------------------------
#  Kubernetes
# ------------------------------------------------------------------------------
alias nmt='kubectl run tmp-nw-tool --rm -i --tty --image registry-emea.app.corpintra.net/dockerhub/praqma/network-multitool -- sh' # Run a temporary network multitool pod in Kubernetes
alias k0s='k9s' # alias k0s to k9s - Kubernetes TUI
alias get-admin='kubectl -n kafka get secrets admin -o jsonpath="{.data.user\.password}" | base64 -d | pbcopy' # Get Kafka admin password and copy to clipboard
alias pf='kubectl port-forward svc/argocd-server -n argocd 8081:443' # Port-forward ArgoCD server
alias get-argo-admin='kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo' # Get ArgoCD admin password

# ------------------------------------------------------------------------------
#  Networking
# ------------------------------------------------------------------------------
alias ports='netstat -tulanp' # List open ports
alias portscan='nmap -p 1-65535 localhost' # Scan all ports on localhost
alias portopen='nc 127.0.0.1 8080 -v' # Test if port 8080 is open locally
alias port-used-by='lsof -i :8080' # Find process using port 8080
alias traceg='sudo mtr --show-ips --tcp --port 443 google.de -r' # Trace route to google.de using TCP and port 443
alias set-gateway='sudo ip route add default via 192.168.1.1 dev eth0' # Set default gateway
alias set-ip='sudo ip addr add 192.168.1.100/24 dev eth0' # Set IP address on eth0
alias gateway='ip route show default' # show the default gateway
alias flushdns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'  # macOS DNS flush
alias pingg='ping google.com' # Ping Google

# ------------------------------------------------------------------------------
#  System Monitoring
# ------------------------------------------------------------------------------
alias topcpu='ps -eo pcpu,pid,user,args | sort -k 1 -r | head -10'  # Top 10 CPU consuming processes
alias topmem='ps -eo pmem,pid,user,args | sort -k 1 -r | head -10'  # Top 10 memory consuming processes

# ------------------------------------------------------------------------------
#  Proxy
# ------------------------------------------------------------------------------
alias pp='export HTTPS_PROXY=s415078c.detss.corpintra.net:3128' # Set HTTPS proxy
alias upp='unset HTTPS_PROXY' # Unset HTTPS proxy

# ------------------------------------------------------------------------------
#  Miscellaneous
# ------------------------------------------------------------------------------
alias terraform='tofu' # alias terraform to tofu
alias lens="open -a OpenLens" # Open OpenLens application
alias vim='nvim' # alias vim to neovim
alias j="jobs" # list background jobs
alias test-file='truncate -s 10M test-file' # Create a test file of 10MB

# ------------------------------------------------------------------------------
#  GitHub Copilot
# ------------------------------------------------------------------------------
gh extension list | grep -q "gh[- ]copilot" || _echo_exit " Install the GitHub Copilot extension for github cli: > gh extension install github/gh-copilot"

# ------------------------------------------------------------------------------
#  Alias not to be expanded
# ------------------------------------------------------------------------------
GLOBALIAS_FILTER_VALUES=(ls grep)
# netstat -netstat -anp | grep etcd
