#
# use-omz: A Zsh plugin to make using Oh-My-Zsh with antidote easier.
#

# References:
# - https://github.com/ohmyzsh/ohmyzsh/blob/master/oh-my-zsh.sh
# - https://github.com/zsh-users/zsh/blob/master/Completion/compinit

# Oh-My-Zsh can be a bit of a dependency [Rat King](https://en.wikipedia.org/wiki/Rat_king).
# But, it has some really useful plugins. This plugin serves to simply untangle those rat
# tails so that OMZ plugins can be used with the antidote Zsh plugin manager seamlessly.

#region init and helpers
0=${(%):-%N}

##? Check a string for case-insensitive "true" value (1,y,yes,t,true,on).
function is-true {
  [[ -n "$1" && "$1:l" == (1|y(es|)|t(rue|)|on) ]]
}

# Ensure fpath does not contain duplicates.
typeset -gU fpath

# OMZ uses this extensively
autoload -Uz is-at-least

### BUGFIX:
# OMZ has current regression: https://github.com/ohmyzsh/ohmyzsh/issues/12328#issuecomment-2043492331
# If async isn't explicitly set to 'yes', make it 'no' for now.
if ! zstyle -t ':omz:alpha:lib:git' async-prompt; then
  zstyle ':omz:alpha:lib:git' async-prompt no
fi
#endregion

#region Set $ZSH
# Make sure we know where antidote keeps OMZ.
() {
  [[ -z "$ZSH" ]] || return
  if (( $+commands[antidote] || $+functions[antidote] )); then
    export ZSH=$(antidote path ohmyzsh/ohmyzsh)
  else
    echo >&2 "use-omz: antidote command not found."
    return 1
  fi
}

# Make sure we have Oh-My-Zsh cloned.
if [[ ! -d $ZSH ]]; then
  echo >&2 "use-omz: oh-my-zsh not found, or \$ZSH not properly set."
  return 1
fi
#endregion

#region OMZ core variables
# https://github.com/ohmyzsh/ohmyzsh/blob/a87e9c715b2d3249681f9cc8f8d9718030674d50/oh-my-zsh.sh#L53-L68
# Set ZSH_CUSTOM to the path where your custom config files
# and plugins exists, or else we will use the default custom.
[[ -n "$ZSH_CUSTOM" ]] || ZSH_CUSTOM="$ZSH/custom"

# Set ZSH_CACHE_DIR to the path where cache files should be created
# or else we will use the default cache.
[[ -n "$ZSH_CACHE_DIR" ]] || ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"

# Create cache and completions dir and add to $fpath.
mkdir -p "$ZSH_CACHE_DIR/completions"
(( ${fpath[(Ie)"$ZSH_CACHE_DIR/completions"]} )) || fpath=("$ZSH_CACHE_DIR/completions" $fpath)
#endregion

#region Defer compinit and queue completion commands
# Define wrapper functions for completion commands so we can queue up calls to them.
# That way after compinit is called for real, we can play back the queue.
# TODO: Add more builtin completion functions for queuing if others are discovered.
typeset -gHa __compcmd_queue=()
function queued_compcmd compdef {
  0=${(%):-%N}
  if (( $# )); then
    local -a args=("${@[@]}")
    __compcmd_queue+=("$(typeset -p args); $0 \$args")
  else
    __compcmd_queue+=("$0")
  fi
}

# Deferred compinit. When it's finally called, the queue of completion commands is
# processed in order.
function compinit compinit_deferred {
  # Unset any completion wrappers.
  unfunction compinit queued_compcmd compdef &>/dev/null

  # Load the real compinit.
  unfunction compinit &>/dev/null
  autoload -Uz compinit && compinit "${@[@]}"

  # Load other stock functions (from $fpath files) called below.
  autoload -U compaudit zrecompile

  # Process the completion command queue.
  local cmpcmd
  for cmpcmd in $__compcmd_queue; do
    eval $cmpcmd
  done
  unset __compcmd_queue

  # Cleanup.
  unfunction compinit_deferred
}

# In case the user didn't decide to explicitly call compinit, we attach compinit to the
# precmd hook so that we ensure completions are intialized at the very end.
autoload -Uz add-zsh-hook
function ensure-compinit-during-precmd {
  # If the shell is interactive, ensure compinit runs before the first command.
  if [[ -o interactive ]] && (( $+functions[compinit_deferred] )); then
    run-compinit
  fi

  # Remove the hook so that it doesn't keep running on every precmd event.
  add-zsh-hook -d precmd ensure-compinit-during-precmd
}
add-zsh-hook precmd ensure-compinit-during-precmd
#endregion

#region Run compinit
# Check ZSH_COMPDUMP metadata to see if zcompdump has expired.
function has-zcompdump-expired {
  emulate -L zsh
  setopt local_options

  # Get current metadata.
  local zsh_compdump_rev="$(git -C "$ZSH" rev-parse HEAD 2>/dev/null)"
  local zsh_compdump_fpath=($fpath)

  # Get previous metadata.
  typeset -g ZSH_COMPDUMP_REV
  typeset -ga ZSH_COMPDUMP_FPATH
  [[ -r $ZSH_CACHE_DIR/zcompdump-metadata.zsh ]] && source $ZSH_CACHE_DIR/zcompdump-metadata.zsh

  # Compare to see if zcompdump should be expired.
  if [[ "$zsh_compdump_rev" != "$ZSH_COMPDUMP_REV" ]] ||
     [[ "$zsh_compdump_fpath" != "$ZSH_COMPDUMP_FPATH" ]]
  then
    ZSH_COMPDUMP_REV=$zsh_compdump_rev
    ZSH_COMPDUMP_FPATH=($zsh_compdump_fpath)
    { typeset -p ZSH_COMPDUMP_REV; typeset -p ZSH_COMPDUMP_FPATH } > $ZSH_CACHE_DIR/zcompdump-metadata.zsh
  else
    return 1
  fi
}

# Figure out the SHORT hostname
if [[ -z "$SHORT_HOST" ]]; then
  # Figure out the SHORT hostname
  if [[ "$OSTYPE" = darwin* ]]; then
    # macOS's $HOST changes with dhcp, etc. Use ComputerName if possible.
    SHORT_HOST=$(scutil --get ComputerName 2>/dev/null) || SHORT_HOST="${HOST/.*/}"
  else
    SHORT_HOST="${HOST/.*/}"
  fi
fi

# Save the location of the current completion dump file.
if [[ -z "$ZSH_COMPDUMP" ]]; then
  ZSH_COMPDUMP="$ZSH_CACHE_DIR/zcompdump-${SHORT_HOST}-${ZSH_VERSION}"
fi

function run-compinit {
  has-zcompdump-expired && command rm -f "$ZSH_COMPDUMP"

  if [[ -z "$ZSH_DISABLE_COMPFIX" ]] || is-true "$ZSH_DISABLE_COMPFIX"; then
    # If the user wants it, load from all found directories
    compinit -u -d "$ZSH_COMPDUMP"
  else
    source "$ZSH/lib/compfix.zsh"
    # Load only from secure directories
    compinit -i -d "$ZSH_COMPDUMP"
    # If completion insecurities exist, warn the user
    handle_completion_insecurities &|
  fi

  # Compile zcompdump, if modified, in background to increase startup speed.
  {
    if [[ -s "$ZSH_COMPDUMP" && (! -s "${ZSH_COMPDUMP}.zwc" || "$ZSH_COMPDUMP" -nt "${ZSH_COMPDUMP}.zwc") ]]; then
      if command mkdir "${ZSH_COMPDUMP}.lock" 2>/dev/null; then
        zrecompile -q -p "$ZSH_COMPDUMP"
        command rm -rf "${ZSH_COMPDUMP}.zwc.old" "${ZSH_COMPDUMP}.lock" 2>/dev/null
      fi
    fi
  } &!
}
#endregion

#region themes
function set-omz-theme-during-precmd {
  # Remove this hook so that it doesn't keep running on every precmd event.
  add-zsh-hook -d precmd set-omz-theme-during-precmd

  # Return, unless the shell is interactive and ZSH_THEME is set.
  [[ -o interactive ]] && [[ -n "$ZSH_THEME" ]] || return

  # Load prompt pre-reqs
  (( $+functions[_omz_register_handler] ))   || source $ZSH/lib/async_prompt.zsh
  [[ -v FX ]] && [[ -v FG ]] && [[ -v BG ]]  || source $ZSH/lib/spectrum.zsh
  (( $+function[colors] )) &&
    [[ -v ZSH_THEME_GIT_PROMPT_PREFIX ]]     || source $ZSH/lib/theme-and-appearance.zsh
  (( $+function[VCS_INFO_formats] ))         || source $ZSH/lib/vcs_info.zsh

  # Load the theme
  is_theme() {
    local base_dir=$1
    local name=$2
    builtin test -f $base_dir/$name.zsh-theme
  }

  # Set prompt
  if is_theme "$ZSH_CUSTOM" "$ZSH_THEME"; then
    source "$ZSH_CUSTOM/$ZSH_THEME.zsh-theme"
  elif is_theme "$ZSH_CUSTOM/themes" "$ZSH_THEME"; then
    source "$ZSH_CUSTOM/themes/$ZSH_THEME.zsh-theme"
  elif is_theme "$ZSH/themes" "$ZSH_THEME"; then
    source "$ZSH/themes/$ZSH_THEME.zsh-theme"
  else
    echo "[oh-my-zsh] theme '$ZSH_THEME' not found"
  fi
}
add-zsh-hook precmd set-omz-theme-during-precmd
#endregion

#region Lazy-loaded OMZ libs
# Leave for user to decide to load or not:
# lib/completion.zsh
# lib/correction.zsh
# lib/diagnostics.zsh
# lib/directories.zsh
# lib/grep.zsh
# lib/history.zsh
# lib/key-bindings.zsh
# lib/misc.zsh
# lib/termsupport.zsh

# lib/async_prompt.zsh
(( $+functions[_omz_register_handler] )) ||
function _omz_register_handler _omz_async_request _omz_async_callback {
  source $ZSH/lib/async_prompt.zsh
  "$0" "$@"
}

# lib/bzr.zsh
(( $+functions[bzr_prompt_info] )) ||
function bzr_prompt_info {
  source $ZSH/lib/bzr.zsh
  "$0" "$@"
}

# lib/cli.zsh
(( $+functions[omz] )) ||
function omz {
  source $ZSH/lib/cli.zsh
  "$0" "$@"
}

# lib/clipboard.zsh
(( $+functions[detect-clipboard] )) ||
function detect-clipboard clipcopy clippaste {
  unfunction detect-clipboard
  source $ZSH/lib/clipboard.zsh
  detect-clipboard
  "$0" "$@"
}

# lib/compfix.zsh
(( $+functions[handle_completion_insecurities] )) ||
function handle_completion_insecurities {
  source $ZSH/lib/compfix.zsh
  "$0" "$@"
}

# lib/functions.zsh
(( $+functions[open_command] )) ||
function env_default \
  open_command \
  omz_urldecode \
  omz_urlencode \
{
  source $ZSH/lib/functions.zsh
  "$0" "$@"
}

# lib/git.zsh
(( $+functions[git_prompt_info] )) ||
function git_prompt_info \
  git_prompt_status \
  parse_git_dirty \
  git_remote_status \
  git_current_branch \
  git_commits_ahead \
  git_commits_behind \
  git_prompt_ahead \
  git_prompt_behind \
  git_prompt_remote \
  git_prompt_short_sha \
  git_prompt_long_sha \
  git_current_user_name \
  git_current_user_email \
  git_repo_name \
{
  (( $+functions[_omz_register_handler] )) || source $ZSH/lib/async_prompt.zsh
  source $ZSH/lib/git.zsh
  "$0" "$@"
}

# lib/nvm.zsh
(( $+functions[nvm_prompt_info] )) ||
function nvm_prompt_info {
  source $ZSH/lib/nvm.zsh
  "$0" "$@"
}

# lib/prompt_info_functions.zsh
(( $+functions[rvm_prompt_info] )) ||
function chruby_prompt_info \
  rbenv_prompt_info \
  hg_prompt_info \
  pyenv_prompt_info \
  svn_prompt_info \
  vi_mode_prompt_info \
  virtualenv_prompt_info \
  jenv_prompt_info \
  azure_prompt_info \
  tf_prompt_info \
  rvm_prompt_info \
  ruby_prompt_info \
{
  source $ZSH/lib/prompt_info_functions.zsh
  "$0" "$@"
}
#endregion
