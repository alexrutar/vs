# (Neo)Vim Session Manager
This script is essentially a command line wrapper around [Obsession.vim](https://github.com/tpope/vim-obsession), which is itself a wrapper around Vim's built-in `:mksession`.
Initialize new sessions from the current directory with
```
vs init <session>
```
Open existing sesssions with
```
vs open <session>
```
or simply `vs open` to open up an interactive chooser.
To close a session, simply `:qa`.
Get more information with
```
vs -h
```

## Installation
If you have something like [fisher](https://github.com/jorgebucaran/fisher), you can
```
fisher install alexrutar/vs
```
Otherwise, the function is in [functions/vs.fish](functions/vs.fish) and the completions are in [completions/vs.fish](completions/vs.fish) and you can just copy them to the relevant folders.

## Dependencies
You need the tools [fzf](https://github.com/junegunn/fzf) and [fd](https://github.com/sharkdp/fd) accessible on your `PATH`.
You also need a mildly modern version of GNU `tree`.

You also need [Obsession.vim](https://github.com/tpope/vim-obsession) accessible to your preferred Vim executable.

## Configuration
You can select where you want the session files to be saved with the variable `VS_SESSION_DIR`.
It defaults to `$XDG_DATA_HOME/vs`.

For example, I personally like to
```
set -x VS_SESSION_DIR "$XDG_DATA_HOME/nvim/sessions"
```
You can also specify the Vim executable with `VS_VIM`, along with additional options.
For instance, if you want to use Neovim installed into `/usr/local` in verbose mode, you would
```
set -x VS_VIM /usr/local/bin/nvim -V
```
