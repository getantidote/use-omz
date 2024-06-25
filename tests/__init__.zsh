0=${(%):-%N}
path=(${0:A:h}/mocks $path)

function t_setup {
  emulate -L zsh
  setopt local_options
  0=${(%):-%x}

  # Save prior values
  typeset -gA T_SAVED_VARS=()
  for varname in ZDOTDIR XDG_{CONFIG,CACHE,DATA}_HOME; do
    if [[ -v $varname ]]; then
      T_SAVED_VARS[$varname]=${(P)varname}
    fi
  done

  # works with BSD and GNU gmktemp
  T_TEMPDIR=${$(mktemp -d -t t_antidote_use_zsh.XXXXXXXX):A}

  mkdir -p $T_TEMPDIR/.cache $T_TEMPDIR/.local/share
}

function t_teardown {
  emulate -L zsh
  setopt local_options
  0=${(%):-%x}

  # reset current session
  for key val in ${(kv)T_SAVED_VARS}; do
    $key=${val}
  done

  # remove tempdir
  [[ -d "$T_TEMPDIR" ]] && rm -rf -- "$T_TEMPDIR"
}

function plugin-load {
  fpath=($ZSH/plugins/$1 $fpath)
  source $ZSH/plugins/$1/$1.plugin.zsh
}

function subenv {
  if (( $# == 0 )); then
    subenv ZSH | subenv ZDOTDIR | subenv HOME
  else
    local sedexp="s|${(P)1}|\$$1|g"
    shift
    command sed "$sedexp" "$@"
  fi
}
