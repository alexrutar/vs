function v --argument command session_name new_session_name --description "Manage vim session files"
    function __v_list_sessions
        fd -e vim --base-directory $V_SESSION_DIR --exec echo {.} | sort
    end
    function __v_list_session_dirs
        fd --type d --base-directory $V_SESSION_DIR --exclude "*.lock"  --strip-cwd-prefix | sed 's/$/\//' | sort
    end
    set -q V_SESSION_DIR
    or set -q XDG_DATA_DIR && set -l V_SESSION_DIR "$XDG_DATA_HOME/v"
    or set -l V_SESSION_DIR "$HOME/.local/share/v"
    switch $command
        case open
            if not test -n "$session_name"
                set -l fzf_session (__v_list_sessions | fzf --height 40% --border --tac)
                if test -n "$fzf_session"
                    set session_name $fzf_session
                else
                    return 0
                end
            end

            set -l sessionfile $V_SESSION_DIR/$session_name.vim
            set -l lockfile $V_SESSION_DIR/$session_name.lock

            if test -f "$sessionfile"
                # clean up the lockfile and the handler on exit, even when interrupted
                # we require a unique name since we need one cleanup handler for each active session
                function __v_cleanup \
                        --inherit-variable lockfile \
                        --on-signal INT --on-signal HUP \
                        --on-event fish_exit
                    functions -e __v_cleanup
                    rmdir $lockfile
                end

                if mkdir $lockfile &> /dev/null
                    vim -S $sessionfile
                    __v_cleanup
                else
                    echo "Session '$session_name' already running!" >&2
                    return 1
                end
            else
                echo "Could not find session '$session_name'" >&2
                return 1
            end

        case mv
            set -l target $V_SESSION_DIR/$new_session_name.vim
            mkdir -p (dirname $target) && mv -i $V_SESSION_DIR/$session_name.vim $target

        case rm
            rm -i $V_SESSION_DIR/$session_name.vim

        case list
            if isatty 1
                __v_list_sessions | tree --fromfile . --noreport
            else
                __v_list_sessions
            end

        case init
            set -l sessionfile $V_SESSION_DIR/$session_name.vim
            if test -f $sessionfile
                echo "Cannot overwrite existing session '$session_name'" >&2
                return 1
            else
                mkdir -p (dirname $sessionfile) && vim "+silent VSave $session_name" +term
            end

        case _cleanup
            fd -e lock --base-directory $V_SESSION_DIR -x rmdir


        case _list_dirs
            __v_list_session_dirs

        case '*'
            echo "Invalid command option '$argv[1]'" >&2
            return 1
    end
end
