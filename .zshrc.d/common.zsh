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

# Functions
function ve() {
    VENV=$(eval "find ~/venvs -mindepth 1 -maxdepth 1 -type d"\
        | fzf)
    if [[ -z $VENV ]]; then
        echo "No venv found"
    else
        source $VENV/bin/activate
    fi
}

function gbc() {
    BRANCH=$(echo "-\n$(git branch | cat | grep -wv '*' | awk '{$1=$1};1')" |
        fzf)
    if [[ -z $BRANCH ]]; then
        return
    else
        git checkout "$BRANCH"
    fi
}

# Keybindings
bindkey -s "^[s" "se\n"
bindkey -s "^[v" "ve\n"
bindkey -s "^[g" "gbc\n"

# Completions
source <(kubectl completion zsh)

# Loads nvm and nvm bash completion
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
