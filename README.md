# V Session Manager
This script is essentially a command line wrapper around [Obsession.vim](https://github.com/tpope/vim-obsession), which is itself a wrapper around Vim's built-in `:mksession`.
Initialize new sessions with
```
v init <session name>
```
Open existing sesssions with
```
v open <session name>
```
or simply `v open` to open up a nice prompt in [fzf](https://github.com/junegunn/fzf).

## Installation
If you have something like [fisher](https://github.com/jorgebucaran/fisher) installed, you can just
```
fisher install alexrutar/v-session-manager
```
Otherwise, the function is in [functions/v.fish](functions/v.fish) and the completions are in [completions/v.fish](completions/v.fish) and you can just install them manually.
The script is documented via tab-completion.

## Dependencies
You need the tools [fzf](https://github.com/junegunn/fzf) and [fd](https://github.com/sharkdp/fd) accessible on your `PATH`.
You also need a mildly modern version of `tree`.
If you're running macOS and everything is outdated, you can
```
brew install coreutils
```
