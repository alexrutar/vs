set -l v_subcommands open rename rm list init
complete -f -c v

complete -c v -a open \
    -n "not __fish_seen_subcommand_from $v_subcommands" \
    -d 'Open the session file.'

complete -c v -a mv \
    -n "not __fish_seen_subcommand_from $v_subcommands" \
    -d 'Rename the session file.'

complete -c v -a rm \
    -n "not __fish_seen_subcommand_from $v_subcommands" \
    -d 'Delete the session file.'

complete -c v -a list \
    -n "not __fish_seen_subcommand_from $v_subcommands" \
    -d 'List available session files.'

complete -c v -a init \
    -n "not __fish_seen_subcommand_from $v_subcommands" \
    -d 'Start up a new session'

complete -c v -a "(v list)" \
    -n "not __fish_seen_subcommand_from list init; and __fish_seen_subcommand_from $v_subcommands"

complete -c v -a "(v _list_dirs)" \
    -n "__fish_seen_subcommand_from init"
