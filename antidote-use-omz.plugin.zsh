#
# antidote-use-omz: A Zsh plugin to make using Oh-My-Zsh with antidote easier.
#

# References:
# - https://github.com/ohmyzsh/ohmyzsh/blob/master/oh-my-zsh.sh

# Oh-My-Zsh can be a bit of a dependency [Rat King](https://en.wikipedia.org/wiki/Rat_king).
# But, it has some really useful plugins. This plugin serves to simply untangle those rat
# tails so that OMZ plugins can be used with the antidote Zsh plugin manager seamlessly.

#region helpers
0=${(%):-%N}

##? Check if a name is a command, function, or alias.
function is-callable {
  (( $+commands[$1] || $+functions[$1] || $+aliases[$1] || $+builtins[$1] ))
}

# Support additional Zsh hooks.
(( $+functions[hooks-add-hook] )) || source ${0:A:h}/zsh-hooks.zsh
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

#region https://github.com/ohmyzsh/ohmyzsh/blob/a87e9c715b2d3249681f9cc8f8d9718030674d50/oh-my-zsh.sh#L53-L68
# Set ZSH_CUSTOM to the path where your custom config files
# and plugins exists, or else we will use the default custom/
[[ -n "$ZSH_CUSTOM" ]] || ZSH_CUSTOM="$ZSH/custom"

# Set ZSH_CACHE_DIR to the path where cache files should be created
# or else we will use the default cache/
[[ -n "$ZSH_CACHE_DIR" ]] || ZSH_CACHE_DIR="$ZSH/cache"

# Make sure $ZSH_CACHE_DIR is writable, otherwise use a directory in $HOME
if [[ ! -w "$ZSH_CACHE_DIR" ]]; then
  ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/oh-my-zsh"
fi

# Create cache and completions dir and add to $fpath
mkdir -p "$ZSH_CACHE_DIR/completions"
(( ${fpath[(Ie)"$ZSH_CACHE_DIR/completions"]} )) || fpath=("$ZSH_CACHE_DIR/completions" $fpath)
#endregion











# # Reference:
# # - https://github.com/zsh-users/zsh/blob/master/Completion/compinit

# # Define wrapper functions for completion commands so we can queue up calls to them.
# # That way after compinit is called for real, we can play back the queue.
# # TODO: Add more than compdef if there are others needed.
# typeset -gHa __compcmd_queue=()
# function queued_compcmd compdef {
#   0=${(%):-%N}
#   if (( $# )); then
#     local -a args=("${@[@]}")
#     __compcmd_queue+=("$(typeset -p args); $0 \$args")
#   else
#     __compcmd_queue+=("$0")
#   fi
# }

# # Wrap compinit so that when it's finally called the queue of completion commands is
# # processed in order.
# typeset -gHa __compinit_args=()
# function compinit {
#   __compinit_args=("${@[@]}")
# }

# # Deferred compinit call. When it's finally called, the queue of completion commands is
# # processed in order.
# function compinit_deferred {
#   # Unset any completion wrappers.
#   unfunction compinit queued_compcmd compdef &>/dev/null

#   # Load the real compinit.
#   autoload -Uz compinit && compinit "${__compinit_args[@]}"

#   # Process the completion command queue.
#   local cmpcmd
#   for cmpcmd in $__compcmd_queue; do
#     eval $cmpcmd
#   done
#   unset __compcmd_queue

#   # Cleanup.
#   unfunction compinit_deferred
# }

# # If the user didn't specify they wanted to manually initialize completions,
# # then attach compinit to the precmd hook so that it happens at the very end.
# autoload -Uz add-zsh-hook
# function ensure-compinit-during-precmd {
#   # If the shell is interactive, ensure compinit runs before the first command.
#   if [[ -o interactive ]] && (( $+functions[compinit_deferred] )); then
#     compinit_deferred
#   fi

#   # Remove the hook so that it doesn't keep running on every precmd event.
#   add-zsh-hook -d precmd ensure-compinit-during-precmd
# }
# add-zsh-hook precmd ensure-compinit-during-precmd







# # Bootstrap.
# 0=${(%):-%N}
# zstyle -t ':zephyr:lib:bootstrap' loaded || source ${0:a:h:h:h}/lib/bootstrap.zsh
# autoload-dir ${0:a:h}/functions

# # 16.2.2 Completion
# setopt always_to_end        # Move cursor to the end of a completed word.
# setopt auto_list            # Automatically list choices on ambiguous completion.
# setopt auto_menu            # Show completion menu on a successive tab press.
# setopt auto_param_slash     # If completed parameter is a directory, add a trailing slash.
# setopt complete_in_word     # Complete from both ends of a word.
# setopt NO_menu_complete     # Do not autoselect the first completion entry.

# # 16.2.3 Expansion and Globbing
# setopt extended_glob        # Needed for file modification glob modifiers with compinit.

# # 16.2.6 Input/Output
# setopt path_dirs            # Perform path search even on command names with slashes.
# setopt NO_flow_control      # Disable start/stop characters in shell editor.

# # Add other upstream completions to $fpath.
# fpath=(
#   ${0:a:h}/external/src  # zsh-users/zsh-completions
#   ${0:a:h}/completions   # starship, git contrib
#   $fpath
# )

# # Add completions for keg-only brews when available.
# if (( $+commands[brew] )); then
#   brew_prefix=${HOMEBREW_PREFIX:-${HOMEBREW_REPOSITORY:-$commands[brew]:A:h:h}}
#   # $HOMEBREW_PREFIX defaults to $HOMEBREW_REPOSITORY but is explicitly set to
#   # /usr/local when $HOMEBREW_REPOSITORY is /usr/local/Homebrew.
#   # https://github.com/Homebrew/brew/blob/2a850e02d8f2dedcad7164c2f4b95d340a7200bb/bin/brew#L66-L69
#   [[ $brew_prefix == '/usr/local/Homebrew' ]] && brew_prefix=$brew_prefix:h

#   # Add brew locations to fpath
#   fpath=(
#     # Add curl completions from homebrew.
#     $brew_prefix/opt/curl/share/zsh/site-functions(/N)

#     # Add zsh completions.
#     $brew_prefix/share/zsh/site-functions(-/FN)

#     $fpath
#   )
#   unset brew_prefix
# fi

# # Add custom completions.
# fpath=(${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/zsh}/completions(-/FN) $fpath)

# # Let's talk compinit... compinit works by finding _completion files in your fpath. That
# # means fpath has to be fully populated prior to calling compinit. If you use oh-my-zsh,
# # if populates fpath and runs compinit prior to loading plugins. This is only
# # problematic if you expect to be able to add to fpath later. Conversely, if you wait to
# # run compinit until the end of your config, then functions like compdef aren't
# # available earlier in your config.
# #
# # TLDR; this code handles all those use cases and simply queues calls to compdef and
# # hooks compinit to precmd for one call only, which happens automatically at the end of
# # your config. You can override this behavior with zstyles.
# if zstyle -t ':zephyr:plugin:completion' immediate; then
#   run-compinit
# else
#   # Define compinit placeholder functions (compdef) so we can queue up calls to compdef.
#   # That way when the real compinit is called, we can execute the queue.
#   typeset -gHa __zephyr_compdef_queue=()
#   function compdef {
#     (( $# )) || return
#     local compdef_args=("${@[@]}")
#     __zephyr_compdef_queue+=("$(typeset -p compdef_args)")
#   }

#   # Wrap compinit temporarily so that when the real compinit call happens, the
#   # queue of compdef calls is processed.
#   function compinit {
#     unfunction compinit compdef &>/dev/null
#     autoload -Uz compinit && compinit "$@"
#     local typedef_compdef_args
#     for typedef_compdef_args in $__zephyr_compdef_queue; do
#       eval $typedef_compdef_args
#       compdef "$compdef_args[@]"
#     done
#     unset __zephyr_compdef_queue
#   }

#   # If the user didn't specify they wanted to manually initialize completions,
#   # then attach compinit to the precmd hook so that it happens at the very end.
#   if ! zstyle -t ':zephyr:plugin:completion' manual; then
#     autoload -Uz add-zsh-hook
#     function run-compinit-precmd {
#       run-compinit
#       add-zsh-hook -d precmd run-compinit-precmd
#     }
#     add-zsh-hook precmd run-compinit-precmd
#   fi
# fi

# # Set the completion style
# zstyle -s ':zephyr:plugin:completion' compstyle 'zcompstyle' || zcompstyle=zephyr
# if (( $+functions[compstyle_${zcompstyle}_setup] )); then
#   compstyle_${zcompstyle}_setup
# else
#   compstyleinit && compstyle ${zcompstyle}
# fi
# unset zcompstyle

# # Mark this plugin as loaded.
# zstyle ':zephyr:plugin:completion' loaded 'yes'
