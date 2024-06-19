# (Neo)Vim Session Manager

## Quick Start
This script is essentially a command line wrapper around [Obsession.vim](https://github.com/tpope/vim-obsession), which is itself a wrapper around Vim's built-in `:mksession`.
Initialize new sessions from the current directory with
```fish
vs init <session>
```
Open existing sessions with
```fish
vs open <session>
```
or simply `vs open` to open up an interactive chooser.
To close a session, simply `:qa`.
Get more information with
```fish
vs -h
```

## Installation
If you have something like [fisher](https://github.com/jorgebucaran/fisher), you can
```fish
fisher install alexrutar/vs
```
Otherwise, the function is in [functions/vs.fish](functions/vs.fish) and the completions are in [completions/vs.fish](completions/vs.fish) and you can just copy them to the relevant folders.

### Dependencies
You need the tools [fzf](https://github.com/junegunn/fzf) and [fd](https://github.com/sharkdp/fd) accessible on your `PATH`.
You also need a mildly modern version of GNU `tree`.

You also need [Obsession.vim](https://github.com/tpope/vim-obsession) accessible to your preferred Vim executable.

### Configuration
You can select where you want the session files to be saved with the variable `VS_SESSION_DIR`.
It defaults to `$XDG_DATA_HOME/vs/sessions`.

For example, I personally like to
```fish
set -x VS_SESSION_DIR "$XDG_DATA_HOME/nvim/sessions"
```
You can also specify the Vim executable with `VS_VIM_CMD`, along with additional options.
The default value is the first Vim executable found on your path.
For instance, if you instead want to use Neovim installed into `/usr/local` in verbose mode, you would
```fish
set -x VS_VIM_CMD /usr/local/bin/nvim -V
```

## Features
### Basic Session Management
You can delete and rename existing session files with `vs rename` and `vs delete`.
List available sessions with `vs list`.

### Interactive Session Browsing
If you have [fzf](https://github.com/junegunn/fzf) installed on your device, running
```fish
vs open
```
will pipe the list of sessions into `fzf`, which you can use to filter and choose an option.

### Lockfiles and cleanup
VS has a basic lockfile implementation which prevents multiple instances of a given session from running at the same time.
Sometimes, lockfiles are not removed even when there is no running instance (for example, if your shell exits ungracefully).
To fix this, first ensure that there are no running instances, and run
```
vs recover
```
