# (Neo)Vim Session Manager
This script is essentially a command line wrapper around [Obsession.vim](https://github.com/tpope/vim-obsession), which is itself a wrapper around Vim's built-in `:mksession`.
Initialize new sessions with
```
vs init <session>
```
Open existing sesssions with
```
vs open <session>
```
or simply `vs open` to open up an interactive chooser.
If you are currently in a (Neo)Vim session which is not currently being saved, you can run
```
:VSave <session>
```
to start saving into the session file.
To close a session, simple `:qa`.

Get more information with
```
vs --help
```

## Installation
If you have something like [fisher](https://github.com/jorgebucaran/fisher) installed, you can
```
fisher install alexrutar/vs
```
Otherwise, the function is in [functions/vs.fish](functions/vs.fish) and the completions are in [completions/vs.fish](completions/vs.fish) and you can just install them manually.

You also need to configure (Neo)Vim.
First install [Obsession.vim](https://github.com/tpope/vim-obsession), and then add the following (Neo)Vim contents to your `.vimrc` or `init.vim`:
```
command -nargs=1 -complete=custom,ListVSessions VSave Obsess $VS_SESSION_DIR/<args>.vim
function ListVSessions(A,L,P)
    return system("vs _list_all")
endfun
```
Note that this assumes that fish is your default shell in (Neo)Vim.
If not, replace the third line with
```
    return system("fish -c 'vs _list_all'")
```
though this will likely make the autocompletion a bit slower.

## Dependencies
You need the tools [fzf](https://github.com/junegunn/fzf) and [fd](https://github.com/sharkdp/fd) accessible on your `PATH`.
You also need a mildly modern version of GNU `tree`.

## Configuration
You can select where you want the session files to be saved with the variable `VS_SESSION_DIR`.
It defaults to `$XDG_DATA_HOME/vs`.

For example, I personally like to
```
set -x VS_SESSION_DIR "$XDG_DATA_HOME/nvim/sessions"
```
You can also specify the Vim executable with `VS_VIM`, along with additional options.
If you want to use `nvim` installed into `/usr/local` in verbose mode, you would set
```
set -x VS_VIM /usr/local/bin/nvim -V
```
