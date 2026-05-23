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
alias t="tmux"
alias se="tsesh"
alias gbc="git_branch_change"
alias gwc="git_worktree_change"
alias gwn="git_worktree_create"
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
    local base_branch="$3"
    local container_root="$4"
    local base_ref

    mkdir -p "$(dirname "$worktree_path")" || return 1

    if git -C "$container_root" show-ref --verify --quiet "refs/heads/$branch"; then
        git -C "$container_root" worktree add "$worktree_path" "$branch" \
            || git -C "$container_root" worktree add -f "$worktree_path" "$branch"
        return
    fi

    if git -C "$container_root" show-ref --verify --quiet "refs/remotes/origin/$branch"; then
        git -C "$container_root" worktree add -b "$branch" "$worktree_path" "origin/$branch" \
            || git -C "$container_root" worktree add -f -b "$branch" "$worktree_path" "origin/$branch"
        return
    fi

    if [[ -n "$base_branch" ]]; then
        if git -C "$container_root" show-ref --verify --quiet "refs/heads/$base_branch"; then
            base_ref="$base_branch"
        elif git -C "$container_root" show-ref --verify --quiet "refs/remotes/origin/$base_branch"; then
            base_ref="origin/$base_branch"
        else
            base_ref="$base_branch"
        fi

        git -C "$container_root" worktree add -b "$branch" "$worktree_path" "$base_ref" \
            || git -C "$container_root" worktree add -f -b "$branch" "$worktree_path" "$base_ref"
        return
    fi

    git -C "$container_root" worktree add -b "$branch" "$worktree_path" \
        || git -C "$container_root" worktree add -f -b "$branch" "$worktree_path"
}

function n() {
    local bare_root

    if _git_bare_root >/dev/null 2>&1; then
        bare_root=$(_git_bare_root)
        cd "$bare_root" || return 1
    fi

    nvim .
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

    git -C "$container_root" fetch --prune origin

    selected=$({
        printf "%s\t%s\n" "bare" "$container_root"
        {
            _git_branch_list | while read -r branch; do
                worktree_path="$container_root/$branch"
                if [[ -d "$worktree_path" ]]; then
                    printf "%s\t%s\n" "$branch" "change"
                else
                    printf "%s\t%s\n" "$branch" "create"
                fi
            done
        } | awk -F '\t' '
            $2 == "change" { change = change $0 ORS; next }
            { create = create $0 ORS }
            END { printf "%s%s", change, create }
        '
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

    _git_worktree_add "$branch" "$worktree_path" "" "$container_root" || return 1
    cd "$worktree_path" || return 1
}

function git_worktree_create() {
    local base_branch="$1"
    local container_root branch worktree_path

    container_root=$(_git_bare_root) || return 1

    git -C "$container_root" fetch --prune origin

    read "branch?worktree> "
    [[ -z "$branch" ]] && return

    worktree_path="$container_root/$branch"
    if [[ -d "$worktree_path" ]]; then
        cd "$worktree_path" || return 1
        return
    fi

    _git_worktree_add "$branch" "$worktree_path" "$base_branch" "$container_root" || return 1
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
bindkey -s "^[w" "gwn\n"
bindkey -s "^[r" "source ~/.zshrc\n"

# Completions
source <(kubectl completion zsh)

# Loads nvm and nvm bash completion
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
