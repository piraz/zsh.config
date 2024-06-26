eval "$(/opt/homebrew/bin/brew shellenv)"

. "$(brew --prefix asdf)/libexec/asdf.sh"
# append completions to fpath
fpath=(${ASDF_DIR}/completions $fpath)
# initialise completions with ZSH's compinit
autoload -Uz compinit && compinit

# For more information on how to get started, please visit:
#   https://cloud.google.com/sdk/docs/quickstarts
#
#
# To install or remove components at your current SDK version [435.0.1], run:
#   $ gcloud components install COMPONENT_ID
#   $ gcloud components remove COMPONENT_ID
#
# To update your SDK installation to the latest version [435.0.1], run:
#   $ gcloud components update
source "$(brew --prefix)/share/google-cloud-sdk/path.zsh.inc"
source "$(brew --prefix)/share/google-cloud-sdk/completion.zsh.inc"

# From https://cloud.google.com/blog/products/containers-kubernetes/kubectl-auth-changes-in-gke
export USE_GKE_GCLOUD_AUTH_PLUGIN=True

export PATH=/usr/local/go/bin:$HOME/bin:$PATH:/usr/local/bin

export KUBE_EDITOR=nvim

# Aliases
alias updatedb="/usr/libexec/locate.updatedb"
