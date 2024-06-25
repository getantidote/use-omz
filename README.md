# antidote-use-omz

> A Zsh plugin to make using Oh-My-Zsh with antidote easier.

The Zsh plugin manager [antidote][antidote] can be used to load subplugins, such as those included in frameworks like [Oh-My-Zsh][omz]. However, with projects like Oh-My-Zsh, you often have to know a bunch about the inner workings of to set all the right variables, include all the right libraries, declare all the right functions, or set up completion correctly. While antidote documents that process, it's unnecessarily complicated for regular users that just want to use antidote and Oh-My-Zsh together seamlessly.

Since antidote is intended to be an all-purpose high performance Zsh plugin manager without added complexity or special handling of plugins or frameworks like OMZ, this project serves as a bridge.

## How do I use it?

Simply include this at the top of your antidote `${ZDOTDIR:-$HOME}/.zsh_plugins.txt` file:

```zsh
mattmc3/antidote-use-omz
```

It's that easy. Now, you can use OMZ plugins without worry.

## Need more examples?

```zsh
### .zsh_plugins.txt

# If you use OMZ with antidote, load this plugin FIRST to set things up so you don't have to worry about whether Oh-My-Zsh will work correctly.
mattmc3/antidote-use-omz

# You may need to use all of OMZ's lib like so:
#   ohmyzsh/ohmyzsh path:lib
#
# -OR-, if you really know what you want, you might be able to choose only
# the specific libs you need:
#   ohmyzsh/ohmyzsh path:lib/clipboard.zsh
#
ohmyzsh/ohmyzsh path:lib/clipboard.zsh

# Now include some plugins
ohmyzsh/ohmyzsh path:plugins/copybuffer
ohmyzsh/ohmyzsh path:plugins/copyfile
ohmyzsh/ohmyzsh path:plugins/copypath
ohmyzsh/ohmyzsh path:plugins/extract
ohmyzsh/ohmyzsh path:plugins/git
ohmyzsh/ohmyzsh path:plugins/magic-enter
ohmyzsh/ohmyzsh path:plugins/fancy-ctrl-z
# ... etc ...
```

[antidote]:  https://github.com/mattmc3/antidote
[omz]:       https://github.com/ohmyzsh/ohmyzsh
