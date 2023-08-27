set -l vs_subcommands open init rename delete list rm mv

complete -c vs -f

complete -c vs -n "not __fish_seen_subcommand_from $vs_subcommands" -s h -l help -d "Print help message"
complete -c vs -n "not __fish_seen_subcommand_from $vs_subcommands" -s V -l version -d "Print version"

complete -c vs -n "not __fish_seen_subcommand_from $vs_subcommands" -a open --description "Open the session"
complete -c vs -n "not __fish_seen_subcommand_from $vs_subcommands" -a init --description "Start a new session"
complete -c vs -n "not __fish_seen_subcommand_from $vs_subcommands" -a rename --description "Rename the session"
complete -c vs -n "not __fish_seen_subcommand_from $vs_subcommands" -a delete --description "Delete the session"
complete -c vs -n "not __fish_seen_subcommand_from $vs_subcommands" -a list --description "List available sessions"

complete -c vs -n "__fish_seen_subcommand_from open" -a "(vs list)" 
complete -c vs -n "__fish_seen_subcommand_from init rename mv delete rm" -a "(vs _list_all)"
