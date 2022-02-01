function vs --argument command session_name new_session_name --description "Manage vim session files"
    set --local vs_version 0.1

    set --query VS_SESSION_DIR
    or set --query XDG_DATA_HOME && set --local VS_SESSION_DIR "$XDG_DATA_HOME/vs"
    or set --local VS_SESSION_DIR "$HOME/.local/share/vs"
    mkdir -p $VS_SESSION_DIR

    function __vs_list_sessions --inherit-variable VS_SESSION_DIR
        fd --extension vim --base-directory $VS_SESSION_DIR --exec echo {.}
    end

    function __vs_list_session_dirs --inherit-variable VS_SESSION_DIR
        fd --type d --base-directory $VS_SESSION_DIR --exclude "*.lock"  --strip-cwd-prefix | sed 's/$/\//'
    end

    switch $command
        case -v --version
            echo "vs, version $v_version"

        case '' -h --help help
            echo 'Usage: vs open [SESSION]   Open the session'
            echo '       vs init SESSION     Start up a new session'
            echo '       vs delete SESSION   Delete the session'
            echo '       vs rename OLD NEW   Rename the session'
            echo '       vs list             List available sessions'
            echo 'Options:'
            echo '       -v | --version     Print version'
            echo '       -h | --help        Print this help message'
            echo 'Variables:'
            echo '       VS_SESSION_DIR      Saved session directory.'
            echo '                            Default: ~/.local/share/vs'

        case open
            if not test -n "$session_name"
                set --local fzf_session (__vs_list_sessions | sort | fzf --height 40% --border --tac)
                if test -n "$fzf_session"
                    set session_name $fzf_session
                else
                    return 0
                end
            end

            set --local sessionfile $VS_SESSION_DIR/$session_name.vim
            set --local lockfile $VS_SESSION_DIR/$session_name.lock

            if test -f "$sessionfile"
                # clean up the lockfile and the handler on exit, even when interrupted
                # we require a unique name since we need one cleanup handler for each active session
                function __vs_cleanup \
                        --inherit-variable lockfile \
                        --on-signal INT --on-signal HUP \
                        --on-event fish_exit
                    functions --erase __vs_cleanup
                    rmdir $lockfile
                end

                if mkdir $lockfile &> /dev/null
                    vim -S $sessionfile
                    __vs_cleanup
                else
                    echo "Session '$session_name' already running!" >&2
                    return 1
                end
            else
                echo "Could not find session '$session_name'" >&2
                return 1
            end

        case mv rename
            set --local target $VS_SESSION_DIR/$new_session_name.vim
            mkdir --parents (dirname $target) && mv --interactive $VS_SESSION_DIR/$session_name.vim $target

        case rm delete
            rm --interactive $VS_SESSION_DIR/$session_name.vim

        case ls list
            if isatty 1
                __vs_list_sessions | tree --fromfile . --noreport
            else
                __vs_list_sessions | sort
            end

        case init
            set --local sessionfile $VS_SESSION_DIR/$session_name.vim
            if test -f $sessionfile
                echo "Cannot overwrite existing session '$session_name'" >&2
                return 1
            else
                mkdir --parents (dirname $sessionfile) && vim "+silent VSave $session_name" +term
            end

        # extra undocumented utility functions
        case _cleanup
            fd --extension lock --base-directory $VS_SESSION_DIR --exec rmdir

        case _list_all
            begin; __vs_list_sessions; __vs_list_session_dirs; end | sort

        case '*'
            echo "vs: Unknown command: \"$command\"" >&2
            return 1
    end
end
