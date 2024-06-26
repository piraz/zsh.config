alias wezterm="flatpak run org.wezfurlong.wezterm"

. "$HOME/.asdf/asdf.sh"
# append completions to fpath
fpath=(${ASDF_DIR}/completions $fpath)
# initialise completions with ZSH's compinit
autoload -Uz compinit && compinit

export PATH=$GOPATH/bin:$HOME/bin:$PATH:/usr/local/bin
export DOCKER_HOST=unix:///run/user/1000/docker.sock
