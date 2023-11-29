# Variables
export EDITOR=nvim
export GOPATH=$HOME/go
export PATH=~/.local/scripts:$PATH
export PIRAZ_SOURCES="~/source/piraz"

if [ -f ~/.piraz_sources ]; then
    PIRAZ_SOURCES="$PIRAZ_SOURCES $(cat ~/.piraz_sources | paste -sd ' ' -)"
fi

# Aliases
alias k="kubectl"
alias g="git"
alias gad="git add"
alias gbr="git branch"
alias gch="git checkout"
alias gdi="git diff"
alias gdc="git diff --cached"
alias gst="git status"
alias gpl="git pull"
alias gps="git push"
alias ls="ls --color"
alias n="nvim ."
alias t="tmux"
alias se="tsesh"

# Completions
source <(kubectl completion zsh)
