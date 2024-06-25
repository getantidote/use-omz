#
# antidote-use-omz: A Zsh plugin to make using Oh-My-Zsh with antidote easier.
#

# References:
# - https://github.com/ohmyzsh/ohmyzsh/blob/master/oh-my-zsh.sh
# - https://github.com/zsh-users/zsh/blob/master/Completion/compinit

# Oh-My-Zsh can be a bit of a dependency [Rat King](https://en.wikipedia.org/wiki/Rat_king).
# But, it has some really useful plugins. This plugin serves to simply untangle those rat
# tails so that OMZ plugins can be used with the antidote Zsh plugin manager seamlessly.

#region init and helpers
0=${(%):-%N}

##? Check if a name is a command, function, or alias.
function is-callable {
  (( $+commands[$1] || $+functions[$1] || $+aliases[$1] || $+builtins[$1] ))
}

##? Check a string for case-insensitive "true" value (1,y,yes,t,true,on).
function is-true {
  [[ -n "$1" && "$1:l" == (1|y(es|)|t(rue|)|on) ]]
}

# Ensure fpath does not contain duplicates.
typeset -gU fpath

# OMZ uses this extensively
autoload -Uz is-at-least
#endregion

#region Set $ZSH
# Make sure we know where antidote keeps OMZ.
() {
  [[ -z "$ZSH" ]] || return

  # OMZ should exist in $ANTIDOTE_HOME/ohmyzsh/ohmyzsh
  typeset -gH adote_home
  if [[ -n "$ANTIDOTE_HOME" ]]; then
    adote_home=$ANTIDOTE_HOME
  elif is-callable antidote; then
    adote_home=$(antidote home)
  elif [[ "${OSTYPE}" == darwin* ]]; then
    adote_home=$HOME/Library/Caches
  elif [[ "${OSTYPE}" == (cygwin|msys)* ]]; then
    adote_home=${LOCALAPPDATA:-$LocalAppData}
    if type cygpath > /dev/null; then
      adote_home=$(cygpath "$result")
    fi
  elif [[ -n "$XDG_CACHE_HOME" ]]; then
    adote_home=$XDG_CACHE_HOME
  else
    adote_home=$HOME/.cache
  fi

  # Set the basic OMZ home variable.
  export ZSH=$adote_home/ohmyzsh/ohmyzsh
}

# Make sure we have Oh-My-Zsh cloned.
if [[ ! -d $ZSH ]]; then
  echo "antidote-use-omz: oh-my-zsh not found, or \$ZSH not properly set."
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

  if [[ -n "$ZSH_DISABLE_COMPFIX" ]] && ! is-true "$ZSH_DISABLE_COMPFIX"; then
    source "$ZSH/lib/compfix.zsh"
    # Load only from secure directories
    compinit -i -d "$ZSH_COMPDUMP"
    # If completion insecurities exist, warn the user
    handle_completion_insecurities &|
  else
    # If the user wants it, load from all found directories
    compinit -u -d "$ZSH_COMPDUMP"
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

#region Lazy-loaded OMZ libs
(( $+functions[_omz_register_handler] )) ||
function _omz_register_handler _omz_async_request _omz_async_callback {
  source $ZSH/lib/async_prompt.zsh
  "$0" "$@"
}

(( $+functions[bzr_prompt_info] )) ||
function bzr_prompt_info {
  source $ZSH/lib/bzr.zsh
  "$0" "$@"
}

(( $+functions[detect-clipboard] )) ||
function detect-clipboard clipcopy clippaste {
  source $ZSH/lib/clipboard.zsh
  detect-clipboard || true # let one retry
  "$0" "$@"
}

(( $+functions[nvm_prompt_info] )) ||
function nvm_prompt_info {
  source $ZSH/lib/nvm.zsh
  "$0" "$@"
}

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
