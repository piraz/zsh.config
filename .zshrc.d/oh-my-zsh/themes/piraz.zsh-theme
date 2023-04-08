# For colors tips: https://stackoverflow.com/a/65339599/2887989
# See: https://github.com/ohmyzsh/ohmyzsh/blob/master/themes/bira.zsh-theme


local fg_bold_white="%{$fg_bold[white]%}"
local fg_bold_yellow="%{$fg_bold[yellow]%}"
local fg_green="%{$fg[green]%}"
local fg_bold_green="%{$fg_bold[green]%}"
local fg_bold_red="%{$fg_bold[red]%}"

local r_color="%{$reset_color%}"

local green_op="${fg_green}[${r_color}"
local green_cp="${fg_green}]${r_color}"
local green_cn="${fg_green}-${r_color}"

local prompt_end="${fg_green}>>>${r_color}"

venv_prompt() {
    if [[ -z ${VIRTUAL_ENV+x} ]]; then
        echo -n
	return
    fi
    venv=`basename $VIRTUAL_ENV`
    pyver=`python --version`
    at_venv="${fg_bold_yellow}@${fg_bold_white}$venv"
    with_pyver=" ${fg_bold_green}with${fg_bold_white} $pyver"
    echo "$with_pyver$at_venv"
}

local vcs_branch='$(git_prompt_info)$(hg_prompt_info)'
local venv_prompt='$(venv_prompt)'

local curr_dir="${green_op}${fg_bold_white}pwd:%~${green_cp}"
local user_host="${green_op}${fg_bold_white}%n${fg_bold_yellow}@${fg_bold_white}%m${venv_prompt}${green_cp}${green_cn}"
local hist_no="${green_op}${fg_bold_white}#%h${green_cp}"
local jobs_no="${green_op}${fg_bold_white}jobs:%j${green_cp}${green_cn}"
local ret_status="${fg_bold_white}err:%?"
local piraz_smirk="%(?,${fg_bold_white}P%)${r_color},${fg_bold_red}P( ${ret_status}${r_color})"

PROMPT="${user_host}${green_op}${piraz_smirk}${green_cp}
${jobs_no}${curr_dir}${vcs_branch}
${hist_no}${prompt_end} "

ZSH_THEME_GIT_PROMPT_PREFIX="${fg_bold_green}(${fg_bold_red}"
ZSH_THEME_GIT_PROMPT_SUFFIX="${fg_bold_green})${r_color}"
ZSH_THEME_GIT_PROMPT_CLEAN=""
ZSH_THEME_GIT_PROMPT_DIRTY="*"

ZSH_THEME_HG_PROMPT_PREFIX="$ZSH_THEME_GIT_PROMPT_PREFIX"
ZSH_THEME_HG_PROMPT_SUFFIX="$ZSH_THEME_GIT_PROMPT_SUFFIX"
ZSH_THEME_HG_PROMPT_DIRTY="$ZSH_THEME_GIT_PROMPT_DIRTY"
ZSH_THEME_HG_PROMPT_CLEAN="$ZSH_THEME_GIT_PROMPT_CLEAN"

ZSH_THEME_VIRTUAL_ENV_PROMPT_PREFIX="${green_op}${fg_bold_white}venv:"
ZSH_THEME_VIRTUAL_ENV_PROMPT_SUFFIX="${green_cp}${green_cn}"
ZSH_THEME_VIRTUALENV_PREFIX="$ZSH_THEME_VIRTUAL_ENV_PROMPT_PREFIX"
ZSH_THEME_VIRTUALENV_SUFFIX="$ZSH_THEME_VIRTUAL_ENV_PROMPT_SUFFIX"
