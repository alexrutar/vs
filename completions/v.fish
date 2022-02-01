# set -l v_subcommands_with_list open rename delete
complete --command v --exclusive --long help --description "Print help"
complete --command v --exclusive --long version --description "Print version"

complete --command v --exclusive --condition __fish_use_subcommand --arguments open --description "Open the session file"
complete --command v --exclusive --condition __fish_use_subcommand --arguments rename --description "Rename the session file"
complete --command v --exclusive --condition __fish_use_subcommand --arguments delete --description "Delete the session file"
complete --command v --exclusive --condition __fish_use_subcommand --arguments list --description "List available session files"
complete --command v --exclusive --condition __fish_use_subcommand --arguments init --description "Start up a new session"

complete --command v --exclusive --arguments "(v list)" \
    --condition "__fish_seen_subcommand_from open delete"

complete --command v --exclusive --arguments "(v _list_all)" \
    --condition "__fish_seen_subcommand_from init rename"
