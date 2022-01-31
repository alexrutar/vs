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
If you are currently in a (Neo)Vim session which is not currently being saved, you can run
```
:VSave <session name>
```

## Installation
If you have something like [fisher](https://github.com/jorgebucaran/fisher) installed, you can
```
fisher install alexrutar/v-session-manager
```
Otherwise, the function is in [functions/v.fish](functions/v.fish) and the completions are in [completions/v.fish](completions/v.fish) and you can just install them manually.

You also need to install [Obsession.vim](https://github.com/tpope/vim-obsession) and add the following (Neo)Vim command to your `.vimrc` or `init.vim`:
```
command -nargs=1 SSave Obsess $VIM_SESSION_DIR/<args>.vim
```
The script is documented via tab-completion.

## Dependencies
You need the tools [fzf](https://github.com/junegunn/fzf) and [fd](https://github.com/sharkdp/fd) accessible on your `PATH`.
You also need a mildly modern version of `tree`.
If you're running macOS and everything is outdated, you can
```
brew install coreutils
```

## Configuration
You can select where you want the session files to be saved with the variable `V_SESSION_DIR`.
It defaults to `$XDG_DATA_HOME/v`.

For example, I personally like to
```
set -x V_SESSION_DIR "$XDG_DATA_HOME/nvim/sessions"
```
