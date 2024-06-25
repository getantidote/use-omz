# OMZ plugin: 1password

## Setup

```zsh
% source ./tests/__init__.zsh
% t_setup
%
```

```zsh
% source $ZSH/plugins/1password/1password.plugin.zsh 2>&1 | subenv ZSH
$ZSH/plugins/1password/1password.plugin.zsh:6: command not found: compdef
%
```

```zsh
% source antidote-use-omz.plugin.zsh
% plugin-load 1password
%
```

## Teardown

```zsh
% source ./tests/__init__.zsh
% t_teardown
%
```
