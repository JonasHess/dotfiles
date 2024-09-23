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
alias kk="kubectl -n kafka"
alias vim='nvim'
alias nmt='kubectl run tmp-nw-tool --rm -i --tty --image registry-emea.app.corpintra.net/dockerhub/praqma/network-multitool -- sh'
alias cb='pbcopy'
alias c='clear'
alias pp='export HTTPS_PROXY=s415078c.detss.corpintra.net:3128'
alias upp='unset HTTPS_PROXY'
alias get-admin='kubectl -n kafka get secrets admin -o jsonpath="{.data.user\.password}" | base64 -d | pbcopy'
alias e='nvim'
#alias e='idea -e --wait'

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
