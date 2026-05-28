alias pbcopy="xsel --clipboard --input"
alias pbpaste="xsel --clipboard --output"
# alias wezterm="flatpak run org.wezfurlong.wezterm"

. "$HOME/.asdf/asdf.sh"
# append completions to fpath
fpath=(${ASDF_DIR}/completions $fpath)
# initialise completions with ZSH's compinit
autoload -Uz compinit && compinit
export PATH=$GOPATH/bin:$NVIM_PATH/bin:$HOME/bin:$PATH:/usr/local/bin
export DOCKER_HOST=unix:///run/user/1000/docker.sock
. "$HOME/.cargo/env"

# Local machine-specific overrides
if [[ -f "$HOME/.piraz/zsh/custom.linux.zsh" ]]; then
    source "$HOME/.piraz/zsh/custom.linux.zsh"
fi
