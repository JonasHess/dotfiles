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
