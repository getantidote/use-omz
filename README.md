# antidote-use-omz

> A Zsh plugin to make using Oh-My-Zsh with antidote easier.

The [antidote][antidote] Zsh plugin manager can be used to load [Oh-My-Zsh][omz] plugins. However, you have to know a bunch about the inner workings of Oh-My-Zsh to set all the right variables, include all the right libraries, and set up completion correctly. While antidote documents that process, it's complicated for regular users that just want to use antidote and Oh-My-Zsh together seamlessly.

Since antidote is intended to be an all-purpose high performance Zsh plugin manager without added complexity or special handling for plugins or frameworks like OMZ, this project serves as a bridge.

## How do I use it?

Simply include this at the top of your antidote `${ZDOTDIR:-$HOME}/.zsh_plugins.txt` file:

```zsh
mattmc3/antidote-use-omz
```

It's that easy. Now, you can use OMZ plugins without worry.

```zsh
### .zsh_plugins.txt

# If you use OMZ with antidote, this sets things up so you don't have to
mattmc3/antidote-use-omz

# Now, include your preferred OMZ libs, plugins, and even themes:
ohmyzsh/ohmyzsh path:lib/clipboard.zsh
ohmyzsh/ohmyzsh path:plugins/git
ohmyzsh/ohmyzsh path:plugins/extract
# ... etc ...
```

[antidote]:  https://github.com/mattmc3/antidote
[omz]:       https://github.com/ohmyzsh/ohmyzsh
