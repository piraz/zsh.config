# Variables
export EDITOR=nvim
export GOPATH=$HOME/go
export NVIM_PATH="/opt/nvim/current"
export NVIMM_PATH="/opt/nvim"
export NVIMM_MIN_RELEASE="0.9.0"
export PATH=~/.local/scripts:$GOPATH/bin:$NVIM_PATH/bin:$PATH:~/.local/bin
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
alias gbc="git_branch_change"
alias gwc="git_worktree_change"
alias gtc="git_change"
alias gcw="git_checkout_worktree"

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

function _git_bare_root() {
    local common_dir

    common_dir=$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null) || {
        echo "Not inside a git repository"
        return 1
    }

    if [[ "$common_dir" != */.bare ]]; then
        echo "Current repository is not using the bare worktree layout"
        return 1
    fi

    dirname "$common_dir"
}

function _git_branch_list() {
    git for-each-ref --format='%(refname:short)' refs/heads refs/remotes/origin \
        | grep -v '^origin/HEAD$' \
        | sed 's|^origin/||' \
        | awk '!seen[$0]++'
}

function _git_worktree_add() {
    local branch="$1"
    local worktree_path="$2"

    if git show-ref --verify --quiet "refs/heads/$branch"; then
        git worktree add "$worktree_path" "$branch" \
            || git worktree add -f "$worktree_path" "$branch"
        return
    fi

    git worktree add -b "$branch" "$worktree_path" "origin/$branch" \
        || git worktree add -f -b "$branch" "$worktree_path" "origin/$branch"
}

function git_branch_change() {
    local branch

    branch=$(echo "-\n$(git branch | cat | grep -wv '*' | awk '{$1=$1};1')" |
        fzf) || return

    [[ -z "$branch" ]] && return
    git checkout "$branch"
}

function git_worktree_change() {
    local container_root selected branch worktree_path

    container_root=$(_git_bare_root) || return 1

    selected=$({
        printf "%s\t%s\n" "bare" "$container_root"
        _git_branch_list | while read -r branch; do
            worktree_path="$container_root/$branch"
            if [[ -d "$worktree_path" ]]; then
                printf "%s\t%s\n" "$branch" "change"
            else
                printf "%s\t%s\n" "$branch" "create"
            fi
        done
    } | column -t -s $'\t' | fzf --prompt='worktree> ' --with-nth=1,2) || return

    branch="${selected%%[[:space:]]*}"
    [[ -z "$branch" ]] && return

    if [[ "$branch" == "bare" ]]; then
        cd "$container_root" || return 1
        return
    fi

    worktree_path="$container_root/$branch"
    if [[ -d "$worktree_path" ]]; then
        cd "$worktree_path" || return 1
        return
    fi

    _git_worktree_add "$branch" "$worktree_path" || return 1
    cd "$worktree_path" || return 1
}

function git_change() {
    _git_bare_root >/dev/null 2>&1 && {
        git_worktree_change
        return
    }

    git_branch_change
}

function git_checkout_worktree() {
    local URI="$1"
    local NAME="${2:-$(basename "$URI" .git)}"

    git clone --bare "$URI" "$NAME/.bare"
    echo "gitdir: ./.bare" > "$NAME/.git"
    git -C "$NAME/.bare" config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'
    git -C "$NAME/.bare" fetch
}

# Keybindings
bindkey -s "^[s" "se\n"
bindkey -s "^[v" "ve\n"
bindkey -s "^[g" "gtc\n"
bindkey -s "^[r" "source ~/.zshrc\n"

# Completions
source <(kubectl completion zsh)

# Loads nvm and nvm bash completion
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
