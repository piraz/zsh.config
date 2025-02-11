eval "$(/opt/homebrew/bin/brew shellenv)"

export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
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

NODE_VERSION="23.3.0"
NODE_PATH="$(brew --prefix)/Cellar/node/$NODE_VERSION"

export PATH=/usr/local/go/bin:$NODE_PATH/bin:$HOME/bin:$PATH:/usr/local/bin

export KUBE_EDITOR=nvim

# Aliases
alias updatedb="/usr/libexec/locate.updatedb"
