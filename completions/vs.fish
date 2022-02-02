set -l vs_subcommands open init rename mv delete rm list
complete --command vs --exclusive
complete --command vs --exclusive --long help --description "Print help"
complete --command vs --exclusive --long version --description "Print version"

complete --command vs --exclusive --condition "not __fish_seen_subcommand_from $vs_subcommands" --arguments open --description "Open the session file"
complete --command vs --exclusive --condition "not __fish_seen_subcommand_from $vs_subcommands" --arguments init --description "Start up a new session"
complete --command vs --exclusive --condition "not __fish_seen_subcommand_from $vs_subcommands" --arguments rename --description "Rename the session file"
complete --command vs --exclusive --condition "not __fish_seen_subcommand_from $vs_subcommands" --arguments delete --description "Delete the session file"
complete --command vs --exclusive --condition "not __fish_seen_subcommand_from $vs_subcommands" --arguments list --description "List available session files"

complete --command vs --exclusive --condition "__fish_seen_subcommand_from open" --arguments "(vs list)" 
complete --command vs --exclusive --condition "__fish_seen_subcommand_from init rename mv delete rm" --arguments "(vs _list_all)"
