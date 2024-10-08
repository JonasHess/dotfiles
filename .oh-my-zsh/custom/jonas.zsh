# Put files in this folder to add your own custom functionality.
# See: https://github.com/ohmyzsh/ohmyzsh/wiki/Customization
# 
# Files in the custom/ directory will be:
# - loaded automatically by the init script, in alphabetical order
# - loaded last, after all built-ins in the lib/ directory, to override them
# - ignored by git by default
# 
# Example: add custom/shortcuts.zsh for shortcuts to your local projects
# 


unsetopt BEEP
export PATH=/Applications/IntelliJ\ IDEA.app/Contents/MacOS/:$PATH
autoload -Uz compinit
compinit
alias terraform='tofu'
alias lens="open -a OpenLens"
alias vim='nvim'
alias nmt='kubectl run tmp-nw-tool --rm -i --tty --image registry-emea.app.corpintra.net/dockerhub/praqma/network-multitool -- sh'
alias cb='pbcopy'
alias c='clear'
alias k0s='k9s'
alias j="jobs"
alias pp='export HTTPS_PROXY=s415078c.detss.corpintra.net:3128'
alias upp='unset HTTPS_PROXY'
alias get-admin='kubectl -n kafka get secrets admin -o jsonpath="{.data.user\.password}" | base64 -d | pbcopy'
alias e='nvim'
#alias e='idea -e --wait'
alias pf='kubectl port-forward svc/argocd-server -n argocd 8081:443'
alias get-argo-admin='kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo'

alias copy='rsync -auhvz --progress'
# -a archive mode; equals -rlptgoD (no -H,-A,-X)
# -u update: copy only when the SOURCE file is newer than the destination file or when the destination file is missing
# -v verbose
# -h human readable
# -z compress
# --progress show progress during transfer

alias test-file='truncate -s 10M test-file'

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias back='cd -'  # Go to the previous directory

alias publicip='curl ifconfig.me'
alias localip="ipconfig getifaddr en0"
alias speedtest='speedtest-cli --simple'
alias ports='netstat -tulanp'
alias port-used-by='lsof -i :'
alias path='echo -e ${PATH//:/\\n}'
alias path+='export PATH=$PATH:'
alias flushdns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'  # macOS DNS flush
alias pingg='ping google.com'
alias topcpu='ps -eo pcpu,pid,user,args | sort -k 1 -r | head -10'  # Top 10 CPU consuming processes
alias topmem='ps -eo pmem,pid,user,args | sort -k 1 -r | head -10'  # Top 10 memory consuming processes

alias latest='ls -lt | head -6'
alias search='apt-cache search'
alias editzsh='nvim ~/.oh-my-zsh/custom/jonas.zsh'
alias editbrew='nvim ~/repos/mac-os-setup/config.yml'



# Alias not to be expanded
GLOBALIAS_FILTER_VALUES=(ls grep)



# Merge kubeconfigs
if [ -d $HOME/.kube/config.d ] && [ $(ls $HOME/.kube/config.d | wc -l) -gt 0 ]; then
  export KUBECONFIG=$KUBECONFIG$(ls $HOME/.kube/config.d/* | awk -F '/' '{printf ":%s",$0} END {print ""}')
fi



export PATH=$PATH:/Users/jonas/repos/kubectl-plugins
export PATH=$PATH:$HOME/.rd/bin


# Load Angular CLI autocompletion.
# source <(ng completion script)

source ~/.nvm/nvm.sh


# NVM   Node Version Manager
mkdir -p $HOME/.nvm
export NVM_DIR="$HOME/.nvm"
    [ -s "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" ] && \. "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" # This loads nvm
    [ -s "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm" ] && \. "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm" # This loads nvm bash_completion


# Enable vi mode
bindkey -v

## Bind SHIRT + CONTROL + "_" to Github Copilot suggest (only in command mode)
zvm_bindkey vicmd '^_' zsh_gh_copilot_suggest

