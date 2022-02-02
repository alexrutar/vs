complete --command vs --exclusive --long help --description "Print help"
complete --command vs --exclusive --long version --description "Print version"

complete --command vs --exclusive --condition __fish_use_subcommand --arguments open --description "Open the session file"
complete --command vs --exclusive --condition __fish_use_subcommand --arguments rename --description "Rename the session file"
complete --command vs --exclusive --condition __fish_use_subcommand --arguments delete --description "Delete the session file"
complete --command vs --exclusive --condition __fish_use_subcommand --arguments list --description "List available session files"
complete --command vs --exclusive --condition __fish_use_subcommand --arguments init --description "Start up a new session"

complete --command vs --exclusive --arguments "(vs list)" \
    --condition "__fish_seen_subcommand_from open delete rm"
complete --command vs --exclusive --arguments "(vs _list_all)" \
    --condition "__fish_seen_subcommand_from init rename mv"
