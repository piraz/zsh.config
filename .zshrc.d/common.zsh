# Variables
export EDITOR=nvim
export GOPATH=$HOME/go
export NVIM_PATH="/opt/nvim/current"
export NVIMIM_PATH="/opt/nvim"
export NVIMIM_MIN_RELEASE="0.9.0"
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
alias gwd="git_worktree_delete"
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

function _git_set_upstream_if_remote_exists() {
    local branch="$1"
    local container_root="$2"

    git -C "$container_root" show-ref --verify --quiet "refs/remotes/origin/$branch" || return 0
    git -C "$container_root" rev-parse --abbrev-ref "$branch@{upstream}" >/dev/null 2>&1 && return 0

    git -C "$container_root" branch --set-upstream-to="origin/$branch" "$branch"
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
            || git -C "$container_root" worktree add -f "$worktree_path" "$branch" \
            || return 1
        _git_set_upstream_if_remote_exists "$branch" "$container_root"
        return
    fi

    if git -C "$container_root" show-ref --verify --quiet "refs/remotes/origin/$branch"; then
        git -C "$container_root" worktree add -b "$branch" "$worktree_path" "origin/$branch" \
            || git -C "$container_root" worktree add -f -b "$branch" "$worktree_path" "origin/$branch" \
            || return 1
        _git_set_upstream_if_remote_exists "$branch" "$container_root"
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
            || git -C "$container_root" worktree add -f -b "$branch" "$worktree_path" "$base_ref" \
            || return 1
        _git_set_upstream_if_remote_exists "$branch" "$container_root"
        return
    fi

    git -C "$container_root" worktree add -b "$branch" "$worktree_path" \
        || git -C "$container_root" worktree add -f -b "$branch" "$worktree_path" \
        || return 1
    _git_set_upstream_if_remote_exists "$branch" "$container_root"
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

function git_worktree_delete() {
    local branch="$1"
    local container_root current_branch current_top selected worktree_path confirm
    local branch_delete="-d"
    local remove_force=()

    if [[ "$branch" == "-f" || "$branch" == "--force" ]]; then
        branch="$2"
        branch_delete="-D"
        remove_force=(--force)
    fi

    container_root=$(_git_bare_root) || return 1

    if [[ -z "$branch" ]]; then
        current_branch=$(git symbolic-ref --quiet --short HEAD 2>/dev/null)
        current_top=$(git rev-parse --show-toplevel 2>/dev/null)

        if [[ -n "$current_branch" && "$current_top" != "$container_root" ]]; then
            branch="$current_branch"
            worktree_path="$current_top"
        else
            selected=$(git -C "$container_root" worktree list --porcelain | awk -v root="$container_root" '
                /^worktree / { path = substr($0, 10); branch = "" }
                /^branch refs\/heads\// { branch = substr($0, 19) }
                /^$/ { if (branch != "" && path != root) printf "%s\t%s\n", branch, path }
            ' | fzf --prompt='delete worktree> ' --delimiter=$'\t' --with-nth=1,2) || return

            branch="${selected%%$'\t'*}"
            worktree_path="${selected#*$'\t'}"
        fi
    fi

    [[ -z "$worktree_path" ]] && worktree_path="$container_root/$branch"

    if [[ ! -d "$worktree_path" ]]; then
        echo "Worktree not found: $worktree_path"
        return 1
    fi

    echo "delete worktree: $worktree_path"
    echo "delete branch:   $branch"
    read "confirm?delete? [y/N] "
    [[ "$confirm" == "y" || "$confirm" == "Y" ]] || return

    cd "$container_root" || return 1
    git -C "$container_root" worktree remove "${remove_force[@]}" "$worktree_path" || return 1
    git -C "$container_root" worktree prune

    if git -C "$container_root" show-ref --verify --quiet "refs/heads/$branch"; then
        git -C "$container_root" branch "$branch_delete" "$branch"
    fi
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

# ZLE widgets
function zsh_fzf_widget() {
    local action

    case "$WIDGET" in
        fzf_session)         action=tsesh ;;
        fzf_git_change)      action=git_change ;;
        fzf_venv)            action=ve ;;
        fzf_worktree_create) action=git_worktree_create ;;
        fzf_worktree_delete) action=git_worktree_delete ;;
        *) return 1 ;;
    esac

    zle -I
    "$action"
    zle reset-prompt
}

zle -N fzf_session zsh_fzf_widget
zle -N fzf_git_change zsh_fzf_widget
zle -N fzf_venv zsh_fzf_widget
zle -N fzf_worktree_create zsh_fzf_widget
zle -N fzf_worktree_delete zsh_fzf_widget

bindkey '^[s' fzf_session
bindkey '^[v' fzf_venv
bindkey '^[g' fzf_git_change
bindkey '^[w' fzf_worktree_create
bindkey '^[W' fzf_worktree_delete
bindkey -s "^[r" "source ~/.zshrc\n"

# Completions
source <(kubectl completion zsh)

# Loads nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"

# Use default Node version automatically
if command -v nvm >/dev/null 2>&1; then
    nvm use default >/dev/null
fi

# Loads cargo if exists
if [[ -f "$HOME/.cargo/env" ]]; then
    source "$HOME/.cargo/env"
fi
