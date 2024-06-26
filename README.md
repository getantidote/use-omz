# antidote-use-omz

> A Zsh plugin to make using Oh-My-Zsh with antidote seamless.

The Zsh plugin manager [antidote][antidote] can be used to load subplugins, such as those included in frameworks like Prezto and [Oh-My-Zsh][omz]. However, it doesn't have specific logic to treat these popular frameworks different than any other plugin. With projects like Oh-My-Zsh (aka: OMZ) that have a lot of dependencies on itself, and aren't expecting to be loaded any way other than the documented default, that can be a problem.

With OMZ, you have to know what each OMZ plugin you are using requires and be sure to include all those pre-requisites - setting all the right variables, including all the right libraries, declaring all the right functions, or setting up Zsh completions to work correctly. It become quite the dependency [Rat King](https://en.wikipedia.org/wiki/Rat_king). And, the project is popular and constantly evolving, making using OMZ with antidote an unnecessarily complicated process for regular users that just want them to work together seamlessly. This project aims to solve all that.

Since [antidote][antidote] is intended to be a general-purpose, high performance Zsh plugin manager without added complexity or special handling of frameworks like OMZ, this simple plugin serves as a bridge. It's not strictly necessary to use [antidote-use-omz](https://github.com/mattmc3/antidote-use-omz) with antidote, but it really helps, and is highly recommended.

## How do I use it?

Simply include this plugin FIRST, at the top of your antidote `${ZDOTDIR:-$HOME}/.zsh_plugins.txt` file. To do that, add this line:

```zsh
mattmc3/antidote-use-omz
```

It's that easy. Now, you can use OMZ plugins without worry.

## Performance

__Q:__ Is this fast? I've heard OMZ is slow.
<br/>
__A:__ Absolutely! With antidote, I'm committed to making sure Zsh users have a speedy shell. OMZ has a bit of a reputation for being slow out of the box. This project not only makes working with OMZ's plugins simple, it also adds many performance enhancements like lazy-loading, caching, and completion optimizations. But, it won't save you from [choosing certain OMZ plugins that are notoriously slow](https://github.com/ohmyzsh/ohmyzsh/issues/5327#issuecomment-248836398). You can run benchmarks for yourself with [zsh-bench].

## Troubleshooting

__Q:__ Do I need to use this plugin if I'm using antidote and OMZ?
</br>
__A:__ Not strictly, but this plugin is now the officially supported way to use antidote correctly with OMZ.

__Q:__ What if I find an OMZ plugin that doesn't work?
</br>
__A:__ [Submit an issue here](https://github.com/mattmc3/antidote-use-omz/issues). OMZ specific issues won't be fixed within antidote itself, but this project aims to support every OMZ subplugin with antidote.

## Examples

There is a sample [ZDOTDIR project](https://github.com/getantidote/zdotdir/tree/ohmyzsh) included with antidote which shows many examples.

Here's a more complete .zsh_plugins.txt you can use as a starter config.

Example `${ZDOTDIR:-$HOME}/.zshrc`:

```zsh
# Set OMZ variables if you want.
ZSH_THEME=robbyrussell

# Set any helper functions used by your antidote config.
function is-macos() {
  [[ $OSTYPE == darwin* ]]
}

# Load antidote plugins.
source /path/to/antidote/antidote.zsh
antidote load

# Customize
# ... add your other customizations ...
```

Example `${ZDOTDIR:-$HOME}/.zsh_plugins.txt`:

```zsh
# If you use Oh-My-Zsh with antidote, load this plugin FIRST to set things up so you
# don't have to worry about whether OMZ will work correctly.
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

# Add binary utils
romkatv/zsh-bench kind:path

# Add core plugins that make Zsh a bit more like Fish
zsh-users/zsh-completions path:src kind:fpath
zsh-users/zsh-autosuggestions
zsh-users/zsh-history-substring-search
zdharma-continuum/fast-syntax-highlighting

# ... etc ...
```

## Differences

A quick note on differences in behavior between OMZ and antidote-use-omz:

- Oh-My-Zsh by default checks the security of directories in `fpath` when running `compinit`. This feature can cause slower performance, and can be disabled by setting `ZSH_DISABLE_COMPFIX=true`. If `ZSH_DISABLE_COMPFIX` isn't set at all, the default audit is performed. antidote-use-omz reverses this default behavior, so to re-enable it you should explicitly set `ZSH_DISABLE_COMPFIX=false`.

- Oh-My-Zsh by default embeds metadata information in the `$ZSH_COMPDUMP` file. The way it does this is slow, so antidote-use-omz saves metadata in a separate cache file as a performance optimization.

[antidote]:   https://github.com/mattmc3/antidote
[omz]:        https://github.com/ohmyzsh/ohmyzsh
[zsh-bench]:  https://github.com/romkatv/zsh-bench
