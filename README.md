# antidote-use-omz

> A Zsh plugin to make using Oh-My-Zsh with antidote easier.

The Zsh plugin manager [antidote][antidote] can be used to load subplugins, such as those included in frameworks like [Oh-My-Zsh][omz]. However, it doesn't have specific logic to treat these popular frameworks different than any other plugin. With projects like Oh-My-Zsh that have a lot of dependencies on itself, and aren't expecting to be loaded any way other than the documented default, that can be a problem.

With Oh-My-Zsh, it's a Rat King of dependencies. You have to know what the OMZ plugin you are using requires and be sure to set up those pre-requisites - setting all the right variables, including all the right libraries, declaring all the right functions, or setting up Zsh completions to work correctly. OMZ can be a real [Rat King](https://en.wikipedia.org/wiki/Rat_king) of dependencies. While antidote documents some of that, it's constantly changing and an unnecessarily complicated process for regular users that just want to use antidote with Oh-My-Zsh together seamlessly.

Since [antidote][antidote] is intended to be a general-purpose, high performance Zsh plugin manager without added complexity or special handling of frameworks like OMZ, this project serves as a bridge. It's not strictly necessary to include [antidote-use-omz](https://github.com/mattmc3/antidote-use-omz) with antidote, it is highly recommended.

## How do I use it?

Simply include this at the top of your antidote `${ZDOTDIR:-$HOME}/.zsh_plugins.txt` file:

```zsh
mattmc3/antidote-use-omz
```

It's that easy. Now, you can use OMZ plugins without worry.

## Troubleshooting

Q: What if I find an OMZ plugin that doesn't work?
A: [Submit an issue here](https://github.com/mattmc3/antidote-use-omz/issues). OMZ specific issues won't be fixed in antidote. This plugin is now the supported way to use antidote correctly with OMZ.

## Need more examples?

There is a sample [ZDOTDIR project](https://github.com/getantidote/zdotdir/tree/ohmyzsh) included with antidote which shows many examples.

Here's a more complete .zsh_plugins.txt you can use as a starter config.

```zsh
#
# .zsh_plugins.txt: antidote plugins
#

# If you use OMZ with antidote, load this plugin FIRST to set things up so you don't have to worry about whether Oh-My-Zsh will work correctly.
mattmc3/antidote-use-omz

# Regarding OMZ libs - you may decide to use all of OMZ's lib like so:
#   ohmyzsh/ohmyzsh path:lib
#
# -OR-, if you really know what you want and nothing else, you might be able to
# choose only the specific libs you need:
#   ohmyzsh/ohmyzsh path:lib/clipboard.zsh
#

# Let's go ahead and use all of Oh My Zsh's lib directory.
ohmyzsh/ohmyzsh path:lib

# Now, let's pick our Oh My Zsh utilty plugins
ohmyzsh/ohmyzsh path:plugins/colored-man-pages
ohmyzsh/ohmyzsh path:plugins/copybuffer
ohmyzsh/ohmyzsh path:plugins/copyfile
ohmyzsh/ohmyzsh path:plugins/copypath
ohmyzsh/ohmyzsh path:plugins/extract
ohmyzsh/ohmyzsh path:plugins/globalias
ohmyzsh/ohmyzsh path:plugins/magic-enter
ohmyzsh/ohmyzsh path:plugins/fancy-ctrl-z
ohmyzsh/ohmyzsh path:plugins/git
ohmyzsh/ohmyzsh path:plugins/ruby
ohmyzsh/ohmyzsh path:plugins/otp
ohmyzsh/ohmyzsh path:plugins/zoxide

# Add some programmer plugins
ohmyzsh/ohmyzsh path:plugins/git
ohmyzsh/ohmyzsh path:plugins/golang
ohmyzsh/ohmyzsh path:plugins/python
ohmyzsh/ohmyzsh path:plugins/ruby
ohmyzsh/ohmyzsh path:plugins/rails

# Add macOS specific plugins
ohmyzsh/ohmyzsh path:plugins/brew conditional:is-macos
ohmyzsh/ohmyzsh path:plugins/macos conditional:is-macos

# Add a nice prompt
romkatv/powerlevel10k

# Add binary utils
romkatv/zsh-bench kind:path

# Add core plugins that make Zsh a bit more like Fish
zsh-users/zsh-completions path:src kind:fpath
zsh-users/zsh-autosuggestions
zsh-users/zsh-history-substring-search
zdharma-continuum/fast-syntax-highlighting

# ... etc ...
```

[antidote]:  https://github.com/mattmc3/antidote
[omz]:       https://github.com/ohmyzsh/ohmyzsh
