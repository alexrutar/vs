set -l v_subcommands_with_list open rename delete
complete --command v --exclusive --long help --description "Print help"
complete --command v --exclusive --long version --description "Print version"

complete --command v --exclusive --condition __fish_use_subcommand --arguments open --description "Open the session file"
complete --command v --exclusive --condition __fish_use_subcommand --arguments rename --description "Rename the session file"
complete --command v --exclusive --condition __fish_use_subcommand --arguments delete --description "Delete the session file"
complete --command v --exclusive --condition __fish_use_subcommand --arguments list --description "List available session files"
complete --command v --exclusive --condition __fish_use_subcommand --arguments init --description "Start up a new session"

complete -c v -a "(v list)" \
    -n "__fish_seen_subcommand_from $v_subcommands_with_list"

complete -c v -a "(v _list_dirs)" \
    -n "__fish_seen_subcommand_from init"
