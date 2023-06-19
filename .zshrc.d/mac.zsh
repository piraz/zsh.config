eval "$(/opt/homebrew/bin/brew shellenv)"

. /opt/homebrew/opt/asdf/libexec/asdf.sh

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

export PATH=/usr/local/go/bin:$PATH:/usr/local/bin

export KUBE_EDITOR=nvim

# Aliases
alias updatedb="/usr/libexec/locate.updatedb"
