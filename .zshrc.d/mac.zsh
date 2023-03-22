eval "$(/opt/homebrew/bin/brew shellenv)"

. /opt/homebrew/opt/asdf/libexec/asdf.sh

alias ls="ls --color"
alias gad="git add"
alias gbr="git branch"
alias gch="git checkout"
alias gdi="git diff"
alias gdc="git diff --cached"
alias gst="git status"
alias gpl="git pull"
alias gps="git push"

# From https://cloud.google.com/blog/products/containers-kubernetes/kubectl-auth-changes-in-gke
export USE_GKE_GCLOUD_AUTH_PLUGIN=True

export PATH=/usr/local/go/bin:$PATH:/usr/local/bin
export GOPATH=$HOME/go

export KUBE_EDITOR=nvim
